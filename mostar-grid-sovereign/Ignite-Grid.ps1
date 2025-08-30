#
# ? MoStar Grid - Sovereign Cloud Ignition Protocol ?
#
Write-Host "`n[1/4] Forging the Covenant with the Cloud..." -ForegroundColor Cyan
$terraformDir = ".\terraform"
$tfvarsFile = Join-Path $terraformDir "terraform.tfvars"
$projectId = "tokyo-scholar-356213"
try {
    Set-Content -Path $tfvarsFile -Value "project_id = `"$projectId`""
    Write-Host "? Secret key inscribed for project '$projectId'." -ForegroundColor Green
} catch {
    Write-Host "? FAILED to create terraform.tfvars file. Aborting." -ForegroundColor Red; return
}
Push-Location $terraformDir
try {
    Write-Host "`n[2/4] Initializing the Land (terraform init)..." -ForegroundColor Cyan
    terraform init
    if ($LASTEXITCODE -ne 0) { throw "Terraform initialization failed." }
    Write-Host "? Land initialized." -ForegroundColor Green
    Write-Host "`n[3/4] Revealing the Prophecy (terraform plan)..." -ForegroundColor Cyan
    terraform plan
    if ($LASTEXITCODE -ne 0) { throw "Terraform plan failed." }
    Write-Host "? Prophecy revealed. Review the plan above." -ForegroundColor Green
    Write-Host "`n[4/4] THE GENESIS PULSE (terraform apply)..." -ForegroundColor Yellow
    terraform apply -auto-approve
    if ($LASTEXITCODE -ne 0) { throw "THE GENESIS PULSE FAILED. The Grid is not yet born." }
    Write-Host "`n--- IGNITION COMPLETE ---" -ForegroundColor Yellow
    Write-Host "? The MoStar Grid is ALIVE in your sovereign cloud." -ForegroundColor Green
} catch {
    Write-Host "`n? An error occurred during the ignition sequence: $_" -ForegroundColor Red
} finally {
    Pop-Location
}
