# Port-Sight — Docker Deployment Guide

Deploy Port-Sight on any platform that runs Docker: Linux (Ubuntu, RHEL, etc.), Windows, or macOS.

---

## How It Works

Docker packages the application into isolated **containers**. Port-Sight uses three:

| Container | What it runs | Internal port |
|-----------|-------------|---------------|
| **frontend** | Nginx serving the React UI + proxying API calls | 80 / 443 |
| **backend** | Python FastAPI application server | 8000 |
| **db** | PostgreSQL 16 database | 5432 |

Users access the app on the port you choose (default: **80**). Nginx routes `/api/*` requests to the backend automatically. The backend and database are not directly exposed to the network.

**HTTPS is automatic** — if certificate files are present in the `certs/` folder, HTTPS enables itself on the next restart. No config files to edit.

---

## Quick Install (Recommended)

One command to install. Pick the one that matches your OS:

### Linux / macOS

```bash
curl -fsSL https://raw.githubusercontent.com/shunsing22/port-sight-releases/main/install.sh | bash
```

### Windows (PowerShell)

```powershell
irm https://raw.githubusercontent.com/shunsing22/port-sight-releases/main/install.ps1 | iex
```

> **Prerequisite:** Docker Desktop must be installed and running. Download it from https://www.docker.com/products/docker-desktop/

Both installers will:
1. Download the production Docker Compose file
2. Generate `.env` with secure random secrets
3. Pull pre-built images from GitHub Container Registry
4. Start the application

After install, open `http://localhost` in a browser. The first-run wizard will guide you through creating an admin account.

To customize settings (port, CORS, HTTPS), edit `.env` and restart:

```bash
cd ~/port-sight          # Linux/macOS
cd $HOME\port-sight      # Windows
# Edit .env, then:
docker compose up -d
```

### Install to a custom directory

```bash
# Linux/macOS
PORT_SIGHT_DIR=/opt/port-sight curl -fsSL https://raw.githubusercontent.com/shunsing22/port-sight-releases/main/install.sh | bash

# Windows (PowerShell)
$env:PORT_SIGHT_DIR="C:\port-sight"; irm https://raw.githubusercontent.com/shunsing22/port-sight-releases/main/install.ps1 | iex
```

---

## Manual Install

If you prefer to set things up yourself instead of using the one-command installer. Follow the section for your operating system start to finish.

---

### Linux (Ubuntu / Debian)

**1. Install Docker**

```bash
sudo apt update && sudo apt upgrade -y          # update package lists and upgrade existing packages
curl -fsSL https://get.docker.com | sudo sh     # download and run the official Docker install script
sudo usermod -aG docker $USER                   # allow your user to run Docker without sudo
# Log out and back in for the group change to take effect
```

Verify — both commands should print a version number:

```bash
docker --version            # e.g. "Docker version 27.5.1"
docker compose version      # e.g. "Docker Compose version v2.32.4"
```

**2. Download Port-Sight**

```bash
mkdir -p ~/port-sight && cd ~/port-sight        # create the install folder and move into it
# Download the production configuration and default settings
curl -fsSL https://raw.githubusercontent.com/shunsing22/port-sight-releases/main/docker-compose.prod.yml -o docker-compose.yml
curl -fsSL https://raw.githubusercontent.com/shunsing22/port-sight-releases/main/.env.example -o .env
```

**3. Configure**

```bash
nano .env       # open the config file in a text editor (you can also use vim, vi, etc.)
```

Edit the required variables (see [Configuration Reference](#configuration-reference) below).

**4. Start**

```bash
docker compose pull       # download the pre-built application images
docker compose up -d      # start all containers in the background
```

**5. Verify**

```bash
docker compose ps                            # list running containers — all three should show "Up"
curl http://localhost/api/health              # quick health check — should return {"status":"ok"}
```

Open `http://YOUR_SERVER_IP` in a browser. The first-run wizard will prompt you to create an admin account.

---

### Linux (RHEL / CentOS / Rocky / AlmaLinux / Fedora)

**1. Install Docker**

```bash
sudo dnf install -y dnf-plugins-core                                                          # enable plugin support
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo    # add Docker's official repo
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin               # install Docker engine + Compose
sudo systemctl enable --now docker                                                             # start Docker and enable on boot
sudo usermod -aG docker $USER                                                                  # allow your user to run Docker without sudo
# Log out and back in for the group change to take effect
```

Verify — both commands should print a version number:

```bash
docker --version            # e.g. "Docker version 27.5.1"
docker compose version      # e.g. "Docker Compose version v2.32.4"
```

**2. Download Port-Sight**

```bash
mkdir -p ~/port-sight && cd ~/port-sight        # create the install folder and move into it
# Download the production configuration and default settings
curl -fsSL https://raw.githubusercontent.com/shunsing22/port-sight-releases/main/docker-compose.prod.yml -o docker-compose.yml
curl -fsSL https://raw.githubusercontent.com/shunsing22/port-sight-releases/main/.env.example -o .env
```

**3. Configure**

```bash
nano .env       # open the config file in a text editor (you can also use vim, vi, etc.)
```

Edit the required variables (see [Configuration Reference](#configuration-reference) below).

**4. Start**

```bash
docker compose pull       # download the pre-built application images
docker compose up -d      # start all containers in the background
```

**5. Verify**

```bash
docker compose ps                            # list running containers — all three should show "Up"
curl http://localhost/api/health              # quick health check — should return {"status":"ok"}
```

Open `http://YOUR_SERVER_IP` in a browser. The first-run wizard will prompt you to create an admin account.

> **Firewall note:** You may need to open port 80: `sudo firewall-cmd --add-port=80/tcp --permanent && sudo firewall-cmd --reload`

---

### Windows

**1. Install Docker Desktop**

1. Download **Docker Desktop** from https://www.docker.com/products/docker-desktop/
2. Run the installer — enable **WSL 2** when prompted
3. Launch Docker Desktop and wait for the engine to start (green icon in system tray)

Verify — open **PowerShell** and run. Both commands should print a version number:

```powershell
docker --version            # e.g. "Docker version 27.5.1"
docker compose version      # e.g. "Docker Compose version v2.32.4"
```

**2. Download Port-Sight**

```powershell
mkdir "$HOME\port-sight" -Force                # create the install folder
cd "$HOME\port-sight"                          # move into it
# Download the production configuration and default settings
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/shunsing22/port-sight-releases/main/docker-compose.prod.yml" -OutFile "docker-compose.yml"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/shunsing22/port-sight-releases/main/.env.example" -OutFile ".env"
```

**3. Configure**

```powershell
notepad .env       # open the config file in Notepad
```

Edit the required variables (see [Configuration Reference](#configuration-reference) below).

**4. Start**

```powershell
docker compose pull       # download the pre-built application images
docker compose up -d      # start all containers in the background
```

**5. Verify**

```powershell
docker compose ps         # list running containers — all three should show "Up"
# Quick health check — should return {"status":"ok"}
Invoke-WebRequest http://localhost/api/health | Select-Object -Expand Content
```

Open `http://localhost` in a browser. The first-run wizard will prompt you to create an admin account.

---

### macOS

**1. Install Docker Desktop**

1. Download **Docker Desktop** from https://www.docker.com/products/docker-desktop/
2. Open the `.dmg` and drag Docker to Applications
3. Launch Docker Desktop and wait for the engine to start

Verify — open **Terminal** and run. Both commands should print a version number:

```bash
docker --version            # e.g. "Docker version 27.5.1"
docker compose version      # e.g. "Docker Compose version v2.32.4"
```

**2. Download Port-Sight**

```bash
mkdir -p ~/port-sight && cd ~/port-sight        # create the install folder and move into it
# Download the production configuration and default settings
curl -fsSL https://raw.githubusercontent.com/shunsing22/port-sight-releases/main/docker-compose.prod.yml -o docker-compose.yml
curl -fsSL https://raw.githubusercontent.com/shunsing22/port-sight-releases/main/.env.example -o .env
```

**3. Configure**

```bash
nano .env       # open the config file in a text editor (you can also use vim, vi, etc.)
```

Edit the required variables (see [Configuration Reference](#configuration-reference) below).

**4. Start**

```bash
docker compose pull       # download the pre-built application images
docker compose up -d      # start all containers in the background
```

**5. Verify**

```bash
docker compose ps                            # list running containers — all three should show "Up"
curl http://localhost/api/health              # quick health check — should return {"status":"ok"}
```

Open `http://localhost` in a browser. The first-run wizard will prompt you to create an admin account.

---

### Configuration Reference

Edit `.env` with the values below. If you used the Quick Install script, these are already generated for you.

#### Required variables

| Variable | What to do |
|----------|-----------|
| `POSTGRES_PASSWORD` | Pick a strong password (16+ characters) |
| `SECRET_KEY` | Run: `python3 -c "import secrets; print(secrets.token_hex(32))"` |
| `CREDENTIAL_ENCRYPTION_KEY` | Run: `python3 -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())"` |
| `CORS_ORIGINS` | Set to how users access the app (see examples below) |

#### CORS_ORIGINS examples

This must match the URL users type in their browser:

```
# HTTP on default port 80
CORS_ORIGINS=http://192.168.1.50

# HTTP on custom port
CORS_ORIGINS=http://192.168.1.50:3000

# HTTPS with domain
CORS_ORIGINS=https://portsight.company.com

# Multiple origins (comma-separated)
CORS_ORIGINS=http://localhost,http://192.168.1.50
```

#### Changing the port

If port 80 is already in use, set `HTTP_PORT` in `.env`:

```
HTTP_PORT=3000
```

Then access the app at `http://your-server:3000` and update `CORS_ORIGINS` to match.

---

## Enabling HTTPS

HTTPS activates automatically when certificate files are present. No config files to edit.

### Step 1 — Get your certificate files

You need two files:
- `cert.pem` — your SSL certificate (may include the intermediate chain)
- `key.pem` — your private key

These can come from:
- Your IT team or certificate authority
- A free provider like Let's Encrypt
- A self-signed certificate (for testing or internal-only use)

**To generate a self-signed certificate** (valid 1 year):

```bash
# Linux / macOS
mkdir -p certs
openssl req -x509 -newkey rsa:2048 -keyout certs/key.pem -out certs/cert.pem \
  -days 365 -nodes -subj "/CN=portsight"

# Windows (PowerShell) — requires OpenSSL installed, or use Git Bash:
mkdir certs
openssl req -x509 -newkey rsa:2048 -keyout certs/key.pem -out certs/cert.pem `
  -days 365 -nodes -subj "/CN=portsight"
```

### Step 2 — Place the files

Put `cert.pem` and `key.pem` in the `certs/` folder at the project root:

```
port-sight/
  certs/
    cert.pem
    key.pem
  docker-compose.yml
  .env
  ...
```

### Step 3 — Update .env

```bash
CORS_ORIGINS=https://portsight.company.com
```

If you're using a non-standard HTTPS port:

```bash
HTTPS_PORT=8443
CORS_ORIGINS=https://portsight.company.com:8443
```

### Step 4 — Restart

```bash
docker compose restart frontend
```

That's it. The frontend container detects the cert files on startup and automatically:
- Enables HTTPS on port 443
- Redirects all HTTP traffic to HTTPS

You'll see this in the logs:

```
[entrypoint] SSL certificates found — enabling HTTPS (HTTP will redirect)
```

### Disabling HTTPS

To go back to HTTP-only, simply remove or rename the `certs/` folder and restart:

```bash
mv certs certs.bak
docker compose restart frontend
```

---

## Updating Port-Sight

```bash
cd ~/port-sight              # or wherever you installed (Windows: cd $HOME\port-sight)
docker compose pull          # download the latest images
docker compose up -d         # restart with the new version
```

### Pinning a version

To use a specific version instead of `latest`, set in `.env`:

```bash
PORT_SIGHT_VERSION=1.3.0
```

Then pull and restart.

The database volume (`pgdata`) persists across restarts and rebuilds. Your data is safe unless you explicitly run `docker compose down -v` (which deletes volumes).

---

## Common Commands

```bash
# View logs (all containers)
docker compose logs

# View logs for one container (follow mode)
docker compose logs -f backend

# Stop everything (data is preserved)
docker compose down

# Restart after .env or config changes
docker compose up -d

# Check container status
docker compose ps

# Open a shell inside the backend container
docker compose exec backend bash

# Open a psql shell to the database
docker compose exec db psql -U portsight -d portsight
```

---

## Migrating from Neon Cloud to Local PostgreSQL

If you were using Neon (cloud PostgreSQL) and want to switch to the containerized database:

1. Export from Neon:
   ```bash
   pg_dump "postgresql://user:pass@neon-host/dbname" > backup.sql
   ```
2. Start the Docker stack: `docker compose up -d`
3. Import into the container:
   ```bash
   # Linux / macOS
   cat backup.sql | docker compose exec -T db psql -U portsight -d portsight

   # Windows (PowerShell)
   Get-Content backup.sql | docker compose exec -T db psql -U portsight -d portsight
   ```

To keep using Neon instead of a local database, edit `docker-compose.yml`:
- Remove the `db` service and the `pgdata` volume
- Set `DATABASE_URL` in `.env` to your Neon connection string
- Remove the `depends_on: db` block from the backend service

---

## Troubleshooting

### Container won't start

```bash
docker compose logs backend   # check for Python/startup errors
docker compose logs db         # check for PostgreSQL errors
docker compose logs frontend   # check for nginx errors
```

### "Connection refused" or page won't load

```bash
# Check all containers are running
docker compose ps

# Linux: check firewall
sudo ufw allow 80/tcp    # Ubuntu
sudo firewall-cmd --add-port=80/tcp --permanent && sudo firewall-cmd --reload  # RHEL/Rocky

# Windows: Docker Desktop must be running (check system tray)
```

### Backend can't connect to database

The backend waits for the `db` health check before starting. If you see connection errors:
```bash
docker compose logs db
```
Common cause: invalid `POSTGRES_PASSWORD` in `.env` or the password contains special characters that need quoting.

### Port already in use

Change `HTTP_PORT` (or `HTTPS_PORT`) in `.env` to an available port:
```bash
HTTP_PORT=8080
```
Then run `docker compose up -d` and update `CORS_ORIGINS` to match.

### HTTPS not working

Check that both cert files exist and are readable:
```bash
ls -la certs/
```
Check the frontend container logs for the entrypoint message:
```bash
docker compose logs frontend | head -5
```
You should see either `SSL certificates found` or `No SSL certificates found`.

### Rebuilding from scratch

```bash
docker compose down -v          # stop and remove volumes (DELETES ALL DATA)
docker compose up -d --build    # rebuild everything fresh
```

---

## Security Notes

- The `.env` file contains secrets — never commit it to git (already in `.gitignore`)
- For production, enable HTTPS (see above)
- The database and backend are **not** exposed to the host network — only nginx on the HTTP/HTTPS port is accessible
- The `certs/` folder is excluded from git (in `.gitignore`) — never commit private keys
