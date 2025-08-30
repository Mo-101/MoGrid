terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# --- Enabling Required APIs ---
resource "google_project_service" "required_apis" {
  for_each = toset([
    "cloudsql.googleapis.com", "cloudfunctions.googleapis.com", "cloudbuild.googleapis.com",
    "apigateway.googleapis.com", "sourcerepo.googleapis.com", "aiplatform.googleapis.com",
    "firebase.googleapis.com", "firestore.googleapis.com"
  ])
  service = each.key
  disable_on_destroy = false
}

# --- SoulLayer: Immutable Vault ---
resource "google_sql_database_instance" "soul_vault" {
  name             = "soul-vault"
  database_version = "POSTGRES_15"
  region           = var.region
  settings {
    tier             = "db-custom-2-4096"
    availability_type = "REGIONAL"
    ip_configuration {
      require_ssl = true
    }
  }
  deletion_protection = false
  depends_on = [google_project_service.required_apis]
}

resource "google_sql_database" "soul_db" {
  name     = "mostar_codex"
  instance = google_sql_database_instance.soul_vault.name
}

# --- MindLayer: Truth Engine (Source Code Storage) ---
resource "google_storage_bucket" "source_code_bucket" {
  name          = "${var.project_id}-source-code"
  location      = var.region
  force_destroy = true
}

data "archive_file" "truth_engine_source" {
  type        = "zip"
  source_dir  = "../mind_layer/engines/truth_engine/"
  output_path = "${path.module}/truth_engine.zip"
}

resource "google_storage_bucket_object" "truth_engine_zip" {
  name   = "truth_engine.zip"
  bucket = google_storage_bucket.source_code_bucket.name
  source = data.archive_file.truth_engine_source.output_path
}

# --- MindLayer: Truth Engine (Cloud Function) ---
resource "google_cloudfunctions2_function" "truth_engine" {
  name        = "truth-engine"
  location    = var.region
  build_config {
    runtime     = "python311"
    entry_point = "trinity_gate"
    source {
      storage_source {
        bucket = google_storage_bucket.source_code_bucket.name
        object = google_storage_bucket_object.truth_engine_zip.name
      }
    }
  }
  service_config {
    max_instance_count = 5
    ingress_settings   = "ALLOW_INTERNAL_ONLY"
  }
  depends_on = [google_project_service.required_apis]
}

# --- BodyLayer: API Gateway ---
resource "google_api_gateway_api" "mostar_api" {
  api_id = "mostar-grid-api"
  display_name = "MoStar Sovereign Grid API"
  depends_on = [google_project_service.required_apis]
}

resource "google_api_gateway_api_config" "mostar_api_config" {
  api           = google_api_gateway_api.mostar_api.api_id
  api_config_id = "v1"
  openapi_documents {
    document {
      path     = "openapi.yaml"
      contents = file("${path.module}/../body_layer/api/openapi.yaml")
    }
  }
  gateway_config {
    backend_config {
      google_cloud_function_backend {
        function = google_cloudfunctions2_function.truth_engine.name
      }
    }
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "google_api_gateway_gateway" "gateway" {
  api_config = google_api_gateway_api_config.mostar_api_config.id
  gateway_id = "mostar-gateway"
  region     = var.region
}
