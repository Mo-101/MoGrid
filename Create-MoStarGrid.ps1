Set-Content -Path ".\Create-MoStarGrid.ps1" -Value @'
#
# ⚡ MoStar Grid - Genesis Materialization Protocol ⚡
#
# This script forges the complete directory structure and all foundational
# files for the MoStar Grid's sovereign GCP environment.
#

Write-Host "--- Initiating Genesis Materialization Protocol ---" -ForegroundColor Yellow
$rootDir = "." # Use the current directory

# --- Phase 1: Forge the Skeleton ---
Write-Host "`n[1/5] Forging the Grid's skeleton..." -ForegroundColor Cyan
$directories = @(
    "terraform", "codex", "body_layer/api",
    "mind_layer/engines/truth_engine", "moscripts"
)
foreach ($dir in $directories) {
    if (-not (Test-Path -Path (Join-Path $rootDir $dir))) {
        New-Item -ItemType Directory -Path (Join-Path $rootDir $dir) | Out-Null
    }
}
Write-Host "✅ Skeleton forged." -ForegroundColor Green

# --- Phase 2: Inscribe the Law & The Land ---
Write-Host "`n[2/5] Inscribing the Law and the Land..." -ForegroundColor Cyan
Set-Content -Path (Join-Path $rootDir "📜-README.md") -Value @'