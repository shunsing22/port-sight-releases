# Port-Sight updater for Windows (Docker Desktop). Run from the install folder:
#
#   .\update.ps1
#
# Pulls the current images for the channel in .env (PORT_SIGHT_VERSION:
# latest, beta, or a pinned number), restarts the stack, then removes the
# Port-Sight image versions no container uses. Every release left behind by a
# plain "docker compose pull" is half a gigabyte that stays on disk forever.
$ErrorActionPreference = "Stop"
Set-Location -Path $PSScriptRoot

if (-not (Test-Path "docker-compose.yml") -or -not (Test-Path ".env")) {
  Write-Host "Run this from your Port-Sight install folder (docker-compose.yml and .env not found in $PSScriptRoot)."
  exit 1
}

Write-Host "Updating Port-Sight in $PSScriptRoot"
& docker compose pull
& docker compose up -d
# A plain "up -d" has been seen to leave the frontend on the old image.
& docker compose up -d --force-recreate frontend 2>$null

# Which tag the stack runs (kept even when the stack is stopped).
$keep = "latest"
$line = Get-Content ".env" | Where-Object { $_ -match '^PORT_SIGHT_VERSION=' } | Select-Object -Last 1
if ($line) { $v = ($line -split "=", 2)[1].Trim().Trim('"').Trim("'"); if ($v) { $keep = $v } }

$removed = 0
$refs = & docker images --filter "reference=ghcr.io/shunsing22/port-sight/*" --format "{{.Repository}}:{{.Tag}}" 2>$null
foreach ($ref in $refs) {
  if (-not $ref -or $ref.EndsWith(":<none>") -or $ref.EndsWith(":$keep")) { continue }
  # Docker refuses to remove a tag a container still uses -- the guard we want.
  & docker image rm $ref 2>$null | Out-Null
  if ($LASTEXITCODE -eq 0) { Write-Host "  removed $ref"; $removed++ }
}
# Untagged leftovers (the previous :latest after each pull); dangling only.
& docker image prune -f | Select-String "Total reclaimed" | ForEach-Object { Write-Host "  $_" }

Write-Host ""
& docker compose ps
Write-Host ""
Write-Host "  Port-Sight updated; removed $removed old image tag(s). Version: see Admin > System."
