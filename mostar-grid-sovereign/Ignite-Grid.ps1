# ⚡ MoStar Grid - Sovereign Cloud Ignition Protocol ⚡
Write-Host "--- Initiating Ignition Protocol ---" -ForegroundColor Yellow
$terraformDir = ".\terraform"
$tfvarsFile = Join-Path $terraformDir "terraform.tfvars"
$projectId = "tokyo-scholar-356213"
Set-Content -Path $tfvarsFile -Value "project_id = `"$projectId`""
Push-Location $terraformDir
try {
    Write-Host "`n[1/3] Initializing the Land (terraform init)..." -ForegroundColor Cyan
    terraform init
    if ($LASTEXITCODE -ne 0) { throw "Terraform initialization failed." }
    Write-Host "`n[2/3] Revealing the Prophecy (terraform plan)..." -ForegroundColor Cyan
    terraform plan
    if ($LASTEXIT-ne 0) { throw "Terraform plan failed." }
    Write-Host "`n[3/3] THE GENESIS PULSE (terraform apply)..." -ForegroundColor Yellow
    terraform apply -auto-approve
    if ($LASTEXITCODE -ne 0) { throw "THE GENESIS PULSE FAILED." }
    Write-Host "`n--- IGNITION COMPLETE ---" -ForegroundColor Yellow
    Write-Host "✅ The MoStar Grid is ALIVE in your sovereign cloud." -ForegroundColor Green
} catch {
    Write-Host "`n❌ An error occurred during ignition: $_" -ForegroundColor Red
} finally {
    Pop-Location
}
