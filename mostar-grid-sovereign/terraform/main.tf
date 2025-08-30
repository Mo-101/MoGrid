terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}
provider "google" { project = var.project_id }
resource "google_project_service" "apis" {
  for_each           = toset([
    "cloudsql.googleapis.com",
    "cloudfunctions.googleapis.com",
    "cloudbuild.googleapis.com",
    "apigateway.googleapis.com"
  ])
  service            = each.key
  disable_on_destroy = false
}
