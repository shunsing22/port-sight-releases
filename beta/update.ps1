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

# -- Channel + self-refresh (v2.13.0-beta.5) -------------------------------
# Same idea as update.sh: fetch this script's current copy for the install's
# channel (beta/ folder for beta installs) and re-run once if it changed, so
# a release that changes what the updater must do never depends on the copy
# already on disk. Best effort.
$releasesUrl = "https://raw.githubusercontent.com/shunsing22/port-sight-releases/main"
$channel = "stable"
$envText = Get-Content ".env" -Raw
$composeText = Get-Content "docker-compose.yml" -Raw
if ($envText -match '(?m)^PORT_SIGHT_VERSION=.*beta' -or $composeText -match 'PORT_SIGHT_CHANNEL: beta') { $channel = "beta" }
$scriptsUrl = $releasesUrl
if ($channel -eq "beta") { $scriptsUrl = "$releasesUrl/beta" }
if ($env:PORT_SIGHT_UPDATER_REFRESHED -ne "1") {
  try {
    $self = Join-Path $PSScriptRoot "update.ps1"
    Invoke-WebRequest -Uri "$scriptsUrl/update.ps1" -OutFile "$self.new" -UseBasicParsing
    if ((Test-Path "$self.new") -and ((Get-Item "$self.new").Length -gt 0)) {
      $newText = Get-Content "$self.new" -Raw
      $oldText = Get-Content $self -Raw
      if ($newText -ne $oldText) {
        Move-Item -Force "$self.new" $self
        Write-Host "Updater refreshed from the $channel channel; re-running."
        $env:PORT_SIGHT_UPDATER_REFRESHED = "1"
        & powershell -NoProfile -ExecutionPolicy Bypass -File $self
        exit $LASTEXITCODE
      }
      Remove-Item -Force "$self.new"
    }
  } catch {
    if (Test-Path "$self.new") { Remove-Item -Force "$self.new" }
  }
}


# -- Flow collector (v2.13 WP N2) --------------------------------
# Existing installs have a local docker-compose.yml copied at install time
# (install.ps1 downloads it once; update.ps1 never re-downloads it) -- so a
# fresh v2.13 release needs to ADD the flow service to whatever is already
# there, idempotently, before pulling (otherwise the pull below never
# fetches the flow image at all). Two independent checks so re-running this
# on an already-updated file is a safe no-op either way.
function Add-FlowCollector {
  $composeFile = "docker-compose.yml"
  $content = Get-Content $composeFile
  $needService = -not ($content -match "port-sight/flow")
  $needUrl = -not ($content -match "FLOW_URL")
  if (-not $needService -and -not $needUrl) { return }

  $portDefault = "2055"
  $tagDefault = "latest"
  if ($content -match "PORT_SIGHT_CHANNEL: beta") {
    $portDefault = "2056"
    $tagDefault = "beta"
  }

  $stamp = Get-Date -Format "yyyyMMdd"
  Copy-Item $composeFile "$composeFile.bak-$stamp" -Force

  $flowBlock = @(
    "  # NetFlow/IPFIX/sFlow collector (v2.13 WP N2) -- decodes flows in"
    "  # memory only, never writes to disk or the database. Not a"
    "  # depends_on of backend: the app must start and run normally"
    "  # when this container is absent. Added by update.ps1."
    "  flow:"
    "    image: ghcr.io/shunsing22/port-sight/flow:`${PORT_SIGHT_VERSION:-$tagDefault}"
    "    restart: unless-stopped"
    "    ports:"
    "      - `"`${FLOW_PORT:-$portDefault}:2055/udp`""
    "    environment:"
    "      PORT_SIGHT_VERSION: `${PORT_SIGHT_VERSION:-$tagDefault}"
    "    mem_limit: `${FLOW_MEM_LIMIT:-2g}"
    "    cpus: `${FLOW_CPUS:-2.0}"
    ""
  )

  $out = New-Object System.Collections.Generic.List[string]
  $inBackend = $false
  $inEnv = $false
  $envDone = $false
  $flowInserted = $false

  foreach ($line in $content) {
    if ($line -match '^  [A-Za-z_][A-Za-z0-9_]*:') {
      $inBackend = ($line -eq "  backend:")
      $inEnv = $false
    }
    if ($needUrl -and $inBackend -and $line -match '^    environment:') {
      $inEnv = $true
      $out.Add($line)
      continue
    }
    if ($needUrl -and $inEnv) {
      if ($line -match '^      [A-Za-z_]') {
        $out.Add($line)
        continue
      }
      if (-not $envDone) {
        $out.Add("      FLOW_URL: http://flow:8085")
        $envDone = $true
      }
      $inEnv = $false
    }
    if ($needService -and -not $flowInserted -and $line -eq "volumes:") {
      $out.AddRange([string[]]$flowBlock)
      $flowInserted = $true
    }
    $out.Add($line)
  }
  if ($needUrl -and $inEnv -and -not $envDone) {
    $out.Add("      FLOW_URL: http://flow:8085")
  }
  if ($needService -and -not $flowInserted) {
    $out.AddRange([string[]]$flowBlock)
  }

  Set-Content -Path $composeFile -Value $out -Encoding ascii

  if ($needService) {
    Write-Host "  Added the flow collector service to docker-compose.yml (UDP port $portDefault; backup: $composeFile.bak-$stamp)."
    Write-Host "  Make sure UDP $portDefault is reachable from your NetFlow/IPFIX/sFlow exporters."
  }
  if ($needUrl) {
    Write-Host "  Added FLOW_URL to the backend service's environment in docker-compose.yml."
  }
}
try { Add-FlowCollector } catch { Write-Host "  (could not update docker-compose.yml for the flow collector: $_)" }

# Raise an older flow service block's resource budget in place: 512m -> 1g
# in v2.13.0-beta.11, then 1g -> 2g and one core -> two in v2.13.13 (see
# update.sh's own comment for the production evidence -- goflow2 was being
# OOM-killed with three exporters on a 1 GiB / 1-core cap). Only values WE
# wrote are replaced, so an admin who has tuned these keeps their own.
try {
  $lines = Get-Content "docker-compose.yml"
  $inFlow = $false; $changed = $false
  for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match '^  [A-Za-z_][A-Za-z0-9_]*:') { $inFlow = ($lines[$i] -eq "  flow:") }
    if ($inFlow -and $lines[$i] -match '^\s+mem_limit: (512m|1g)\s*$') {
      $lines[$i] = '    mem_limit: ${FLOW_MEM_LIMIT:-2g}'; $changed = $true
    }
    if ($inFlow -and $lines[$i] -match '^\s+cpus: 1\.0\s*$') {
      $lines[$i] = '    cpus: ${FLOW_CPUS:-2.0}'; $changed = $true
    }
  }
  if ($changed) { Set-Content -Path "docker-compose.yml" -Value $lines -Encoding ascii; Write-Host "  Raised the flow collector's memory and CPU limits (2g / 2 cores) in docker-compose.yml." }
} catch { }

# v2.13.13: give an older install's flow block the PORT_SIGHT_VERSION
# variable so the collector can log and report which build it is (it used to
# log a hardcoded literal). See update.sh for the matching logic. Skipped
# when the block already has an `environment:` key, so a hand-edited compose
# file never gets a duplicate YAML key; the guard anchors on key lines
# because the flow service's `image:` line contains PORT_SIGHT_VERSION as
# part of its tag.
try {
  $raw = Get-Content "docker-compose.yml"
  $inFlow = $false; $hasEnv = $false
  foreach ($line in $raw) {
    if ($line -match '^  [A-Za-z_][A-Za-z0-9_]*:') { $inFlow = ($line -eq "  flow:") }
    if ($inFlow -and ($line -match '^    environment:' -or $line -match '^      PORT_SIGHT_VERSION:')) { $hasEnv = $true }
  }
  if ((Select-String -Path "docker-compose.yml" -Pattern 'port-sight/flow' -Quiet) -and (-not $hasEnv)) {
    $tagDefaultEnv = "latest"
    if (Select-String -Path "docker-compose.yml" -Pattern 'PORT_SIGHT_VERSION:-beta' -Quiet) { $tagDefaultEnv = "beta" }
    $out = New-Object System.Collections.Generic.List[string]
    $inFlow = $false; $inserted = $false
    foreach ($line in $raw) {
      if ($line -match '^  [A-Za-z_][A-Za-z0-9_]*:') { $inFlow = ($line -eq "  flow:") }
      if ($inFlow -and (-not $inserted) -and ($line -match '^    (mem_limit|cpus):')) {
        $out.Add("    environment:")
        $out.Add('      PORT_SIGHT_VERSION: ${PORT_SIGHT_VERSION:-' + $tagDefaultEnv + '}')
        $inserted = $true
      }
      $out.Add($line)
    }
    if ($inserted) {
      Set-Content -Path "docker-compose.yml" -Value $out -Encoding ascii
      Write-Host "  Told the flow collector its own version (PORT_SIGHT_VERSION) in docker-compose.yml."
    }
  }
} catch { }

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
