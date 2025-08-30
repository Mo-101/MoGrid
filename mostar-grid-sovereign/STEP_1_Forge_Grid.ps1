[CmdletBinding()]
param()
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

Write-Host "`n--- Initiating Forging Protocol (minimal) ---" -ForegroundColor Yellow
$root = (Get-Location).Path

# 1) skeleton
$dirs = @("terraform")
foreach ($d in $dirs) { New-Item -ItemType Directory -Path (Join-Path $root $d) -Force | Out-Null }

# 2) terraform: variables + main
Set-Content -Path (Join-Path $root "terraform/variables.tf") -Encoding UTF8 -Value @"
variable "project_id" { type = string }
"@

Set-Content -Path (Join-Path $root "terraform/main.tf") -Encoding UTF8 -Value @"
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
"@

Write-Host "✅ Minimal Forge complete at: $root" -ForegroundColor Green
