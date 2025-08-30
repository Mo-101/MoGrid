[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)]
  [string]$ProjectId
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

Write-Host "`n--- Ignition Preflight ---" -ForegroundColor Yellow

# 0) terraform present
$tf = Get-Command terraform -ErrorAction SilentlyContinue
if (-not $tf) { throw "Terraform not found in PATH. Install via scoop/winget and open a NEW PowerShell." }
Write-Host "Terraform: $($tf.Source)" -ForegroundColor DarkGray

# 1) ensure ./terraform exists
$terraformDir = Join-Path (Get-Location) "terraform"
if (-not (Test-Path $terraformDir)) { throw "Missing ./terraform directory. Run STEP_1_Forge_Grid.ps1 first." }

# 2) write tfvars
$tfvarsPath = Join-Path $terraformDir "terraform.tfvars"
Set-Content -Path $tfvarsPath -Encoding UTF8 -Value ("project_id = '{0}'" -f $ProjectId)

# 3) init/validate/plan
Push-Location $terraformDir
try {
  Write-Host "`n[1/3] terraform init ..." -ForegroundColor Cyan
  & terraform init -input=false

  Write-Host "`n[2/3] terraform validate ..." -ForegroundColor Cyan
  & terraform validate

  Write-Host "`n[3/3] terraform plan ..." -ForegroundColor Cyan
  & terraform plan -out ".\plan.out" -input=false

  Write-Host "`n✅ Plan generated. Ready for apply." -ForegroundColor Green
}
catch {
  Write-Host "`n❌ Ignition (plan) failed: $($_.Exception.Message)" -ForegroundColor Red
  Write-Host "If error mentions Google auth/ADC, run: gcloud auth application-default login" -ForegroundColor Yellow
  throw
}
finally {
  Pop-Location
}
