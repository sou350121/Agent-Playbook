param(
  [string]$StoriesDir = "stories",
  [string]$PromptsDir = "prompts",
  [string]$SessionsDir = "sessions",
  [string]$FeaturesDir = "docs/features"
)

function Fail($msg) { Write-Host "[FAIL] $msg"; exit 1 }
function Warn($msg) { Write-Host "[WARN] $msg" }

$stories = Get-ChildItem -Path $StoriesDir -Filter "*.md" -File -ErrorAction SilentlyContinue
if (-not $stories -or $stories.Count -eq 0) { Fail "No stories found under $StoriesDir/*.md" }

$missing = $false
foreach ($s in $stories) {
  $base = [System.IO.Path]::GetFileNameWithoutExtension($s.Name)
  $prompt = Join-Path $PromptsDir ("$base.md")
  $failures = Join-Path (Join-Path $SessionsDir $base) "failures.md"
  $status = Join-Path (Join-Path $FeaturesDir $base) "status.md"

  if (-not (Test-Path $prompt)) { Write-Host "Missing $prompt"; $missing = $true }
  if (-not (Test-Path $failures)) { Write-Host "Missing $failures"; $missing = $true }
  if (-not (Test-Path $status)) { Write-Host "Missing $status"; $missing = $true }

  if (Test-Path $status) {
    $content = Get-Content $status -Raw
    if ($content -notmatch [regex]::Escape((Join-Path $StoriesDir $s.Name))) { Warn "$status does not reference story path" }
    if ($content -notmatch [regex]::Escape($prompt)) { Warn "$status does not reference prompt path" }
  }
}

if ($missing) { Fail "Evidence chain incomplete" }
Write-Host "[OK] DocOps evidence chain looks good"