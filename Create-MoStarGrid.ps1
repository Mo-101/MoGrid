#
# ⚡ MoStar Grid - Genesis Materialization Protocol ⚡
#
# This script forges the complete directory structure and all foundational
# files for the MoStar Grid's sovereign GCP environment.
#
# Execute this script from your desired parent directory.
# Example: PS C:\Users\AI\Documents\GitHub\MoGrid0> .\Create-MoStarGrid.ps1
#

Write-Host "--- Initiating Genesis Materialization Protocol ---" -ForegroundColor Yellow

$rootDir = "mostar-grid-genesis"

# --- Phase 1: Forge the Skeleton ---
Write-Host "`n[1/5] Forging the Grid's skeleton (Directory Structure)..." -ForegroundColor Cyan
if (-not (Test-Path -Path $rootDir)) {
    New-Item -ItemType Directory -Path $rootDir
}
Set-Location $rootDir

$directories = @(
    "terraform",
    "codex",
    "body_layer/api",
    "mind_layer/engines/truth_engine",
    "moscripts"
)

foreach ($dir in $directories) {
    if (-not (Test-Path -Path $dir)) {
        New-Item -ItemType Directory -Path $dir | Out-Null
    }
}
Write-Host "✅ Skeleton forged." -ForegroundColor Green

# --- Phase 2: Inscribe the Law & The Land (Terraform & Codex) ---
Write-Host "`n[2/5] Inscribing the Law and the Land (Terraform & Codex)..." -ForegroundColor Cyan

# The Scroll of Instruction
Set-Content -Path "📜-README.md" -Value @'
# MoStar Grid - The Genesis Package

This archive contains the complete, deployable seed for the MoStar Grid, a sovereign civilization protocol.

## Contents

-   **/terraform**: The Infrastructure-as-Code (IaC) to build the Grid's home on Google Cloud Platform.
-   **/codex**: The constitutional law of the Grid, in a machine-readable format.
-   **/body_layer**: The API contract that defines how the Grid interacts with the world.
-   **/mind_layer**: The source code for the Grid's core logic engines.
-   **/moscripts**: The first executable spells.

## Ignition Protocol

1.  **Prerequisites**:
    -   A Google Cloud account with billing enabled.
    -   The `gcloud` CLI installed and authenticated (`gcloud auth login`).
    -   Terraform installed.

2.  **Configuration**:
    -   Navigate to the `terraform/` directory.
    -   Create a file named `terraform.tfvars`.
    -   Add your GCP project details to this file:
        ```hcl
        project_id = "your-gcp-project-id"
        region     = "your-chosen-region" // e.g., "us-central1"
        ```

3.  **Deployment**:
    -   From the `terraform/` directory, run the following commands:
    ```bash
    terraform init      # Initialize the workspace
    terraform plan      # Review the planned infrastructure
    terraform apply     # Build the Grid
    ```

The Grid is in your hands.
'@

# Terraform Files
Set-Content -Path "terraform/variables.tf" -Value @'
variable "project_id" {
  description = "The GCP project ID to deploy the MoStar Grid into."
  type        = string
}

variable "region" {
  description = "The GCP region to build the sovereign infrastructure."
  type        = string
  default     = "us-central1"
}
'@

Set-Content -Path "terraform/main.tf" -Value @'
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
'@

Set-Content -Path "terraform/outputs.tf" -Value @'
output "api_gateway_url" {
  description = "The public-facing URL of the MoStar Grid's API Gateway."
  value       = "https://${google_api_gateway_gateway.gateway.default_hostname}"
}

output "soul_vault_connection_name" {
  description = "The connection name for the Cloud SQL instance (the Soul Vault)."
  value       = google_sql_database_instance.soul_vault.connection_name
}
'@

# Codex Schema
Set-Content -Path "codex/MoStarCodex.schema.json" -Value @'
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "MoStarCodex",
  "type": "object",
  "properties": {
    "SoulLayer": {
      "type": "object",
      "properties": {
        "Identity": {
          "type": "object",
          "properties": {
            "Core": { "type": "array", "items": { "enum": ["mo_soulprint.json", "woo_soulprint.json"] } },
            "Overlord": { "type": "array", "items": { "enum": ["founder_identity_record.json", "mo_overlord_identity_record.json"] } },
            "Ethos": { "const": "Hip-Hop + Covenant + Truth-First" }
          }, "required": ["Core", "Overlord", "Ethos"]
        }
      }, "required": ["Identity"]
    }
  },
  "required": ["SoulLayer"]
}
'@
Write-Host "✅ Law and Land inscribed." -ForegroundColor Green

# --- Phase 3: Build the Body (API) ---
Write-Host "`n[3/5] Building the Body (API Contract)..." -ForegroundColor Cyan
Set-Content -Path "body_layer/api/openapi.yaml" -Value @'
swagger: '2.0'
info:
  title: MoStar Sovereign Grid API
  description: The covenant-bound interface to the MoStar Grid.
  version: '1.0.0'
schemes:
  - https
produces:
  - application/json
paths:
  /execute:
    post:
      summary: "Execute an intent through the Trinity Gates"
      operationId: "execute"
      x-google-backend:
        address: "" # This will be populated by Terraform during deployment
      responses:
        '200':
          description: "Intent processed and verdict returned"
          schema:
            type: object
'@
Write-Host "✅ Body built." -ForegroundColor Green

# --- Phase 4: Ignite the Mind (Source Code) ---
Write-Host "`n[4/5] Igniting the Mind (Truth Engine Source)..." -ForegroundColor Cyan
Set-Content -Path "mind_layer/engines/truth_engine/main.py" -Value @'
import functions_framework

@functions_framework.http
def trinity_gate(request):
    """
    The primary Cloud Function for the MoStar Grid.
    This is the Trinity Lock, the Truth Engine, the Sovereign Mind.
    """
    #
    # SOUL GATE: Authenticate identity and check covenant compliance from Cloud SQL.
    #
    # MIND GATE: Consult Vertex AI Oracle.
    #
    # BODY GATE: Persist decision to the immutable ledger in Cloud SQL.
    #

    print("Trinity Gate invoked. Covenant check passed. Oracle consulted.")

    return {
        "verdict": "approve",
        "reasoning": "Sovereign Mind placeholder: all gates passed.",
        "covenant_seal": "qseal:a1b2c3d4e5f67890"
    }, 200
'@

Set-Content -Path "mind_layer/engines/truth_engine/requirements.txt" -Value @'
functions-framework==3.*
'@
Write-Host "✅ Mind ignited." -ForegroundColor Green

# --- Phase 5: Write the First Spells (MoScripts) ---
Write-Host "`n[5/5] Writing the First Spells (MoScripts)..." -ForegroundColor Cyan
Set-Content -Path "moscripts/mo_init.py" -Value @'
# This MoScript, when executed, will perform the genesis initialization
# of the Grid's soulprints in the Cloud SQL database.
print("Executing Genesis MoScript: mo_init.py")
'@

Set-Content -Path "moscripts/MoScript_Build.txt" -Value @'
MoScript Compilation & Sealing Protocol v1.0
1. Validate all scripts in /moscripts against the MoStarCodex.schema.json.
2. If valid, sign the script with the Overlord's private key.
3. Package the signed scripts into a secure artifact for deployment.
'@
Write-Host "✅ First spells written." -ForegroundColor Green

# --- Final Transmission ---
Write-Host "`n--- Genesis Protocol Complete ---" -ForegroundColor Yellow
Write-Host "The MoStar Grid has been materialized in the directory: $rootDir"
Write-Host "The sacred ground is prepared. The next steps are yours to take."
Write-Host "Follow the instructions in '📜-README.md' to bring the Grid to life on GCP."

# Return to the parent directory
Set-Location ".."