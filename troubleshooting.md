# Port-Sight — Troubleshooting Guide

A guide for server admins to diagnose common issues. Commands assume a Docker deployment unless noted otherwise.

---

## Quick Health Check

Run these commands on the server where Port-Sight is installed to quickly assess the state of things.

### 1. Are all containers running?

```bash
cd /opt/port-sight   # or wherever you installed
docker compose ps
```

You should see three containers — `db`, `backend`, and `frontend` — all with status **Up**. If any show `Restarting`, `Exit`, or are missing, that's the problem.

### 2. Is the backend API responding?

```bash
curl -s http://localhost:8000/health
```

Expected response: `{"status":"ok"}`

If the backend is behind nginx (default Docker setup), you can also test through the proxy:

```bash
curl -s http://localhost/api/health
```

If you get no response, `Connection refused`, or an HTML error page, the backend is not running or not reachable.

### 3. Is the database up?

```bash
docker compose exec db pg_isready
```

Expected: `accepting connections`. If not, the database container has a problem.

### 4. What version is running?

```bash
curl -s http://localhost:8000/version
```

Returns the app version and can confirm the backend is responsive.

---

## Common Problems

### "I see the login page but I've never created an account"

**What happened:** Port-Sight should show a setup wizard on first launch to create the admin account. If it shows the login form instead, the frontend couldn't reach the backend API to check if setup is needed.

**Fix:**

1. Check that all three containers are running: `docker compose ps`
2. Check backend logs: `docker compose logs backend --tail 50`
3. Look for errors like:
   - `Connection refused` — backend isn't running
   - `database connection failed` — check DATABASE_URL in `.env`
   - `ModuleNotFoundError` — corrupted image, try `docker compose pull && docker compose up -d`
4. Test the backend directly: `curl -s http://localhost:8000/health`
5. Once the backend is healthy, refresh the browser — you should be redirected to `/setup`

**Workaround:** Navigate directly to `http://your-server/setup` in your browser. If the backend is reachable, the setup wizard will appear.

### "Login page says: Unable to connect to the backend server"

The frontend is working, but it cannot reach the backend API.

1. **Check backend container:** `docker compose ps backend` — is it running?
2. **Check backend logs:** `docker compose logs backend --tail 50`
3. **Common causes:**
   - Backend crashed on startup (bad DATABASE_URL, missing env vars)
   - Database not ready yet (give it 10-15 seconds after `docker compose up`)
   - Port conflict (another service using port 8000 internally)

### "I can't access the web interface at all"

The browser can't reach the server.

1. **Check the frontend container:** `docker compose logs frontend --tail 20`
2. **Check which port is configured:**
   ```bash
   grep HTTP_PORT .env
   ```
   Default is port 80 (HTTP) and 443 (HTTPS).
3. **Is the port open?** From another machine:
   ```bash
   curl -s http://your-server-ip
   ```
4. **Firewall:** Ensure your server's firewall allows inbound traffic on the configured ports:
   ```bash
   # Ubuntu/Debian
   sudo ufw status

   # RHEL/CentOS
   sudo firewall-cmd --list-ports
   ```
5. **HTTPS without certificates:** If you configured HTTPS but haven't placed certificates in `certs/`, nginx won't start. Check `docker compose logs frontend` for certificate errors, or switch to HTTP by removing HTTPS port mapping.

### Reachable by SSH and ping, not by browser

The server answers ping, you can SSH to it, every container shows `Up`, but the browser cannot connect to Port-Sight (or PortCraft, or any other
Docker-published port on the same host). This is a host networking fault, not a Port-Sight fault, and it has a specific signature: traffic to the
host itself works, traffic forwarded into a container does not. It most often appears right after the VM moved to another hypervisor (VMware to
Hyper-V or Proxmox) or gained a second network adapter.

Work through these in order on the server. Every step either clears a cause or finds it.

1. **Is nginx alive?** `curl -sk -o /dev/null -w '%{http_code}\n' https://localhost/` should print `200` or `30x`. If not, the problem is the
   frontend container: see "I can't access the web interface at all" above. Note that a connection to `localhost` goes through Docker's userland
   proxy, so this step proves nginx is up and nothing more.

2. **Does TCP connect from a workstation?** Windows: `Test-NetConnection <server-ip> -Port 443`. Linux/macOS: `nc -vz <server-ip> 443`.
   `TcpTestSucceeded : False` (or "connection timed out") with ping working is the signature this section is about. If TCP connects but the page
   never loads, test frame size instead: `ping <server-ip> -f -l 1472` (Windows) or `ping -M do -s 1472 <server-ip>`; a failure there is an MTU
   problem on the virtual switch.

3. **Is Docker publishing the port and allowed to forward?**
   ```bash
   sudo ss -ltnp | grep -E ':(80|443) '          # dockerd listening on 0.0.0.0:443
   sudo iptables -t nat -S DOCKER | grep 443      # a DNAT rule into the frontend container
   sysctl net.ipv4.ip_forward                     # must be 1; ufw's /etc/ufw/sysctl.conf sets it to 0 by default
   sudo iptables -S FORWARD | head -3             # the DOCKER-USER / DOCKER-FORWARD jumps must be present
   ```
   If nothing listens, `docker compose up -d --force-recreate frontend`. If `ip_forward` is 0, `sudo sysctl -w net.ipv4.ip_forward=1` and make it
   permanent in `/etc/sysctl.d/99-docker.conf` (and in `/etc/ufw/sysctl.conf` when ufw is in use). If the Docker chains are missing from FORWARD,
   `sudo systemctl restart docker` rebuilds them.

4. **How many interfaces carry the address, and how many default routes are there?**
   ```bash
   ip -br address
   ip route show
   ```
   The healthy answer is one interface with the address and one `default via` line. Two interfaces with the same address, or two default routes,
   is the usual cause. It happens because Ubuntu's installer writes a netplan rule that matches interfaces by `name: "e*"`; on a VM with one
   adapter that is harmless, but a second adapter (a hypervisor migration often leaves one behind with the old MAC) receives the same address and
   gateway. Host services such as SSH survive because the kernel keeps the connection on the interface it arrived on; replies forwarded from a
   container are routed by the table, take the first default route, and die if that interface has no path to the gateway.

5. **Which interface can actually reach the gateway?** With the gateway address from `ip route show`:
   ```bash
   ip neigh show 192.0.2.1
   ```
   `REACHABLE` or `STALE` on one interface and `FAILED` or `INCOMPLETE` on another confirms it: the `FAILED` interface is attached to a dead or
   wrong virtual switch yet still owns a default route.

6. **Fix it now.** Bring the dead interface down. Your SSH session is on the live one and survives:
   ```bash
   sudo ip link set eth0 down        # the interface whose gateway neighbour is FAILED
   ip route show                     # one default route remains
   ```
   Test from the workstation again. It should connect.

7. **Make it permanent.** Pin the netplan configuration to the live adapter's MAC so a stray adapter gets nothing. Read the MAC with
   `ip link show eth1 | grep ether`, then edit the file in `/etc/netplan/` (often `50-cloud-init.yaml`): replace the `match:` block's
   `name: "e*"` with `macaddress: "00:15:5d:xx:xx:xx"` and leave the rest unchanged. If the file is named `50-cloud-init.yaml`, also stop cloud-init
   from rewriting it at boot:
   ```bash
   echo 'network: {config: disabled}' | sudo tee /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg
   sudo netplan apply
   ip -br address && ip route show   # one address, one default route
   ```
   Then have the VM's administrator remove the extra virtual adapter from the VM. If the old MAC must be kept (a DHCP reservation or a firewall
   rule keyed to it), set it statically on the one remaining adapter.

8. **Still unclear? Watch the packets.** Reload the browser while each capture runs:
   ```bash
   sudo timeout 20 tcpdump -ni eth1 'tcp port 443 and host <workstation-ip>'
   sudo timeout 20 tcpdump -ni br-xxxxxxxx 'tcp port 443'   # the bridge from `ip -br address` that holds 172.18.0.1, or whichever the frontend is on
   ```
   SYNs arriving on the interface and on the bridge, SYN-ACKs leaving the bridge but never appearing on the interface, means the reply is routed
   out the wrong way (step 4). SYNs that never reach the interface at all mean something between the router and the VM is filtering the port.
   Each frame appearing several times with an identical timestamp is a second adapter on the same virtual switch.

After a hypervisor migration also check the clock: see the deployment guide's **Server time** section. The same migration that leaves a second
adapter behind usually leaves the VM on the `tsc` clocksource with no time service.

The host log collection (`./maintenance.sh collect-logs`, below under Getting Help) records interfaces, routes, gateway reachability, clock source
and time sync. Support runs the diagnosis over that archive and it names these conditions directly, so send it rather than describing the output.

### Backend keeps restarting

```bash
docker compose logs backend --tail 100
```

**Common causes:**

| Error in logs | Fix |
|---|---|
| `asyncpg.InvalidPasswordError` | Wrong `POSTGRES_PASSWORD` in `.env` — must match between backend and db |
| `could not translate host name "db"` | The `db` container isn't running — check `docker compose ps` |
| `SECRET_KEY` / `CREDENTIAL_ENCRYPTION_KEY` missing | Run `python -c "import secrets; print(secrets.token_hex(32))"` and add to `.env` |
| `relation "users" does not exist` | Database is empty — this should auto-resolve on the next restart (tables auto-create). If persistent, check DATABASE_URL points to the right database |
| `null value in column "snmp_concurrency"` | Fixed in v1.5.1 — update to latest version |
| `value out of int64 range` during polling | A switch is returning corrupted SNMP counter values — fixed in v1.7.3 (values are now clamped). Update to latest version. |
| Poll stops partway through (e.g. 15/422) | Likely a hung SNMP response — fixed in v1.7.2 (120s per-switch timeout). Update to latest version. |
| Restore failed: `unrecognized configuration parameter "transaction_timeout"` | pg_dump client is newer than the PostgreSQL server. Fixed in v1.7.7+ (unknown SET parameters are automatically stripped during restore). Update to latest version. |

### "502 Bad Gateway" or "Connection refused" after an update

The frontend (nginx) can't reach the backend. This typically happens after `docker compose pull && docker compose up -d` when the backend container restarts with a new IP address but nginx still has the old IP cached.

**Fix:**

```bash
docker compose restart frontend
```

If that doesn't resolve it:

```bash
docker compose down && docker compose up -d
```

**Why it happens:** Docker may assign a new internal IP to the backend container during a restart. Nginx resolves the backend hostname once at startup. If nginx starts before the backend is ready, or if the backend's IP changes, nginx sends requests to the old address.

**Prevention:** This is a normal Docker behavior and resolves itself with a frontend restart. It is not a data-loss scenario — the database is unaffected.

### "dependency db failed to start" / database container unhealthy after an update

`docker compose logs db --tail 40` tells you why. If it repeats
`PANIC: could not write to file ... No space left on device`, the disk that
holds `/var/lib/docker` is full and PostgreSQL is looping in crash recovery.
Nothing is corrupt; it recovers by itself as soon as there is free space.

```bash
df -h /var/lib/docker
docker system df                 # "Images ... RECLAIMABLE" is usually the answer
docker image prune -af           # removes old version images only; volumes untouched
docker compose up -d
```

Every `docker compose pull` leaves the previous version's images behind;
update with `./update.sh` (it removes them) and let the daily maintenance job
run (see the deployment guide). If the volumes themselves are what grew,
`docker system df -v` shows the size per volume.

### "Cannot allocate memory" when a container starts, with RAM free

`runc create failed ... failed to unshare remaining namespaces: Cannot
allocate memory` while `free -m` shows plenty available means the kernel's
free memory is fragmented (long uptime plus a large delete). `dmesg | grep
"page allocation failure"` confirms it. Fix without a reboot:

```bash
sync
echo 3 > /proc/sys/vm/drop_caches
echo 1 > /proc/sys/vm/compact_memory
docker compose up -d
```

The daily maintenance job runs the compaction every night so this does not
build up.

### Database connection issues

```bash
# Check database container health
docker compose exec db pg_isready -U portsight

# Connect to the database directly
docker compose exec db psql -U portsight -d portsight -c "SELECT count(*) FROM users;"
```

If using an **external database** (Neon, on-prem PostgreSQL):
- Verify the `DATABASE_URL` in `.env` includes `?ssl=require` for cloud databases
- Test connectivity: `docker compose exec backend python -c "import asyncio, asyncpg; asyncio.run(asyncpg.connect('your-url'))"`

### SNMP polling not working

1. **Check poll logs:** Go to Admin > Polling in the UI, or:
   ```bash
   docker compose logs backend --tail 200 | grep -i "poll\|snmp"
   ```
2. **Timeouts / no response:** Verify the switch IP is reachable from the Docker container:
   ```bash
   docker compose exec backend python -c "import socket; socket.setdefaulttimeout(5); s=socket.socket(socket.AF_INET, socket.SOCK_DGRAM); s.connect(('SWITCH_IP', 161)); print('reachable')"
   ```
3. **Authentication errors:** Double-check SNMPv3 credentials or v2c community string on the switch management page. Credentials are encrypted — you can't view them, only re-enter.
4. **License expired:** Polling is blocked when the license expires. Check Admin > License for status.

### Backup / Restore fails

1. **"pg_dump not found"** — The backend container should include PostgreSQL client tools. If you're running locally (not Docker), install them:
   ```bash
   # Ubuntu/Debian
   sudo apt-get install postgresql-client

   # macOS
   brew install libpq
   ```
2. **Restore errors** — The restore process drops and recreates all tables. If it fails mid-way, the database may be in a bad state. Restore from an older backup or restart the backend (tables auto-recreate on startup, but data may be lost).
3. **Backup fails with 504 / "Backup failed"** — Backups and restores run as a background job and stream straight to/from disk (no request timeout, no in-memory dump), so this should no longer happen on current versions. If you still see it: upgrade to the version that runs backups in the background; check free disk space (Admin › System page, Disk tile — a backup needs roughly the compressed size of the database free); and check the backend log for a `pg_dump failed:` or `Restore failed:` line, which carries the actual reason (e.g. a disk-full error from pg_dump/psql itself). The Backups page polls and shows live progress ("Creating backup… N MB written") so you can watch it work rather than guessing whether it's stuck.
4. **"SFTP push failed"** (a backup row shows "Failed: ..." in its Push column, or Test Connection reports an error) —
   - **Authentication failed** — double-check host/port/username and, depending on auth mode, the password or private key. A password/key is write-only once saved (the page only shows whether one is "set"); re-enter it if unsure it's correct, then Test Connection again.
   - **Host key does not match the pinned key** — the remote server's SSH host key changed since the first successful connection (a rebuilt or re-imaged backup server, or — less innocently — a man-in-the-middle). If the change is expected, click **Reset Host Key** on the SFTP Push card, then Test Connection again to pin the new key. Every push is refused until this is done, by design.
   - **Remote directory does not exist / permission denied** — the configured remote directory must already exist and be writable by the SFTP account; Port-Sight does not create it for you beyond a best-effort `mkdir` (which silently no-ops if the account can't create directories — the actual upload failure is what's reported).
   - A failed push never fails the backup itself — the local file is always kept; use Download as a fallback, or **Push now** on that row once the SFTP issue is fixed.

### No flows arriving (Flow Collector card shows 0 exporters)

1. **Check the collector's own logs:**
   ```bash
   docker compose logs flow --tail 200
   ```
   Look for "First flow seen from exporter ..." lines — if none ever appear, nothing is reaching the container at all.
2. **Firewall** — confirm inbound UDP is allowed from each exporter to the Port-Sight host on the collector's port (2055 prod / 2056 beta by default, or whatever `FLOW_PORT` is set to in `.env`). Test from the exporter's own management network if possible; a stateful firewall rule for TCP won't cover UDP.
3. **Exporter destination** — double check the switch/router/firewall's NetFlow/IPFIX export configuration actually points at the Port-Sight host's real IP and the right port. A typo here (wrong IP, wrong port, or still pointed only at SolarWinds) is the most common cause.
4. **Subnets of interest** — even with flows arriving, the "Subnets of interest" count (Health tab summary, or the full table on Admin > Network > Flow Collector) comes from mapped links (see "Subnet discovery" in the admin guide); a flow that matches none of them is dropped immediately and never shows up anywhere (by design — that's the whole memory-bounding story). Zero subnets of interest usually means no maps have bound links yet, or neighbor/subnet discovery hasn't run.

### Exporter sends but never appears (v2.13.1)

Firewall and exporter config both look right — `tcpdump` on the host shows UDP packets arriving on the collector's port — but the device never shows up in the Exporters table, and nothing for it ever appears in Top Talkers.

1. **Check Admin > Network > Flow Collector for a "Packets arriving, waiting for a template" info card.** If the address is listed there, this isn't a networking problem at all: NetFlow v9 and IPFIX both require the exporting device to send a *template* describing its record layout before goflow2 can decode a single record, and that template hasn't arrived yet. (NetFlow v5 and sFlow are self-describing and never hit this.)
2. **The most common cause by far is a Cisco FTD** — its default template resend interval is 30 minutes, and every time the `flow` container restarts (an update, a host reboot, the container crashing) it starts over with zero templates. A device can sit "waiting" for up to half an hour after any such restart, purely waiting for its next scheduled resend. Fix: set the device's template timeout to 1 minute — see the Cisco FTD entry in the admin guide's "Flow collector" chapter (section 14) for the exact FMC/FlexConfig steps. Once applied, a waiting address clears itself from the card automatically within a minute or two, with nothing to click on this page.
3. **Running FTD in an HA pair?** Both members export independently and each needs the template-timeout setting applied — the card lists them separately, by address.
4. **Not listed on the card, but still never appears?** That's a different problem — go back to "No flows arriving" above (wrong destination IP/port, a firewall rule that's TCP-only, or nothing reaching the host at all).

### Exporter shows as a Docker gateway address (172.x.x.1) instead of the real device

Admin > Network > Flow Collector's Exporters table shows a warning card and a row with an address like `172.18.0.1` — that's a Docker bridge network gateway, not anything on your network.

1. **Cause** — Docker's userland proxy rewrote the incoming UDP datagram's source address to the bridge gateway before it reached the collector, so that's the only address the collector ever saw.
2. **Fix** — on the Port-Sight host: add `{"userland-proxy": false}` to `/etc/docker/daemon.json`, then `systemctl restart docker` (every container on the host restarts once — not just Port-Sight's). Confirm everything came back with `docker compose ps` in each install directory on the host. Apply this **before** pointing exporters at the host when you can — see the next entry if you've already applied it with exporters already sending.
3. **After the fix**, the real exporter address appears as its own row within about two minutes. Delete the stale `172.x.x.1` row from the Exporters table (each row has a delete action) — it won't come back on its own once the fix is in place, because the scheduler only recreates a deleted row once the collector shows genuinely fresh activity for that address.
4. See "Exporter shows as the Docker gateway" in the admin guide's "Flow collector" chapter (section 14) for the full explanation of why this is a safe, standard Docker daemon setting.

### Flows stopped after a Docker restart

You set `{"userland-proxy": false}` in `/etc/docker/daemon.json` and restarted Docker (see above), but instead of the real exporter address appearing, flows stopped arriving entirely — Admin > Network > Flow Collector shows a "Flows have stopped arriving" warning card, or the Exporters table just stops updating (Last seen keeps getting older).

1. **Cause** — the exporter sends a continuous UDP stream, and the Linux kernel's connection-tracking ("conntrack") table kept an entry for it that survived the Docker daemon restart, still pointing at the old (userland-proxy) delivery path. The `userland-proxy` setting change itself is correct; it's the stale kernel entry, not the setting, that's the problem.
2. **Fix** — on the Port-Sight host, as root:
   ```bash
   apt-get install -y conntrack
   conntrack -D -p udp --dport 2055
   ```
   Replace `2055` with your `FLOW_PORT` if you changed it from the default (`2056` on a beta install alongside production). The command prints how many entries it deleted — zero is harmless (means nothing stale was left).
3. Within about two minutes of the next flow packet, the real exporter address appears as a new row on Admin > Network > Flow Collector.
4. See "Exporter shows as the Docker gateway" → "If exporters were already sending when you changed it" in the admin guide's "Flow collector" chapter (section 14) for the full explanation.

### NetFlow byte counts look about double

Top Talkers reports far more traffic than you believe a link carries, and the numbers are suspiciously close to twice what you expect.

The usual cause is a device exporting the same traffic twice, once on ingress and once on egress. Port-Sight sums every record an exporter sends for a conversation and deliberately keeps no interface dimension (that is what bounds the collector's memory), so two records for one packet become double the bytes and packets. Rankings are unaffected; volumes are doubled.

**As of v2.13.15, Port-Sight detects this by itself.** Open Admin > Network > Flow Collector: if a warning card headed "NetFlow is reporting more traffic than the wire can carry" is at the top of the page, this is exactly what is happening, and the card names the exporter, roughly how far over it is ("about 2.1x") and which mapped links it was measured on. The check compares each mapped link's NetFlow bytes against that link's own SNMP interface counters over the same recent 15-minute window, both directions summed on each side; the watched subnets behind a link are always only part of what crosses it, so NetFlow above the wire is physically impossible and can only mean multi-counting. It is computed on demand when the page is opened (and refreshed once a minute while it is open), so there is nothing to enable. If there is no card, the comparison found nothing wrong where it could measure: the **NetFlow vs wire** column in the Exporters table shows each exporter's highest measured ratio (below 1 is healthy), and a dash there means that exporter's links could not be compared at all -- hover it for the reason, usually too little traffic, no interface samples for the link, or the exporter not being matched to one of the link's own switches.

**Confirm it two ways by hand, neither of which needs the device's CLI:**

1. Compare Top Talkers' byte rate for the link against that link's own utilisation graph. Port-Sight builds that graph from SNMP interface counters, so it is completely independent of NetFlow. Roughly 2x means yes.
2. Look at the **Flows** column for one busy conversation. Over a 15-minute window with a 60-second active timeout it should be about 15. About 30 means two records a minute for the same traffic.

**The fix is on the exporter, not in Port-Sight** — see "Export ingress only" in the admin guide's "Flow collector" chapter (section 14) for how to find it on a Catalyst 9000 and how to remove just the Port-Sight exporter from the egress monitor without disturbing an existing collector.

### A firewall's top talkers list conversations but zero bytes

The Top Talkers table shows real source and destination pairs with real ports and a non-zero flow count, but every row reads 0 bytes and 0 packets, and that exporter is labelled "no traffic" in the exporter dropdown.

Cisco ASA/FTD NSEL templates do not carry the standard octet and packet fields at all — the counts arrive in NSEL-specific information elements, and the collector has to fall back to them. Releases before v2.13.13 gated that fallback on a firewall event type read from the wrong element id, so the fallback never fired and every NSEL flow was recorded with zero bytes. Fixed in v2.13.13, where the fallback no longer depends on the event type at all. Update, then allow a minute or two for the firewall to resend its templates after the collector restarts (see "Packets arriving, waiting for a template" above — and set the device's template timeout to 1 minute if you have not already).

Packet counts specifically depend on your firewall's template including the initiator and responder packet elements. If it does not, packets stay at zero while byte counts work correctly; byte counts are what Top Talkers ranks on, so that is cosmetic.

### Collector unreachable (Flow Collector card shows "Unreachable")

As of v2.13.4, the Status card (and the "NetFlow is off" checklist's first item, if NetFlow is off) names *why* it's unreachable instead of a bare "Unreachable" badge — the text shown is the backend's `unreachable_hint`, keyed by `unreachable_reason`. The three reasons map to different fixes:

1. **`dns`** — the flow container isn't on Port-Sight's network, or isn't running at all. This is expected on any install from before v2.13 that hasn't run the updater yet. On the host:
   ```bash
   docker compose ps flow
   docker compose up -d --force-recreate flow
   ```
   Installs from before v2.13: run `./update.sh` (or `.\update.ps1` on Windows) once first — it adds the `flow` service to your `docker-compose.yml` and pulls the image. See "Updating Port-Sight" above.

   **Container without a network or published port** (seen on production, 2026-10-01): occasionally `docker compose up -d` recreates the `flow` container without actually attaching it to the compose network (racing a network recreate) — `docker compose ps flow` shows it `Up`, but `unreachable_reason` stays `dns` because nothing can reach it. `update.sh` now checks for exactly this after `up -d` (the container has a network, and its port is published) and force-recreates it once automatically if not; running it by hand is the same `docker compose up -d --force-recreate flow` command above.
2. **`refused`** — the container is running and on the network, but nothing is listening on its port yet (it takes a few seconds to start after a restart — normal, wait and re-check) or it has crashed:
   ```bash
   docker compose logs flow --tail 20
   ```
3. **`timeout`** — the collector didn't answer its own status call within the backend's 2-second budget, almost always because it's busy decoding a flood of flows. Not itself a failure — the memory and rate figures reappear as soon as it answers. See "Restarting repeatedly" below if this keeps recurring.
4. **Toggled off** — new installs start with NetFlow off by default (v2.13.4); the Flow Collector page shows a "NetFlow is off" card with a prerequisites checklist instead of the Status card above — expected, not a bug, until an admin flips the **Enable** switch. An install that already had it on before v2.13.4 keeps its own setting across the upgrade. Either way, check Admin > Network > Flow Collector's **Enable**/"Enabled" switch; while off, the backend stops pushing subnets (the container can still be running, just idle).
5. **Restarting repeatedly / "unreachable" that keeps coming back** — check for `goflow2 exited (code=-9)` in `docker compose logs flow`. Code -9 is the kernel's OOM killer: a very high flow rate with a lot of subnets of interest can outgrow the container's memory limit. A memory guard sheds detail (fewer conversations kept per minute) before that point — `GET /status`'s `memory` block, and the Flow Collector page's Memory row, report `shedding: true` while it is actively doing so, which is expected behaviour rather than a bug. **On releases before v2.13.13 that guard could not see the problem it exists to prevent:** it measured only the Python aggregator's own memory, not the container's, while goflow2 — a separate process in the same container, and the one whose output queue actually grows under load — was invisible to it. The symptom was a collector reporting a couple of hundred MB with `shedding: false` while `docker stats` showed it at its ceiling and goflow2 was being killed in a loop. Update to v2.13.13 or later, where the guard reads the container's own cgroup usage and the Memory row shows the same figure `docker stats` does. Beyond that, in order of leverage: prune the subnets you actually watch (see "Sizing" in the admin guide's "Flow collector" chapter, section 14); reduce what the exporters send, with a NetFlow traffic filter on a firewall or a sampler on a large core; or raise `FLOW_MEM_LIMIT` / `FLOW_CPUS` in `.env` (the shipped defaults became 2 GB and 2 cores in v2.13.13). Note that CPU, not memory, is usually what runs out first.
6. This is never a reason the rest of Port-Sight stops working — polling, reports, and the map viewer all function normally with the flow collector absent or unreachable.

### Every page is slow and the backend container sits at 100% CPU

Check `docker stats --no-stream` on the host. If `backend` is pinned at ~100% while `db` and `flow` are idle, something is asking the backend to do heavy work on a loop. On releases before **v2.14.4** the known cause was the Flow Collector page: it recomputed the NetFlow-vs-wire check on every one of its 60-second polls, per open browser, and two browsers left on that page (one of them a workstation nobody was looking at) kept a 451-switch production backend busy for an afternoon — every other page waited, and the collector started reporting as unreachable because the backend could not answer it within its 5-second budget. Closing the page cleared it within a minute. From v2.14.4 the check runs on a 5-minute backend schedule and the page serves the stored result, so the number of open browsers no longer matters. If you see this on a later release: `docker compose logs --tail 200 backend` shows which requests are arriving in a loop and from which address.

### Top talkers shows nothing

The map's Top Talkers panel (a link's glyph, or a NetFlow icon) can come up empty for several different reasons — work through these in order:

1. **Is the glyph/icon even there?** A link only gets a Top Talkers glyph when it has at least one subnet behind it (see "Subnet discovery" above) AND the flow collector is enabled fleet-wide. No subnet behind the link, or the feature toggled off, means no glyph — that's expected, not a bug.
2. **"The flow collector is not reachable"** — the collector container itself is down; see "Collector unreachable" above.
3. **"No flows for this subnet in the last 15 minutes"** — the collector is up, but nothing arrived for this specific subnet in the window. Check, in order:
   - **Is this subnet actually in the collector's watch list?** Admin > Network > Flow Collector's "Subnets of interest" table — if the CIDR isn't listed there, the collector was never told to track it and nothing you do on the exporter side will help. Run **Poll Hardware** so subnet/neighbor discovery has fresh data, then wait up to a minute for the next 60-second push.
   - **Is any exporter actually sending flow data at all?** Admin > Network > Flow Collector's Exporters table — if it's empty, see "No flows arriving" above.
   - **Is the RIGHT exporter selected?** A subnet is often visible to more than one exporter (a core and a firewall both see crossing traffic) but each shows its OWN view — one exporter's window can be empty while another's has data. Try the exporter selector in the panel (shown when more than one exporter has data for that subnet).
   - **Timing** — the window lags "now" by about a minute (exporters batch their own records before sending); a burst of traffic in the last few seconds may not have arrived yet.
4. **A subnet that used to work now shows nothing** — check whether the underlying map link or NetFlow icon's derived subnet changed (a topology change, a new override in the map editor's Subnets panel, or a switch that stopped answering SNMP) rather than assuming the collector itself broke.

### No link events

Reports > Link Events is empty, or a link you'd expect to have fired one doesn't. Remember there is **no alerting** built on this feature by design — it never notifies you, so "no events" can simply mean "nothing has crossed a threshold yet," not that something is broken.

1. **Check the filters first** — the date range defaults to the last 24 hours; widen it (7 days / 30 days / a custom range) before assuming nothing has happened.
2. **Band crossed events** need a mapped link to actually rise into the configured minimum band (Admin > App Settings > "Link Events" > "Minimum band that records an event", default **orange**). Lower it to `yellow` temporarily if you want to confirm the mechanism is working on a link that never gets very hot.
3. **Above normal events are silent for an interface's first four weeks.** They fire only from the hour-of-week "normal" profile, and a slot needs four weeks of samples before it is trusted — a fresh install, or a link just added to a map, raises none of these for a month even if it's genuinely busy, by design (there is deliberately no fallback to the 30-day high-water mark, which is now a chart reference only). Check `GET /capacity-trends/interfaces/{id}/profile` — `in_weeks` / `out_weeks` below `min_weeks` means still learning — or the "normal range learning: N of 4 weeks" note on that interface's chart. Once trusted, a reading must also clear the floor, **25% of the link's capacity** by default (Admin > App Settings > "Link Events") — a 10 Gb/s link running at 4% never fires however far over its normal that is — and a link with no known capacity never fires at all.
4. **Restarted recently?** The in-memory "last known band" the band-crossed trigger compares against is empty right after a backend restart — the first poll cycle after a restart never fires a false event for a link that was already hot before Port-Sight was watching it again (the same "prime the cache, don't fire" behavior the map-link poller itself already uses). A genuinely rising link will fire again on its next real crossing.

### Snapshot says "no flows" / "collector unreachable" / "no subnets"

A link event recorded fine, but its stored top-talkers snapshot has nothing to show:

1. **"collector unreachable"** — the flow collector container was down or unreachable at the exact moment the event fired. This is a point-in-time fact about that one event, independent of whether the collector is reachable now — see "Collector unreachable" above if it's still down.
2. **"no flows"** — the collector was reachable, but had no data for this link's subnets in the 15 minutes before the event. Work through "Top talkers shows nothing" above (wrong exporter selected, subnet not in the watch list, timing lag) using the event's own `occurred_at` time as the window to reason about.
3. **"no subnets"** — this link has no subnets derived behind it at all (see "Subnet discovery" in the admin guide), so there was nothing to ask the collector about. Adding an explicit override in the map editor's Subnets panel fixes this going forward; it can't retroactively fill in a past event's snapshot.

### A device shows "down" on Reports > Availability but it is up

Availability measures **reachability from the Port-Sight server by SNMP**, with a single one-OID request (`sysUpTime`) and a **3-second timeout, no retries**. A device that is running but does not answer that request in time is "down" here.

1. **Can the backend reach it at all?** From the backend container: `docker compose exec backend python -c "import socket; print(socket.create_connection(('<ip>', 22), 3) and 'tcp ok')"` for a quick path check, then the regular poll's own result for that switch on Admin > Polling (if the 4-hour poll also fails, this is a reachability or credential problem, not a heartbeat one).
2. **An ACL or firewall between the server and the switch** that rate-limits or drops UDP 161 shows up here first, because the heartbeat asks every switch every 5 minutes. Look for devices that flap down/up a few times a day with no reboot — a timeout, not an outage.
3. **A slow control plane** (a core under load, an old supervisor) can take longer than 3 seconds to answer SNMP. The heartbeat deliberately does not retry; if one device is consistently slow, its availability will understate. The 4-hour poll uses a 10-second timeout with one retry and will still succeed.
4. **Credentials changed on the switch** but not in Port-Sight: the device is "down" from the first failed check and stays down; fix the credentials on Admin > Switch Management and it comes back on the next heartbeat.
5. **A device that never answered** since it was added is down from its first check — the device page's first outage says "the first check after it was added already failed".

### Availability shows a wide range (hours between best and worst)

The two numbers are the best and worst cases the checks can support. A range that is **hours** wide means the only checks around that outage were the 4-hour polls.

1. **Is the heartbeat on?** Admin > Settings > Availability > "Heartbeat every" — 0 means off, and the report's note says so. With it on at the default 5 minutes, new outages are bounded to minutes.
2. **Is this an old outage?** Everything replayed from past poll results on day one (the device page says "past 4-hour polls, replayed on day one") carries the 4-hour poll's hours-wide bounds; that cannot be narrowed after the fact.
3. **Was the backend down?** No checks run while Port-Sight itself is stopped or restarting; an outage that spans that gap has its bounds set by the last check before and the first after. A device whose uptime is *longer* than the gap is known to have stayed up through it.
4. **A reboot narrows the range to the second** — the end is pinned by `sysUpTime`. If a device genuinely reloaded and the outage still shows a wide end, the reload happened *before* the first failed check (the agent was not yet answering); the start is then pinned instead.

---

## Checking Logs

### Docker deployment

The backend also keeps a rotating copy of its own log on the backups volume (`/app/backups/logs/backend.log`, 5 MB x 3), which is what the support bundle reads:

```bash
docker compose exec backend tail -n 200 /app/backups/logs/backend.log
```

```bash
# All services
docker compose logs --tail 100

# Specific service
docker compose logs backend --tail 100
docker compose logs frontend --tail 50
docker compose logs db --tail 50

# Follow logs in real-time
docker compose logs -f backend
```

### What to look for

- **Backend startup:** Look for `Uvicorn running on http://0.0.0.0:8000` — this means the backend started successfully
- **Database migrations:** `Running migrations...` followed by `Migrations complete` on first startup
- **Poll results:** `Poll complete for switch_name: X interfaces updated`
- **Errors:** Any line with `ERROR`, `Exception`, `Traceback`, or `Failed`

---

## Restarting Services

```bash
# Restart everything
docker compose restart

# Restart just the backend (e.g., after config change)
docker compose restart backend

# Full stop and start (if restart doesn't fix it)
docker compose down && docker compose up -d

# Pull latest images and restart
docker compose pull && docker compose up -d
```

**Note:** `docker compose down` stops containers but preserves your data (database and backups are in Docker volumes). Only `docker compose down -v` would delete volumes — **never run this unless you want to wipe everything.**

---

## Uninstalling / Clean Reinstall

Use this to completely remove Port-Sight from a server — for example, to test a fresh install or to decommission the server.

⚠️ This permanently deletes all data. Do not proceed on a production instance unless you have a backup or don't need the data.

### Step 1 — Find the install directory

**Linux / macOS:**
```bash
docker inspect port-sight-db-1 | grep "working_dir"
```

**Windows (PowerShell):**
```powershell
docker inspect port-sight-db-1 | Select-String "working_dir"
```

### Step 2 — Stop and remove everything

**Linux / macOS:**
```bash
cd /path/to/install/dir
docker compose down -v
```

**Windows (PowerShell):**
```powershell
cd C:\path\to\install\dir
docker compose down -v
```

### Step 3 — Remove the install directory

**Linux / macOS:**
```bash
cd ~
rm -rf /path/to/install/dir
```

**Windows (PowerShell):**
```powershell
cd $env:USERPROFILE
Remove-Item -Recurse -Force C:\path\to\install\dir
```

### Step 4 (optional) — Remove pulled Docker images

```bash
docker rmi ghcr.io/shunsing22/port-sight/backend:latest
docker rmi ghcr.io/shunsing22/port-sight/frontend:latest
```

This forces Docker to pull fresh images on the next install instead of using a cached version.

### Step 5 — Reinstall

**Linux / macOS:**
```bash
curl -fsSL https://raw.githubusercontent.com/shunsing22/port-sight-releases/main/install.sh | bash
```

**Windows (PowerShell — run as Administrator):**
```powershell
irm https://raw.githubusercontent.com/shunsing22/port-sight-releases/main/install.ps1 | iex
```

---

## Getting Help

If you're still stuck:

1. In the web UI: the assistant's **Send a bug report** emails a redacted support bundle to support with you copied, or Admin > System > Health >
   **Create support bundle** downloads it. The bundle holds versions, health figures, settings without secrets, recent polls, switch and collector
   state, the diagnosis findings, the backend log, and the host's network and clock facts as of the last daily maintenance run.
2. If the UI is down or unreachable: over SSH, from the install folder, `./maintenance.sh collect-logs --send`. It needs only Docker. It gathers
   the host's facts and container logs, adds the application's own bundle when the backend is running, and emails the one archive to support
   through the app's SMTP settings. If it cannot send, it prints the reason and the `scp` command to copy the archive to your computer so you can
   email it yourself. The archive also appears in Admin > System > Support archives, where you can send it later once the UI works
   again, download it, or delete it. Details in the deployment guide, "Collecting a support archive from the command line".
3. Note the version: `curl -s http://localhost:8000/version`
4. Contact support@port-sight.com with the archive if it was not sent automatically.

## Maps page says "Could not load maps"

Your maps are not gone. The list page shows this when the server failed to
compute map status; before v2.14.32 the same failure showed "No maps yet",
which is why it looked like data loss. Check the backend log:

```bash
docker compose logs --since 2h backend 2>&1 | grep -B 3 -A 30 "network_maps.py" | tail -60
```

One known cause (fixed in v2.14.32): a switch that has never polled
successfully has no name yet, and if it was bound to a map while its poll
was failing, every maps request failed. Giving the switch working
credentials, unbinding it, or deleting it clears the condition at once.

## "Maintenance windows: removing N tag assignment(s) for switches that no longer exist"

Informational. A switch was deleted while it still carried the maintenance
tag; from v2.14.32 the minute job removes the leftover tag row and says so
once. Before v2.14.32 the same situation made the job fail every minute with
a foreign-key error and nothing ever reconciled.
