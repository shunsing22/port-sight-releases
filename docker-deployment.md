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

The `.env` file controls how Port-Sight runs. If you used the **Quick Install** script, it will ask you two questions (port and server address) and auto-generate everything else — you can skip this section unless you need to change something later.

If you used the **Manual Install**, open `.env` in a text editor and review the settings below.

> **To apply changes:** After editing `.env`, restart with `docker compose up -d` from the install folder.

---

#### Network Settings

**`HTTP_PORT`** — The port number Port-Sight listens on for HTTP traffic.

The default is `80`, which is the standard web port (so users just type `http://your-server` without specifying a port). If another application on this server is already using port 80, change this to an available port.

```
HTTP_PORT=80       # default — users access via http://your-server
HTTP_PORT=3000     # alternative — users access via http://your-server:3000
```

> **Planning to use HTTPS?** Start with HTTP on port 80 for now. After installation is working, you can enable HTTPS by placing certificate files in the `certs/` folder — see the [Enabling HTTPS](#enabling-https) section below. HTTPS will automatically activate on port 443, and HTTP will redirect to it.

**`CORS_ORIGINS`** — The URL(s) that users type in their browser to reach Port-Sight.

CORS (Cross-Origin Resource Sharing) is a browser security feature. Port-Sight's backend needs to know the exact URL that users will access so it can allow the frontend to communicate with it. **If this doesn't match what users type in their browser, the app will load but show errors when trying to fetch data.**

You can list **multiple addresses** separated by commas (no spaces around the commas). This is common when the server is accessed both locally and over the network.

```
# Single address — users access via IP on default port 80:
CORS_ORIGINS=http://192.168.1.50

# Single address — using a custom port:
CORS_ORIGINS=http://192.168.1.50:3000

# Single address — domain name with HTTPS:
CORS_ORIGINS=https://portsight.company.com

# Multiple addresses — accessed locally AND over the network:
CORS_ORIGINS=http://localhost,http://192.168.1.50

# Multiple addresses — IP, hostname, and domain all work:
CORS_ORIGINS=http://localhost,http://192.168.1.50,http://portsight.company.com
```

> **Common mistake:** Setting `CORS_ORIGINS=http://localhost` but then accessing the app from another computer at `http://192.168.1.50`. The browser will block API calls because the address doesn't match. **Add every address that users might type** — it's better to list too many than too few.

**`HTTPS_PORT`** — Uncomment this line to enable HTTPS. You also need to place certificate files in the `certs/` folder (see the [Enabling HTTPS](#enabling-https) section below).

---

#### Database Settings

Port-Sight includes its own database — you do **not** need to install or manage a separate database server. These settings control the built-in PostgreSQL container.

**`POSTGRES_USER`**, **`POSTGRES_PASSWORD`**, **`POSTGRES_DB`** — Credentials for the built-in database. The install script generates a strong random password automatically. **Do not change these after first run** unless you are willing to recreate the database from scratch.

> **For manual install only:** If you're setting these yourself, pick a strong password (16+ characters). The other two can stay as `portsight`.

**Using an external database** (advanced): If you want to host the database on a separate server (e.g., an existing PostgreSQL server on your network, or a cloud service like Amazon RDS or Neon), you'll need to edit `docker-compose.yml` directly:

1. Remove the `db` service block and the `pgdata` volume at the bottom
2. Remove `depends_on: db` from the `backend` service
3. Change the `DATABASE_URL` line in the `backend` environment to point to your external database:
   ```
   DATABASE_URL: postgresql+asyncpg://username:password@your-db-server:5432/portsight
   ```
4. Run `docker compose up -d` to apply

Most users should use the built-in database — it requires zero setup and is backed up with the Docker volume. Only use an external database if your organization requires centralized database management.

---

#### Security Secrets

These are cryptographic keys that Port-Sight uses internally. The install script generates them automatically. **Do not share these with anyone or post them publicly.**

**`SECRET_KEY`** — Used to sign login tokens (JWTs). If someone gets this key, they can forge login sessions. To generate one manually:

```bash
python3 -c "import secrets; print(secrets.token_hex(32))"
```

**`CREDENTIAL_ENCRYPTION_KEY`** — Used to encrypt SNMP passwords stored in the database. If you lose this key, you'll need to re-enter all switch SNMP credentials. To generate one manually:

```bash
python3 -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())"
```

---

#### Authentication

**`ACCESS_TOKEN_EXPIRE_MINUTES`** — How many minutes a user stays logged in before their session expires and they need to log in again. Default is `60` (1 hour). Set higher for convenience, lower for security.

**`ALGORITHM`** — The algorithm used to sign login tokens. Leave this as `HS256` unless you have a specific reason to change it.

---

#### Display Options

**`STRIP_SWITCH_DOMAIN`** — Controls how switch names appear in the UI. If your switches report their names as fully qualified domain names (e.g., `sw1.building-a.company.com`), set this to `true` to display just the short name (`sw1`). Default is `false` (show the full name).

---

#### Scheduled Polling

Port-Sight can automatically poll all your switches on a recurring schedule. These settings control the default daily poll time.

**`POLL_SCHEDULE_HOUR`** and **`POLL_SCHEDULE_MINUTE`** — The time of day to run the automatic poll, in 24-hour format using the server's timezone. Default is `2:00 AM` (hour=2, minute=0). You can also configure more complex schedules (hourly, weekly, etc.) from the web UI after installation.

---

#### Version Pinning

**`PORT_SIGHT_VERSION`** — By default, Port-Sight uses the latest version when you run `docker compose pull`. To lock to a specific version (e.g., if you want to test before upgrading), uncomment this line and set a version number:

```
PORT_SIGHT_VERSION=1.3.0
```

Then run `docker compose pull && docker compose up -d` to apply.

---

## Enabling HTTPS

HTTPS activates automatically when certificate files are present. No config files to edit.

### What you need

Port-Sight expects two files in the `certs/` folder:

| File | What it is |
|------|-----------|
| `cert.pem` | Your SSL/TLS certificate (may include the intermediate chain) |
| `key.pem` | The private key that matches the certificate |

There are three ways to get these files, depending on your situation:

---

### Option A — Request a certificate from your IT team or company CA

This is the most common approach in corporate environments. Your organization likely has an internal Certificate Authority (CA) or a process for requesting certificates.

**Step 1 — Generate a private key and Certificate Signing Request (CSR):**

A CSR is a file you send to your CA that says "I need a certificate for this server." The CA uses it to create your certificate.

```bash
# Linux / macOS — run from the port-sight install folder
mkdir -p certs
openssl req -new -newkey rsa:2048 -nodes \
  -keyout certs/key.pem \
  -out certs/portsight.csr \
  -subj "/CN=portsight.company.com"
```

```powershell
# Windows (PowerShell) — requires OpenSSL installed, or use Git Bash
mkdir certs -Force
openssl req -new -newkey rsa:2048 -nodes `
  -keyout certs/key.pem `
  -out certs/portsight.csr `
  -subj "/CN=portsight.company.com"
```

Replace `portsight.company.com` with the actual hostname or domain name users will type in their browser. If users will access it by IP address, use the IP instead (e.g., `/CN=192.168.1.50`).

This creates two files:
- `certs/key.pem` — your private key (**keep this secret**, do not send it to anyone)
- `certs/portsight.csr` — the CSR to send to your CA

**Step 2 — Submit the CSR to your CA:**

Send the `portsight.csr` file to your IT team or certificate authority. They will return a signed certificate file (often called `cert.pem`, `certificate.crt`, or similar).

**Step 3 — Save the certificate:**

Save the certificate your CA returned as `certs/cert.pem`. If they also provided an intermediate/chain certificate, append it to the same file:

```bash
# If you received separate cert and chain files, combine them:
cat your-certificate.crt intermediate-chain.crt > certs/cert.pem
```

```powershell
# Windows equivalent:
Get-Content your-certificate.crt, intermediate-chain.crt | Set-Content certs/cert.pem
```

You should now have both files in `certs/`:
```
port-sight/
  certs/
    cert.pem    ← certificate from your CA
    key.pem     ← private key (generated in Step 1)
```

---

### Option B — Self-signed certificate (for testing or internal use)

A self-signed certificate encrypts traffic but browsers will show a security warning because it's not issued by a trusted CA. This is fine for internal tools or testing.

```bash
# Linux / macOS
mkdir -p certs
openssl req -x509 -newkey rsa:2048 -keyout certs/key.pem -out certs/cert.pem \
  -days 365 -nodes -subj "/CN=portsight"
```

```powershell
# Windows (PowerShell) — requires OpenSSL installed, or use Git Bash
mkdir certs -Force
openssl req -x509 -newkey rsa:2048 -keyout certs/key.pem -out certs/cert.pem `
  -days 365 -nodes -subj "/CN=portsight"
```

> **Note:** Users will see a "Your connection is not private" warning in their browser. They can click through it (Advanced → Proceed), but this is only suitable for internal/testing use — not customer-facing deployments.

---

### Option C — Free certificate from Let's Encrypt

Let's Encrypt provides free, trusted certificates that browsers accept without warnings. This requires your server to be reachable from the internet on port 80 (for domain validation).

1. Install **certbot**: https://certbot.eff.org/instructions
2. Run certbot to get your certificate:
   ```bash
   sudo certbot certonly --standalone -d portsight.company.com
   ```
3. Copy the generated files to Port-Sight's `certs/` folder:
   ```bash
   sudo cp /etc/letsencrypt/live/portsight.company.com/fullchain.pem ~/port-sight/certs/cert.pem
   sudo cp /etc/letsencrypt/live/portsight.company.com/privkey.pem ~/port-sight/certs/key.pem
   ```

Let's Encrypt certificates expire every 90 days. Certbot can auto-renew them, but you'll need to copy the renewed files and restart the frontend container.

---

### Activate HTTPS

Once your `cert.pem` and `key.pem` are in the `certs/` folder:

**1. Update `.env`** — Change `CORS_ORIGINS` from `http://` to `https://`:

```
CORS_ORIGINS=https://portsight.company.com
```

If you're using a non-standard HTTPS port (anything other than 443):

```
HTTPS_PORT=8443
CORS_ORIGINS=https://portsight.company.com:8443
```

**2. Restart the frontend container:**

```bash
docker compose restart frontend
```

That's it. The frontend container detects the cert files on startup and automatically:
- Enables HTTPS on port 443 (or your custom `HTTPS_PORT`)
- Redirects all HTTP traffic to HTTPS

You'll see this in the logs:

```
[entrypoint] SSL certificates found — enabling HTTPS (HTTP will redirect)
```

### Disabling HTTPS

To go back to HTTP-only, remove or rename the `certs/` folder, update `CORS_ORIGINS` back to `http://`, and restart:

```bash
mv certs certs.bak
# Edit .env: change CORS_ORIGINS back to http://...
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

### Beta releases

Beta versions are pre-release builds available for early testing. They may contain new features that haven't been fully vetted. To opt in to the beta channel, set in `.env`:

```bash
PORT_SIGHT_VERSION=beta
```

Then pull and restart:

```bash
docker compose pull
docker compose up -d
```

To go back to stable:

```bash
# Remove or comment out the version override, or set to latest:
PORT_SIGHT_VERSION=latest
```

Then pull and restart.

Beta versions follow the format `X.Y.Z-beta.N` (e.g., `1.7.0-beta.1`). You can also pin to a specific beta version if needed:

```bash
PORT_SIGHT_VERSION=1.7.0-beta.2
```

**Important:** Beta releases are not recommended for production environments. Use them on test servers or non-critical deployments. Your data is safe — beta versions use the same database format as stable releases, and you can always roll back to a stable version.

### Rolling back

To revert to a previous stable version after testing a beta:

```bash
# Set the version to a known stable release or latest
PORT_SIGHT_VERSION=latest
docker compose pull
docker compose up -d
```

---

## Backup & Restore

Port-Sight includes built-in database backup and restore, accessible from the **Admin > Backups** page.

### Creating a Backup

Click **Create Backup** in the admin UI. This runs `pg_dump` against the database and saves a compressed `.sql.gz` file. Backups are stored in a persistent Docker volume (`backups`), so they survive container restarts.

You can also **download** backups to your local machine for offsite storage.

### Restoring a Backup

Click **Restore from File**, confirm the warning, then select a `.sql.gz` backup file. This will **overwrite all current data** in the database.

### What backups include

Database backups cover all application data: switches, interfaces, poll history, users, settings, licenses, filter profiles, flags, and VLANs.

### What backups do NOT include

- **TLS certificates** in the `certs/` folder — back these up manually
- **`.env` configuration** (database passwords, encryption keys, CORS settings) — document or save separately
- **Docker volumes and images** — managed by Docker, not the application

### Disaster recovery

In a disaster recovery scenario you are moving Port-Sight from a failed server to
a new one. Both servers run Docker — this is the standard customer deployment path.

#### The encryption key problem

The install script generates a random `CREDENTIAL_ENCRYPTION_KEY` on every fresh
install. Port-Sight uses this key to encrypt all SNMP credentials stored in the
database. **If you restore a backup onto a new server that has a different key,
the backend cannot decrypt those credentials and every poll will fail with a
"Config error."**

The solution is to copy the original server's `CREDENTIAL_ENCRYPTION_KEY` into
the new server's `.env` before starting the stack. The backup restore itself
will not fix this — it only restores database rows, not the `.env` file.

#### Important: `docker compose restart` does NOT reload `.env`

`docker compose restart` keeps the environment variables that were baked in when
the container was first created. It does **not** re-read `.env`. Whenever you
change a value in `.env` you must recreate the containers:

```bash
# Always use this after changing .env — not restart
docker compose up -d

# Force a single container to reload if needed
docker compose up -d --force-recreate backend
```

Verify the running container has the value you expect:

```bash
docker compose exec backend env | grep CREDENTIAL_ENCRYPTION_KEY
```

#### DR procedure

1. **Install Port-Sight on the new server:**
   ```bash
   curl -fsSL https://raw.githubusercontent.com/shunsing22/port-sight-releases/main/install.sh | bash
   ```
   Let it complete, then stop the stack:
   ```bash
   cd /opt/port-sight && docker compose down
   ```

2. **Update `.env` on the new server** with the encryption keys from the old server.
   The simplest approach is to copy the whole `.env` file — the POSTGRES_PASSWORD
   and other settings can safely be carried over since the database is still empty
   at this point:
   ```bash
   # If you can reach the old server directly:
   scp user@old-server:/opt/port-sight/.env /opt/port-sight/.env

   # If you have a saved copy of the old .env:
   # Upload it to /opt/port-sight/.env on the new server

   # If you only have the key values, edit manually:
   nano /opt/port-sight/.env
   # Update CREDENTIAL_ENCRYPTION_KEY= and SECRET_KEY= to match the old server
   ```

3. **Start the stack** — use `up -d`, not `restart`:
   ```bash
   docker compose up -d
   ```

4. **Verify the key loaded into the container:**
   ```bash
   docker compose exec backend env | grep CREDENTIAL_ENCRYPTION_KEY
   # Must match the old server's value exactly
   ```

5. **Restore HTTPS certificates** (if applicable):
   ```bash
   scp user@old-server:/opt/port-sight/certs/* /opt/port-sight/certs/
   docker compose up -d
   ```

6. **Upload the database backup** via Admin > Backups > Restore from File.

7. **Log in** with your original credentials. Run a manual poll on one switch
   to confirm polling works before considering the DR complete.

#### Symptom: polls fail with "Config error" after restore

Work through this in order:

1. Check what key the running container actually has:
   ```bash
   docker compose exec backend env | grep CREDENTIAL_ENCRYPTION_KEY
   ```
2. If it doesn't match the old server's key, the container wasn't recreated.
   Force it:
   ```bash
   docker compose up -d --force-recreate backend
   ```
3. Re-check, then retry polling.

#### If the original `.env` is lost

Restore the backup anyway — all switch records, poll history, users, and settings
come back correctly. Polling will fail because the SNMP passwords in the database
are encrypted with a key you no longer have.

To restore polling: go to Admin > Switch Management, edit each switch, and re-enter
its SNMP credentials. They will be re-encrypted with the new key and polling resumes
immediately. No other data is affected.

#### Verifying a successful restore

- [ ] Can log in with original credentials
- [ ] Admin > Switch Management shows all switches
- [ ] Manual poll on at least one switch completes without error
- [ ] Admin > License shows the correct license or trial status
- [ ] Admin > System shows the expected version and settings

### Backup retention

Up to 20 backups are retained. When the limit is reached, the oldest backup is automatically deleted.

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

### Uninstalling / Clean Reinstall

Use this to completely remove Port-Sight and start fresh — for example, to test a new version or decommission the server.

⚠️ This permanently deletes all data (switches, poll history, settings, users, backups). Make sure you have a backup first if the data matters.

**Linux / macOS:**

```bash
# 1. Find the install directory (if you've forgotten where it is)
docker inspect port-sight-db-1 | grep "working_dir"

# 2. Stop containers and delete all volumes
cd /path/to/install/dir
docker compose down -v

# 3. Remove the install directory
cd ~
rm -rf /path/to/install/dir

# 4. (Optional) Remove cached Docker images to force a fresh pull
docker rmi ghcr.io/shunsing22/port-sight/backend:latest
docker rmi ghcr.io/shunsing22/port-sight/frontend:latest

# 5. Reinstall
curl -fsSL https://raw.githubusercontent.com/shunsing22/port-sight-releases/main/install.sh | bash
```

**Windows (PowerShell):**

```powershell
# 1. Find the install directory (if you've forgotten where it is)
docker inspect port-sight-db-1 | Select-String "working_dir"

# 2. Stop containers and delete all volumes
cd C:\path\to\install\dir
docker compose down -v

# 3. Remove the install directory
cd $env:USERPROFILE
Remove-Item -Recurse -Force C:\path\to\install\dir

# 4. (Optional) Remove cached Docker images to force a fresh pull
docker rmi ghcr.io/shunsing22/port-sight/backend:latest
docker rmi ghcr.io/shunsing22/port-sight/frontend:latest

# 5. Reinstall (run in PowerShell as Administrator)
irm https://raw.githubusercontent.com/shunsing22/port-sight-releases/main/install.ps1 | iex
```

---

## Security Notes

- The `.env` file contains secrets — never commit it to git (already in `.gitignore`)
- For production, enable HTTPS (see above)
- The database and backend are **not** exposed to the host network — only nginx on the HTTP/HTTPS port is accessible
- The `certs/` folder is excluded from git (in `.gitignore`) — never commit private keys
