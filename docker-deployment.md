# Port-Sight — Docker Deployment Guide

Deploy Port-Sight on any platform that runs Docker: Linux (Ubuntu, RHEL, etc.), Windows, or macOS.

---

## How It Works

Docker packages the application into isolated **containers**. Port-Sight uses four:

| Container | What it runs | Internal port |
|-----------|-------------|---------------|
| **frontend** | Nginx serving the React UI + proxying API calls | 80 / 443 |
| **backend** | Python FastAPI application server | 8000 |
| **db** | PostgreSQL 16 database | 5432 |
| **flow** | NetFlow/IPFIX/sFlow collector (v2.13) — decodes flow exports from your network gear in memory only; nothing it sees is ever written to disk or the database | 2055/udp (2055/2056 in the compose files — see below) |

Users access the app on the port you choose (default: **80**). Nginx routes `/api/*` requests to the backend automatically. The backend, database and flow collector are not directly exposed to the network beyond the flow collector's own UDP listening port (see "Flow collector" below) — everything else only talks to the other containers.

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
curl -fsSL https://raw.githubusercontent.com/shunsing22/port-sight-releases/main/install.sh | PORT_SIGHT_DIR=/opt/port-sight bash

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

**`POLL_SCHEDULE_HOUR`** and **`POLL_SCHEDULE_MINUTE`** — Legacy; no longer read. The poll schedule lives in the database and is set on **Admin > Network > Polling > Schedule** (daily at 02:00 server time on a fresh install; hourly, every N hours, daily or weekly are available). The variables stay in `.env` and the compose file for compatibility and can be ignored.

---

#### Version Pinning

**`PORT_SIGHT_VERSION`** — By default, Port-Sight uses the latest version when you run `docker compose pull`. To lock to a specific version (e.g., if you want to test before upgrading), uncomment this line and set a version number:

```
PORT_SIGHT_VERSION=1.3.0
```

Then run `docker compose pull && docker compose up -d` to apply.

---

#### Flow Collector

**`FLOW_PORT`** — The UDP port the `flow` container (v2.13) listens on for NetFlow v5/v9, IPFIX and sFlow. Point your switches/routers/firewalls at this port on the Port-Sight host. Default **2055** on the production compose file, **2056** on the beta compose file (the two stacks share one host IP, so each exporter needs the host listed twice — once per port — if you run both side by side).

```
FLOW_PORT=2055
```

Open this port for inbound **UDP** from your exporters in your host/network firewall — nothing else needs to reach it. The container stores nothing on disk or in the database (aggregates a rolling 15-minute in-memory window only); if it's ever unreachable, the rest of Port-Sight keeps running normally and Admin > System > Health shows it as unreachable. See the admin guide's "Flow collector" chapter for per-platform exporter configuration. If an exporter shows up as a `172.x.x.1`-style address instead of the real device, see "Exporter shows as the Docker gateway" in that same chapter, or `docs/troubleshooting.md`.

**Recommended: before you point exporters at this host.** On Linux, set `{"userland-proxy": false}` in `/etc/docker/daemon.json` and restart Docker *before* configuring any switch/router/firewall to send flows here — applying it after exporters are already streaming can leave a stale kernel conntrack entry that keeps delivering to the old path even once the setting is correct (the fix is a one-line `conntrack` flush, but it's simpler to never need it). `install.sh` prints a reminder about this during installation when the setting isn't already present; it never changes the setting for you. See the admin guide's "Exporter shows as the Docker gateway" subsection (section 14) for the full step-by-step, including the conntrack flush if you've already hit this.

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

A CSR is a file you send to your CA that says "I need a certificate for this
server." It contains the name you want certified and a public key; the matching
private key is created at the same time and **never leaves your server**.

Decide the name first: it must be exactly what users type in the browser address
bar. `portsight.company.com` and `portsight` are different names, and a
certificate for one is not valid for the other.

```bash
# Linux / macOS — run from the port-sight install folder
mkdir -p certs
openssl req -new -newkey rsa:2048 -nodes \
  -keyout certs/key.pem \
  -out certs/portsight.csr \
  -subj "/CN=portsight.company.com" \
  -addext "subjectAltName=DNS:portsight.company.com"

chmod 600 certs/key.pem
```

```powershell
# Windows (PowerShell) — requires OpenSSL installed, or use Git Bash
mkdir certs -Force
openssl req -new -newkey rsa:2048 -nodes `
  -keyout certs/key.pem `
  -out certs/portsight.csr `
  -subj "/CN=portsight.company.com" `
  -addext "subjectAltName=DNS:portsight.company.com"
```

**The `subjectAltName` is the part that matters.** Current browsers ignore the
CN completely and check only the SAN list; a certificate whose SAN does not
include the name being typed is rejected outright, with no way for the user to
proceed in some browsers. Always include it, and always list the same name you
put in the CN.

**If users reach Port-Sight by more than one name** — a short hostname and an
FQDN, say, or an old name during a migration — list them all, separated by
commas, and keep the primary one in the CN:

```
  -addext "subjectAltName=DNS:portsight.company.com,DNS:portsight"
```

**If users reach it by IP address**, the SAN entry uses `IP:` rather than `DNS:`:

```
  -subj "/CN=192.168.1.50" \
  -addext "subjectAltName=IP:192.168.1.50"
```

Note that public CAs will not issue a certificate for a private IP address at
all — for an IP-only deployment you need an internal CA, or a self-signed
certificate (Option B).

**Some enterprise CAs want the full organisation detail** in the subject, and
will reject a bare CN. If yours does, the fuller form is:

```
  -subj "/C=US/ST=California/O=Example Corporation/CN=portsight.company.com"
```

Most CAs override the country, state and organisation fields from their own
records regardless of what you send, so the CN and SAN are the two that actually
determine what you get back.

> **`-addext` needs OpenSSL 1.1.1 or newer** (2018). If your `openssl version`
> is older, the flag is silently unavailable and you will need a config file
> instead — upgrade OpenSSL if you can, as the older releases are long
> unsupported.

This creates two files:
- `certs/key.pem` — your private key (**keep this secret**, do not send it to anyone, and do not email it)
- `certs/portsight.csr` — the CSR to send to your CA

**Check the CSR before you send it**, because a missing SAN is only discovered
weeks later when the certificate arrives and browsers refuse it:

```bash
openssl req -in certs/portsight.csr -noout -subject
openssl req -in certs/portsight.csr -noout -text | grep -A1 "Subject Alternative Name"
```

The second command must print the names you expect. If it prints nothing, the
`-addext` did not take — fix that before submitting.

**Step 2 — Submit the CSR to your CA:**

Send the `portsight.csr` file to your IT team or certificate authority. It is
plain text and safe to paste into a ticket or a web portal (`cat certs/portsight.csr`)
— it contains no secret. Send **only** the `.csr`; the `.pem` key stays on the
server.

They will return a signed certificate file (often called `cert.pem`,
`certificate.crt`, or similar), usually along with one or more intermediate
("chain") certificates.

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
# Linux / macOS — use the name users will actually type
mkdir -p certs
openssl req -x509 -newkey rsa:2048 -keyout certs/key.pem -out certs/cert.pem \
  -days 365 -nodes \
  -subj "/CN=portsight.company.com" \
  -addext "subjectAltName=DNS:portsight.company.com"

chmod 600 certs/key.pem
```

```powershell
# Windows (PowerShell) — requires OpenSSL installed, or use Git Bash
mkdir certs -Force
openssl req -x509 -newkey rsa:2048 -keyout certs/key.pem -out certs/cert.pem `
  -days 365 -nodes `
  -subj "/CN=portsight.company.com" `
  -addext "subjectAltName=DNS:portsight.company.com"
```

Include the `subjectAltName` here too. Without it some browsers refuse the
certificate outright rather than offering the usual "proceed anyway" option, so
a self-signed certificate missing a SAN can lock you out of your own install.
For access by IP address, use `-addext "subjectAltName=IP:192.168.1.50"` and the
matching CN.

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

### Renewing a certificate

Certificates expire. Port-Sight does not warn you about it — nothing inside the
application reads the certificate — so this is a calendar item you own.

**An expired certificate is not an outage.** Port-Sight keeps running and keeps
serving HTTPS; browsers show a "your connection is not private" warning that
users can click through, and the API still answers. So renew promptly, but you
are not working against a hard cut-off.

**Nothing below replaces the certificate in service until step 7**, and step 7
itself is reversible. The new key and certificate are written under new
filenames, so the pair currently working keeps working while you do everything
else.

#### Step 0 — set these four values

Every command in this section uses them, so you edit four lines here instead of
substituting into thirty commands below. Paste this block with your own values:

```bash
APP=/opt/port-sight                 # where Port-Sight is installed
FQDN=portsight.company.com          # the name users type in the browser
PORT=443                            # the HTTPS port Port-Sight serves on
INBOX=/tmp/cert-inbox               # scratch folder for the files the CA sends back
```

Check they took:

```bash
echo "$APP | $FQDN | $PORT | $INBOX"
```

**If you close the terminal or reconnect, run that block again** — shell
variables do not survive a new session, and every later step depends on them.
Every command below is written to be pasted as-is once these are set.

#### Step 1 — generate a new key and CSR

```bash
mkdir -p "$APP/certs"
cp -a "$APP/certs" "$APP/certs.bak-$(date +%F)"

openssl req -new -newkey rsa:2048 -nodes -keyout "$APP/certs/key-new.pem" -out "$APP/certs/request.csr" -subj "/CN=$FQDN" -addext "subjectAltName=DNS:$FQDN"

chmod 600 "$APP/certs/key-new.pem"
```

Most CAs overwrite country, state and organisation from their own records, so
CN and SAN are the two fields that matter. If your CA requires the full subject,
add it: `-subj "/C=US/ST=<state>/O=<organization>/CN=$FQDN"`.

**The SAN is the field browsers actually read.** They ignore the CN entirely and
reject a certificate whose SAN does not list the name being used. If users reach
the server by more than one name, list them all:

```bash
-addext "subjectAltName=DNS:$FQDN,DNS:www.$FQDN"
```

Check before sending:

```bash
openssl req -in "$APP/certs/request.csr" -noout -subject
openssl req -in "$APP/certs/request.csr" -noout -text | grep -A1 "Subject Alternative Name"
```

#### Step 2 — submit the CSR

Send the contents of `$APP/certs/request.csr` to whoever issues your
certificates — a portal, a ticket, an email:

```bash
cat "$APP/certs/request.csr"
```

It is plain text and safe to share: it holds your public key and your requested
names, nothing secret. **The private key never leaves the server.**

#### Step 3 — put the returned files somewhere the next steps can find them

```bash
mkdir -p "$INBOX"
chmod 777 "$INBOX"
```

Now transfer whatever the CA sent into that folder. Any method works — SFTP,
`scp`, or opening a file in an editor and pasting the text. Certificates are
public data, so no secure channel is needed.

`/tmp` is the default because **every account on the server can write to it**,
which matters if you connect over SFTP as yourself and become root afterwards —
you will not be able to write into the install directory as your own user. If
you would rather use your home directory, change `INBOX` in step 0.

Do not put private keys in `/tmp`; it is readable by every account on the host.
The key stays where step 1 wrote it.

Confirm the files arrived:

```bash
ls -l "$INBOX"
```

> **Do not `cat`, `more` or `less` these files to look at them.** Some are
> binary (DER), and printing binary to a terminal can leave it in a state where
> nothing renders. Step 4 reads them safely. If a terminal does go blank, type
> `reset` and press Enter even though you cannot see it.

#### Step 4 — identify what you were sent

**What comes back varies by CA.** You may get one file or five; extensions may
be `.pem`, `.crt`, `.cer` or `.txt`; the contents may be PEM text or DER binary,
sometimes both in the same delivery; a pre-assembled chain file may or may not
be included. **Do not go by the filenames** — a common trap is an intermediate
certificate with the word "Root" in its name.

This reads every file and reports only the ones that really are certificates:

```bash
cd "$INBOX" || echo "INBOX not set - re-run step 0"

found=0
for f in *; do
  [ -f "$f" ] || continue
  n=$(grep -c "BEGIN CERTIFICATE" "$f" 2>/dev/null)
  if [ "${n:-0}" -gt 0 ]; then
    found=1; echo "=== $f"; echo "    PEM, $n certificate(s):"
    openssl crl2pkcs7 -nocrl -certfile "$f" | openssl pkcs7 -print_certs -noout
  elif openssl x509 -in "$f" -inform DER -noout -subject >/dev/null 2>&1; then
    found=1; echo "=== $f"; echo "    DER (binary), 1 certificate:"
    openssl x509 -in "$f" -inform DER -noout -subject -issuer
  fi
done
[ "$found" = 0 ] && echo "NO CERTIFICATES in $(pwd) - are the files somewhere else?"
```

Read the output as a chain. Every certificate names its own `subject` and the
`issuer` that signed it, and that is what tells you the order:

- **Your server certificate** is the one whose subject CN is your FQDN.
- **The next link** is the certificate whose *subject* equals your server
  certificate's *issuer*. Repeat: each certificate's issuer points at the
  subject of the one above it.
- **The root** is the certificate whose subject and issuer are *identical*
  (self-signed). Leave it out — clients trust roots only from their own store,
  never from the wire. Including it is harmless, just dead weight in every
  handshake.
- **A file holding several certificates** is a pre-assembled chain. If its first
  certificate is your server certificate and the rest follow the order above,
  use that one file in step 5 and ignore the others.

There is no fixed number of intermediates — one or two is typical, more is
possible. Follow the issuer/subject links until you reach the self-signed one.

#### Step 5 — assemble the new certificate file

It must be your server certificate **first**, then each intermediate in chain
order. Order matters; many clients reject a chain that is out of order.

**If one file already holds the chain, leaf first:**

```bash
cp "$INBOX/<that file>" "$APP/certs/cert-new.pem"
```

**Otherwise concatenate them yourself**, server certificate first:

```bash
cd "$INBOX"
cat "<server-cert>" "<intermediate-1>" "<intermediate-2>" > "$APP/certs/cert-new.pem"
```

**If any of those were DER** (step 4 said so), convert before concatenating.
`cat` on a binary file produces a `cert-new.pem` that nginx will refuse to load:

```bash
openssl x509 -in "<file>" -inform DER -outform PEM -out "<file>.pem"
```

> The `<angle brackets>` above are the only placeholders left in this section,
> and they must be **replaced with real filenames**. Pasted as-is, the shell
> reads `<` as a redirection and reports a syntax error.

Check what you built:

```bash
echo "certificates in cert-new.pem: $(grep -c 'BEGIN CERTIFICATE' "$APP/certs/cert-new.pem")"
```

#### Step 6 — verify before installing

**The pair check.** This proves the certificate the CA issued belongs to the key
you generated in step 1 — the one failure that would take HTTPS down:

```bash
if c=$(openssl x509 -in "$APP/certs/cert-new.pem" -noout -modulus 2>/dev/null) &&
   k=$(openssl rsa  -in "$APP/certs/key-new.pem"  -noout -modulus 2>/dev/null) &&
   [ -n "$c" ] && [ "$c" = "$k" ]; then
  echo "MATCH - certificate and key belong together"
else
  echo "NO MATCH - stop here, do not install"
fi
```

`NO MATCH` means one of three things: the files are not where you think, the
certificate was issued against a different CSR, or the key is damaged. All three
are reasons to stop. Do not continue until this prints `MATCH`.

**Names and dates:**

```bash
openssl x509 -in "$APP/certs/cert-new.pem" -noout -dates -ext subjectAltName
```

The SAN must list the name people actually type, and `notAfter` should be the
lifetime you expect.

**Chain trust** (informational):

```bash
openssl verify -untrusted "$APP/certs/cert-new.pem" "$APP/certs/cert-new.pem"
```

`OK` is good. This checks against your server's trust store, so a private or
institutional CA can report `unable to get local issuer certificate` even when
the chain is perfectly fine — step 8 is the authoritative check, so a failure
here is not a reason to stop.

#### Step 7 — install

First find out how the container reads these files, because that decides the
permissions:

```bash
cd "$APP"
docker compose exec frontend id
ls -l certs/cert.pem certs/key.pem
```

- `uid=0(root)` — root-owned `600` on the key is correct. Use the commands below
  as written.
- **Any other user** — match whatever the *current working files* show in that
  `ls -l`. They are the proof of what this container can actually read.

**Do not tighten permissions as part of a renewal.** If it goes wrong you will
think the certificate is at fault. Make that a separate change on another day.

```bash
mv "$APP/certs/cert-new.pem" "$APP/certs/cert.pem"
mv "$APP/certs/key-new.pem"  "$APP/certs/key.pem"
chmod 644 "$APP/certs/cert.pem"
chmod 600 "$APP/certs/key.pem"      # only if the container runs as root
ls -l "$APP/certs/cert.pem" "$APP/certs/key.pem"
```

#### Step 8 — restart and verify from the socket

```bash
cd "$APP"
docker compose restart frontend
sleep 4

echo "=== what is actually being served ==="
echo | openssl s_client -connect "localhost:$PORT" -servername "$FQDN" 2>/dev/null | openssl x509 -noout -subject -issuer -dates

echo "=== the chain being served ==="
echo | openssl s_client -connect "localhost:$PORT" -servername "$FQDN" 2>/dev/null | grep -E "^ *[0-9]+ s:|Verify return code"
```

Reading the live socket rather than the file is what catches "I replaced the
file but the container is still serving the old one."

You want the new `notAfter`, **one `s:` line for each certificate you put into
`cert.pem`**, and `Verify return code: 0 (ok)`.

If only one `s:` line appears when you expected more, the intermediates did not
make it into the file — go back to step 5. A leaf-only chain still works in most
browsers, because they quietly fetch the missing intermediate themselves, while
`curl`, Java, Python, mobile apps and monitoring agents fail against it. That
makes it a bug you can easily ship without noticing.

#### Step 9 — check in a browser

Load the site by name and **force a reload** (`Ctrl+Shift+R`, or a private
window). Browsers cache TLS sessions and will happily show the old certificate
after the server has moved on. This is by far the most common reason a correct
renewal looks like it failed — check it before changing anything else.

If it still shows the old certificate after a hard refresh, see
[HTTPS not working](#https-not-working).

#### Step 10 — clean up

```bash
rm -rf "$INBOX"
```

Keep `$APP/certs.bak-<date>` for a week or two in case something surfaces later,
then delete it — it contains the old private key.

#### Rolling back

Step 1 took a copy. If anything is wrong you are two commands and a restart from
the pair that was working:

```bash
ls -d "$APP"/certs.bak-*                      # find the backup
BAK="$APP/certs.bak-YYYY-MM-DD"               # paste the one you want

cp "$BAK/cert.pem" "$APP/certs/cert.pem"
cp "$BAK/key.pem"  "$APP/certs/key.pem"
cd "$APP" && docker compose restart frontend
```

That returns you to the expired-but-working certificate, which is a warning page
rather than an outage.

#### Plan for this getting more frequent

Public certificate lifetimes are being stepped down industry-wide — roughly 200
days from March 2026, 100 days from March 2027, and 47 days from March 2029.
Twice a year by hand is tolerable; eight times a year is not, so it is worth
asking your CA whether they support **ACME** (the protocol certbot and acme.sh
speak). Commercial and higher-education CAs increasingly do; Sectigo-based
services, including InCommon, require an External Account Binding key pair that
your certificate administrator generates for you. Ask for those credentials
before a renewal, not during one.

**Nothing in Port-Sight changes if you automate it.** HTTPS is file-based: the
host's `certs/` folder is mounted read-only into the frontend container and
nginx reads `cert.pem` and `key.pem` from it. Any ACME client that can write
those two files works. The whole integration is a deploy hook:

```bash
cp "/etc/letsencrypt/live/$FQDN/fullchain.pem" "$APP/certs/cert.pem"
cp "/etc/letsencrypt/live/$FQDN/privkey.pem"   "$APP/certs/key.pem"
cd "$APP" && docker compose restart frontend
```

The one decision that needs making is how the CA proves you own the name.
**HTTP-01** needs the CA to reach the server on port 80 from the internet — awkward
here, since Port-Sight already serves that port and an internal tool is often not
reachable from outside. **DNS-01** proves it with a TXT record instead, needs no
inbound reachability, and is usually the right answer for an internally-hosted
server.

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
cd ~/port-sight              # or wherever you installed
./update.sh                  # Windows / Docker Desktop: .\update.ps1
```

`update.sh` pulls the current images for your channel, restarts the stack,
then removes the Port-Sight image versions that are no longer used. That last
step matters: Docker keeps every version you have ever pulled (about 0.5 GB
per release across the images) until something removes it, and a full
disk stops PostgreSQL cold - the database container goes `unhealthy` and the
app stops with `dependency db failed to start`. Only Port-Sight's own unused
images and untagged leftovers are removed; data volumes and other
applications' images are never touched.

**v2.13: adding the flow collector to an existing install.** If your local
`docker-compose.yml` doesn't have a `flow` service yet (any install from
before v2.13), `update.sh`/`update.ps1` add it automatically, before pulling,
so the new image is actually fetched. It backs up your current file first
(`docker-compose.yml.bak-YYYYMMDD`), adds the `flow` service block (port 2055,
or 2056 if your `docker-compose.yml` shows `PORT_SIGHT_CHANNEL: beta`), and
adds `FLOW_URL: http://flow:8085` to the backend service's environment if it
isn't already there. It prints one line saying what it added and reminds you
that the flow collector's UDP port needs to be reachable from your NetFlow
exporters (see "Flow Collector" above). Safe to run more than once — it
only adds what's actually missing.

**One-time step for installs made before v2.13.** The updater that adds
the `flow` service is itself new, and the copy already in your install
directory doesn't know to fetch it. Refresh it once by hand, then update as
usual — from then on `update.sh` refreshes itself from your channel (stable
installs from the releases root, beta installs from `beta/`) before it does
anything else, so this never needs repeating:

```bash
# stable install
curl -fsSL https://raw.githubusercontent.com/shunsing22/port-sight-releases/main/update.sh -o update.sh && chmod +x update.sh && ./update.sh
# beta install
curl -fsSL https://raw.githubusercontent.com/shunsing22/port-sight-releases/main/beta/update.sh -o update.sh && chmod +x update.sh && ./update.sh
```

Windows: download `update.ps1` from the same location (`beta/update.ps1`
for a beta install) over the existing file, then run `.\update.ps1`.

The long form, if you prefer to run the steps yourself:

```bash
docker compose pull && docker compose up -d && ./maintenance.sh run
```

### Daily maintenance job (Linux)

The installer (and every `./update.sh`) also installs a daily cron job,
`/etc/cron.d/port-sight-maintenance-<install dir>` (one per install, so a
production and a beta stack on one host each keep theirs), that runs the same
cleanup at 03:17 and
defragments the kernel's free memory so containers can always start (long
uptimes plus large deletes can leave the kernel unable to hand Docker the
contiguous memory a new container needs). It logs to
`/var/log/port-sight-maintenance.log`. Installing it needs root; if the
installer could not (no sudo), do it once:

```bash
sudo ./maintenance.sh install-cron "$PWD"
```

`sudo ./maintenance.sh remove-cron` removes it. Docker Desktop on Windows and
macOS has no cron; there, `update.ps1` / `update.sh` do the cleanup each time
you update. `Admin > System` shows the disk free on the Docker host and the app
warns admins when it drops under 10%.

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

### Collecting logs when the app is down

If the containers will not start, the app cannot produce its own support bundle. Use the host maintenance script instead; it needs only Docker, not a running Port-Sight:

```bash
./maintenance.sh collect-logs /opt/port-sight          # install directory (default: current directory)
./maintenance.sh collect-logs /opt/port-sight --out /tmp/ps-logs.zip --lines 5000
```

It writes `port-sight-host-logs-<UTC time>.zip` (a `.tgz` on a host with neither `zip` nor Python) and prints its path as the last line. The archive contains `README.txt`, `manifest.json` (time, install directory, channel, image tag), `compose-ps.txt` (container status), `logs/<service>.log` (the last 2,000 lines of each container, or `--lines N`), `compose.yml`, `env-keys.txt`, and `host.txt` (disk, memory, Docker and Compose versions).

What it does not contain: no `.env` values (only the setting names), and any compose-file line whose key contains password, secret, key or token has its value replaced by `<redacted>`. If a command fails, the error text is written into that member and the rest is still collected.

Send the archive to support@port-sight.com.

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

First check whether the certificate has simply expired (browsers say "not
private" but the site still loads):
```bash
openssl x509 -in certs/cert.pem -noout -dates
```
See [Renewing a certificate](#renewing-a-certificate) if `notAfter` is in the past.

Check that both cert files exist and are readable:
```bash
ls -la certs/
```
Check the frontend container logs for the entrypoint message:
```bash
docker compose logs frontend | head -5
```
You should see either `SSL certificates found` or `No SSL certificates found`.

#### The browser still shows the old certificate after a renewal

Work outwards from the container. First, what the server is actually serving:

```bash
echo | openssl s_client -connect localhost:443 -servername <fqdn> 2>/dev/null | openssl x509 -noout -subject -issuer -dates
```

**If that shows the new certificate**, the server is done and the difference is
further out:

```bash
ss -tlnp | grep ':443'                 # anything in front of the container on this host?
getent hosts <fqdn>                    # where does the name actually point?
hostname -I                            # is that this machine?
echo | openssl s_client -connect <fqdn>:443 -servername <fqdn> 2>/dev/null | openssl x509 -noout -dates
```

- Connecting **by name** also shows the new certificate: the server is correct
  and your **browser is caching**. Force a reload (`Ctrl+Shift+R`), use a
  private window, or quit the browser completely. This is the usual answer.
- The name resolves to an address that is **not** this host, or something other
  than the container is listening on 443: a reverse proxy or load balancer is
  terminating TLS, and the new certificate has to be installed **there** as
  well.
- The browser reports an **issuer you do not recognise** — not your CA: traffic
  is being TLS-inspected by a firewall or proxy, which re-signs with its own CA
  and may serve dates cached from before your renewal. Nothing to fix on the
  server; the inspecting device refreshes on its own or its administrator
  clears its cache.

**If the socket shows the old certificate**, the container did not pick up the
new files — confirm `cert.pem` really changed (`openssl x509 -in certs/cert.pem
-noout -dates`) and restart the frontend again.


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
