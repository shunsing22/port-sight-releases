# ─────────────────────────────────────────────────────────────
# Port-Sight Installer for Windows
# Downloads docker-compose.prod.yml, generates .env, and starts
# the application via Docker Compose.
#
# Usage:
#   irm https://raw.githubusercontent.com/shunsing22/port-sight-releases/main/install.ps1 | iex
#   # or
#   .\install.ps1
# ─────────────────────────────────────────────────────────────

& {
  $ErrorActionPreference = "Stop"

  $DefaultDir = "C:\Port-Sight"
  $ComposeUrl = "https://raw.githubusercontent.com/shunsing22/port-sight-releases/main/docker-compose.prod.yml"

  Write-Host ""
  Write-Host "  +------------------------------------+"
  Write-Host "  |       Port-Sight Installer         |"
  Write-Host "  +------------------------------------+"
  Write-Host ""

  # ── Pre-flight checks ──────────────────────────────────────
  try { $null = Get-Command docker -ErrorAction Stop } catch {
    Write-Host ""
    Write-Host "  ERROR: Docker is not installed." -ForegroundColor Red
    Write-Host ""
    Write-Host "  Install Docker Desktop from:"
    Write-Host "    https://www.docker.com/products/docker-desktop/" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  After installing, launch Docker Desktop and wait for it to start,"
    Write-Host "  then re-run this script."
    Write-Host ""
    return
  }

  $composeCheck = $null
  try { $composeCheck = & docker compose version 2>&1 } catch {}
  if (-not $composeCheck -or $LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "  ERROR: Docker Compose is not available." -ForegroundColor Red
    Write-Host ""
    Write-Host "  Docker Compose is included with Docker Desktop."
    Write-Host "  Make sure Docker Desktop is running (check the system tray)."
    Write-Host ""
    return
  }

  # ── Install directory prompt ──────────────────────────────
  # Allow override via environment variable, otherwise prompt
  if ($env:PORT_SIGHT_DIR) {
    $InstallDir = $env:PORT_SIGHT_DIR
  } else {
    Write-Host "  Where should Port-Sight be installed?"
    Write-Host "  This folder will contain the configuration files (docker-compose.yml,"
    Write-Host "  .env, and certificates). The application itself runs inside Docker."
    Write-Host ""
    Write-Host "  The default is $DefaultDir. Just press Enter to accept."
    Write-Host ""
    $InputDir = Read-Host "  Install directory [$DefaultDir]"
    $InputDir = $InputDir.Trim()
    if (-not $InputDir) { $InstallDir = $DefaultDir } else { $InstallDir = $InputDir }
  }

  # ── Create install directory ───────────────────────────────
  Write-Host ""
  Write-Host "Install directory: $InstallDir"
  New-Item -ItemType Directory -Path "$InstallDir\certs" -Force | Out-Null
  Set-Location $InstallDir

  # ── Download docker-compose.prod.yml ───────────────────────
  Write-Host "Downloading docker-compose.prod.yml..."
  Invoke-WebRequest -Uri $ComposeUrl -OutFile "docker-compose.yml" -UseBasicParsing

  # ── Generate .env if it doesn't exist ──────────────────────
  if (Test-Path ".env") {
    Write-Host "Existing .env found - keeping current configuration."
  } else {
    Write-Host "Generating .env with secure random secrets..."
    Write-Host ""

    # ── Interactive prompts ──────────────────────────────────
    # Read-Host works in both piped (irm | iex) and direct (.\install.ps1) modes

    Write-Host "  What port should Port-Sight listen on?"
    Write-Host "  The default is 80 (standard web traffic). Just press Enter to use 80."
    Write-Host ""
    Write-Host "  TIP: If you plan to use HTTPS instead, just use port 80 for now."
    Write-Host "  You can enable HTTPS after installation by placing certificate files"
    Write-Host "  in the certs\ folder. See the deployment guide for details."
    Write-Host ""
    $InputPort = Read-Host "  HTTP port [80]"
    $InputPort = $InputPort.Trim()
    if (-not $InputPort) { $InputPort = "80" }

    Write-Host ""
    Write-Host "  How will users access Port-Sight in their browser?"
    Write-Host "  Enter the server's IP address, hostname, or domain name."
    Write-Host ""
    Write-Host "  If users will access it from multiple addresses (for example,"
    Write-Host "  both localhost AND a network IP), separate them with commas."
    Write-Host ""
    Write-Host "  Examples:"
    Write-Host "    192.168.1.50                        (single IP)"
    Write-Host "    portsight.company.com               (domain name)"
    Write-Host "    localhost, 192.168.1.50             (multiple addresses)"
    Write-Host ""
    $InputAddr = Read-Host "  Server address(es) [localhost]"
    $InputAddr = $InputAddr.Trim()
    if (-not $InputAddr) { $InputAddr = "localhost" }

    # Build CORS origins from the inputs (supports comma-separated addresses)
    $AddrList = $InputAddr -split "," | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" }
    $CorsOrigins = @()
    foreach ($addr in $AddrList) {
      if ($InputPort -eq "80") {
        $CorsOrigins += "http://$addr"
      } else {
        $CorsOrigins += "http://${addr}:${InputPort}"
      }
    }
    $CorsValue = $CorsOrigins -join ","

    Write-Host ""

    # Generate secrets using .NET crypto
    $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()

    # SECRET_KEY: 64 hex chars
    $skBytes = New-Object byte[] 32
    $rng.GetBytes($skBytes)
    $SecretKey = -join ($skBytes | ForEach-Object { $_.ToString("x2") })

    # POSTGRES_PASSWORD: 32 alphanumeric chars
    $pgBytes = New-Object byte[] 32
    $rng.GetBytes($pgBytes)
    $PgPassword = [Convert]::ToBase64String($pgBytes) -replace '[/+=]','' | Select-Object -First 1
    $PgPassword = $PgPassword.Substring(0, [Math]::Min(32, $PgPassword.Length))

    # CREDENTIAL_ENCRYPTION_KEY: Fernet key (base64url-encoded 32 bytes)
    $fernetBytes = New-Object byte[] 32
    $rng.GetBytes($fernetBytes)
    $FernetKey = [Convert]::ToBase64String($fernetBytes) -replace '\+','-' -replace '/','_'

    $timestamp = (Get-Date -Format "yyyy-MM-dd HH:mm:ss") + " UTC"

    $envContent = @"
# ── Port-Sight Configuration ─────────────────────────────
# Generated by install.ps1 on $timestamp
#
# To change these settings later, edit this file and restart:
#   cd $InstallDir
#   docker compose up -d

# ── Network ───────────────────────────────────────────────
# HTTP_PORT: The port number Port-Sight listens on.
#   Default is 80 (standard web port). Change this if port 80
#   is already used by another application on this server.
HTTP_PORT=$InputPort

# HTTPS_PORT: Uncomment to enable HTTPS on a specific port.
#   You also need to place cert.pem and key.pem in the certs\ folder.
# HTTPS_PORT=443

# CORS_ORIGINS: The full URL that users type in their browser
#   to access Port-Sight. This MUST match exactly, including the
#   port number (if not 80). If this is wrong, the app will load
#   but show errors when trying to fetch data.
#   Examples: http://192.168.1.50  http://10.0.0.5:3000
#             https://portsight.company.com
CORS_ORIGINS=$CorsValue

# ── Database ──────────────────────────────────────────────
# These control the built-in PostgreSQL database container.
# You do NOT need an external database — one is included.
# Do not change these after first run unless you recreate the database.
POSTGRES_USER=portsight
POSTGRES_PASSWORD=$PgPassword
POSTGRES_DB=portsight

# ── Security Secrets ──────────────────────────────────────
# Auto-generated. Do not share these or commit them to version control.
# SECRET_KEY: Used to sign authentication tokens (login sessions).
# CREDENTIAL_ENCRYPTION_KEY: Used to encrypt stored SNMP passwords.
SECRET_KEY=$SecretKey
CREDENTIAL_ENCRYPTION_KEY=$FernetKey

# ── Authentication ────────────────────────────────────────
# How long a user stays logged in before needing to log in again.
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=480

# ── Display Options ───────────────────────────────────────
# STRIP_SWITCH_DOMAIN: If your switches have names like "sw1.corp.com",
#   set to true to display just "sw1" in the UI.
STRIP_SWITCH_DOMAIN=false

# ── Scheduled Polling ─────────────────────────────────────
# Port-Sight can automatically poll all switches on a daily schedule.
# Set the time of day (24-hour format, server timezone).
# Default: 2:00 AM. Configure additional schedules in the web UI.
POLL_SCHEDULE_HOUR=2
POLL_SCHEDULE_MINUTE=0

# ── Version Pinning ───────────────────────────────────────
# By default, Port-Sight uses the latest version. Uncomment and set
# a version number to lock to a specific release.
# PORT_SIGHT_VERSION=1.3.0
"@

    $envContent | Out-File -FilePath ".env" -Encoding ascii -NoNewline
    Write-Host ".env created with auto-generated secrets."
  }

  # ── Pull images and start ─────────────────────────────────
  Write-Host ""
  Write-Host "Pulling Docker images..."
  & docker compose pull

  Write-Host ""
  Write-Host "Starting Port-Sight..."
  & docker compose up -d

  Write-Host ""
  Write-Host "  Port-Sight is running!" -ForegroundColor Green
  Write-Host ""
  # Read CORS value back from .env to show the correct URL
  $AppUrl = (Select-String -Path ".env" -Pattern "^CORS_ORIGINS=" | ForEach-Object { $_.Line -replace "^CORS_ORIGINS=","" })
  if (-not $AppUrl) { $AppUrl = "http://localhost" }
  Write-Host "  Open $AppUrl in your browser to complete setup."
  Write-Host "  (First visit will prompt you to create an admin account.)"
  Write-Host ""
  Write-Host "  Useful commands:"
  Write-Host "    cd $InstallDir"
  Write-Host "    docker compose logs -f                                # View logs"
  Write-Host "    docker compose down                                   # Stop"
  Write-Host "    docker compose pull; docker compose up -d             # Update"
  Write-Host ""
  Write-Host "  For HTTPS, place your cert.pem and key.pem in:"
  Write-Host "    $InstallDir\certs\"
  Write-Host "  Then restart: docker compose restart frontend"
  Write-Host ""
}
