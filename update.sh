#!/usr/bin/env bash
# Port-Sight updater. Run from the install directory (or by full path):
#
#   ./update.sh
#
# Pulls the current images for the channel configured in .env
# (PORT_SIGHT_VERSION: latest, beta, or a pinned number), restarts the
# stack, then removes the image versions that are no longer used -- every
# release left behind by a plain "docker compose pull" is half a gigabyte
# that stays on disk forever, and a full disk stops PostgreSQL cold.
# Also (re)installs the daily maintenance job when it can (Linux, sudo).
set -eu

RELEASES_URL="https://raw.githubusercontent.com/shunsing22/port-sight-releases/main"
INSTALL_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$INSTALL_DIR"

if [ ! -f docker-compose.yml ] || [ ! -f .env ]; then
  echo "Run this from your Port-Sight install directory (docker-compose.yml and .env not found in $INSTALL_DIR)." >&2
  exit 1
fi

# -- Channel + self-refresh (v2.13.0-beta.5) -------------------------------
# A beta install (PORT_SIGHT_VERSION=beta in .env, or a beta compose file)
# takes its scripts from the beta/ folder of the releases repo; a stable
# install from the root. Before doing anything else, fetch this script's
# own current copy for the channel and, if it differs, replace ourselves
# and re-run once -- so a release that changes what the updater must do
# (a new container, a compose edit) never depends on the copy that
# happened to be on disk. Best effort: no network, no change.
CHANNEL="stable"
if grep -qE '^PORT_SIGHT_VERSION=.*beta' .env 2>/dev/null || grep -q 'PORT_SIGHT_CHANNEL: beta' docker-compose.yml 2>/dev/null; then
  CHANNEL="beta"
fi
if [ "$CHANNEL" = "beta" ]; then
  SCRIPTS_URL="$RELEASES_URL/beta"
else
  SCRIPTS_URL="$RELEASES_URL"
fi
if [ "${PORT_SIGHT_UPDATER_REFRESHED:-0}" != "1" ] && command -v curl >/dev/null 2>&1; then
  if curl -fsSL "$SCRIPTS_URL/update.sh" -o update.sh.new 2>/dev/null && [ -s update.sh.new ] \
     && head -1 update.sh.new | grep -q 'bash' && ! cmp -s update.sh.new "$0"; then
    chmod +x update.sh.new
    mv update.sh.new update.sh
    echo "Updater refreshed from the $CHANNEL channel; re-running."
    PORT_SIGHT_UPDATER_REFRESHED=1 exec ./update.sh "$@"
  fi
  rm -f update.sh.new
fi

# -- Flow collector (v2.13 WP N2) --------------------------------
# Existing installs have a local docker-compose.yml copied at install time
# (install.sh/.ps1 download it once; it is never re-downloaded by update.sh)
# -- so a fresh v2.13 release needs to ADD the flow service to whatever is
# already there, idempotently, before pulling (otherwise the pull below
# never fetches the flow image at all). Two independent checks so re-running
# this on an already-updated file is a safe no-op either way.
add_flow_collector() {
  local compose_file="docker-compose.yml"
  local need_service=1 need_url=1
  grep -q 'port-sight/flow' "$compose_file" && need_service=0
  grep -q 'FLOW_URL' "$compose_file" && need_url=0
  if [ "$need_service" -eq 0 ] && [ "$need_url" -eq 0 ]; then
    return 0
  fi

  local port_default="2055" tag_default="latest"
  if grep -q 'PORT_SIGHT_CHANNEL: beta' "$compose_file"; then
    port_default="2056"
    tag_default="beta"
  fi

  cp "$compose_file" "$compose_file.bak-$(date -u +%Y%m%d)"

  local flow_block
  flow_block="  # NetFlow/IPFIX/sFlow collector (v2.13 WP N2) -- decodes flows in\n"
  flow_block+="  # memory only, never writes to disk or the database. Not a\n"
  flow_block+="  # depends_on of backend: the app must start and run normally\n"
  flow_block+="  # when this container is absent. Added by update.sh.\n"
  flow_block+="  flow:\n"
  flow_block+="    image: ghcr.io/shunsing22/port-sight/flow:\${PORT_SIGHT_VERSION:-$tag_default}\n"
  flow_block+="    restart: unless-stopped\n"
  flow_block+="    ports:\n"
  flow_block+="      - \"\${FLOW_PORT:-$port_default}:2055/udp\"\n"
  flow_block+="    environment:\n"
  flow_block+="      PORT_SIGHT_VERSION: \${PORT_SIGHT_VERSION:-$tag_default}\n"
  flow_block+="    mem_limit: \${FLOW_MEM_LIMIT:-2g}\n"
  flow_block+="    cpus: \${FLOW_CPUS:-2.0}\n"

  awk \
    -v add_service="$need_service" \
    -v add_url="$need_url" \
    -v flow_block="$flow_block" '
    BEGIN { in_backend = 0; in_env = 0; env_done = 0; flow_inserted = 0 }
    {
      line = $0
      if (line ~ /^  [A-Za-z_][A-Za-z0-9_]*:/) {
        in_backend = (line == "  backend:") ? 1 : 0
        in_env = 0
      }
      if (add_url == 1 && in_backend == 1 && line ~ /^    environment:/) {
        in_env = 1
        print line
        next
      }
      if (add_url == 1 && in_env == 1) {
        if (line ~ /^      [A-Za-z_]/) {
          print line
          next
        }
        if (env_done == 0) {
          print "      FLOW_URL: http://flow:8085"
          env_done = 1
        }
        in_env = 0
      }
      if (add_service == 1 && flow_inserted == 0 && line == "volumes:") {
        print flow_block
        flow_inserted = 1
      }
      print line
    }
    END {
      if (add_url == 1 && in_env == 1 && env_done == 0) {
        print "      FLOW_URL: http://flow:8085"
      }
      if (add_service == 1 && flow_inserted == 0) {
        print flow_block
      }
    }
  ' "$compose_file" > "$compose_file.new"

  if [ -s "$compose_file.new" ]; then
    mv "$compose_file.new" "$compose_file"
  else
    echo "  WARNING: flow-collector insertion produced an empty file; left docker-compose.yml unchanged." >&2
    rm -f "$compose_file.new"
    return 1
  fi

  if [ "$need_service" -eq 1 ]; then
    echo "  Added the flow collector service to docker-compose.yml (UDP port ${port_default}; backup: $compose_file.bak-$(date -u +%Y%m%d))."
    echo "  Make sure UDP $port_default is reachable from your NetFlow/IPFIX/sFlow exporters."
  fi
  if [ "$need_url" -eq 1 ]; then
    echo "  Added FLOW_URL to the backend service's environment in docker-compose.yml."
  fi
}
add_flow_collector || true

# The flow service's resource budget has been raised twice as real exporter
# loads came in: 512m -> 1g in v2.13.0-beta.11 (one unsampled campus core at
# ~6k flows/s), then 1g/1.0 core -> 2g/2.0 in v2.13.13. The second raise
# came from the owner's production box running a Catalyst 9606 plus two FTDs:
# CPU pegged at 110% of the one-core cap, goflow2's output queue grew until
# the container hit 1 GiB, and the kernel OOM-killed goflow2 ("exited
# (code=-9)"), losing every NetFlow v9 template and restarting in a loop.
# An install whose compose file was written by an earlier updater still
# carries the old literals -- raise them in place, only inside the flow
# service block, and only when they are still at a value WE wrote (an admin
# who has tuned these by hand keeps their own values).
if grep -q 'port-sight/flow' docker-compose.yml; then
  flow_block_now="$(sed -n '/^  flow:/,/^  [a-z]/p' docker-compose.yml)"
  if echo "$flow_block_now" | grep -q 'mem_limit: 512m'; then
    sed -i '/^  flow:/,/^  [a-z]/ s/mem_limit: 512m/mem_limit: ${FLOW_MEM_LIMIT:-2g}/' docker-compose.yml
    echo "  Raised the flow collector's memory limit from 512m to 2g in docker-compose.yml."
  elif echo "$flow_block_now" | grep -q 'mem_limit: 1g'; then
    sed -i '/^  flow:/,/^  [a-z]/ s/mem_limit: 1g/mem_limit: ${FLOW_MEM_LIMIT:-2g}/' docker-compose.yml
    echo "  Raised the flow collector's memory limit from 1g to 2g in docker-compose.yml."
  fi
  if echo "$flow_block_now" | grep -q 'cpus: 1.0'; then
    sed -i '/^  flow:/,/^  [a-z]/ s/cpus: 1\.0/cpus: ${FLOW_CPUS:-2.0}/' docker-compose.yml
    echo "  Raised the flow collector's CPU limit from 1 core to 2 in docker-compose.yml."
  fi
fi

# v2.13.13: the collector logs and reports its own version so a support
# bundle says which build produced it (it used to log a hardcoded literal
# that went stale the moment it shipped). It reads PORT_SIGHT_VERSION from
# its environment and says "unknown" without it, so give an older install's
# flow block that variable. Skipped entirely when the block already has an
# `environment:` key of its own, so a hand-edited compose file is never
# given a duplicate YAML key. Note the guard must anchor on the KEY lines:
# the flow service's own `image:` line contains the string
# PORT_SIGHT_VERSION as part of its tag and would otherwise always match.
if grep -q 'port-sight/flow' docker-compose.yml \
   && ! sed -n '/^  flow:/,/^  [a-z]/p' docker-compose.yml | grep -qE '^    environment:|^      PORT_SIGHT_VERSION:'; then
  flow_tag_default="latest"
  grep -q 'PORT_SIGHT_VERSION:-beta' docker-compose.yml && flow_tag_default="beta"
  awk -v tag="$flow_tag_default" '
    /^  [A-Za-z_][A-Za-z0-9_]*:/ { in_flow = ($0 == "  flow:") }
    {
      if (in_flow && !done && $0 ~ /^    (mem_limit|cpus):/) {
        print "    environment:"
        print "      PORT_SIGHT_VERSION: ${PORT_SIGHT_VERSION:-" tag "}"
        done = 1
      }
      print
    }
  ' docker-compose.yml > docker-compose.yml.tmp-flowenv
  if [ -s docker-compose.yml.tmp-flowenv ]; then
    mv docker-compose.yml.tmp-flowenv docker-compose.yml
    echo "  Told the flow collector its own version (PORT_SIGHT_VERSION) in docker-compose.yml."
  else
    rm -f docker-compose.yml.tmp-flowenv
  fi
fi

echo "Updating Port-Sight in $INSTALL_DIR"
docker compose pull
docker compose up -d
# The frontend container is only recreated when its image changed; a plain
# "up -d" has been seen to leave it on the old image after a pull.
docker compose up -d --force-recreate frontend >/dev/null 2>&1 || true

# -- Flow collector: verify it actually started, heal the one failure seen --
# On the owner's production update to v2.13.0 Docker created the flow
# container WITHOUT attaching it to the compose network (no network, no
# published port), so the backend could not reach it and exporters had
# nowhere to send. A single --force-recreate fixed it. Check for exactly
# that state and recreate once, then say plainly what the collector is doing.
if grep -q 'port-sight/flow' docker-compose.yml 2>/dev/null; then
  flow_container="$(docker compose ps -q flow 2>/dev/null | head -1)"
  flow_ok=0
  if [ -n "$flow_container" ]; then
    nets="$(docker inspect "$flow_container" --format '{{range $k,$v := .NetworkSettings.Networks}}{{$k}} {{end}}' 2>/dev/null)"
    ports="$(docker inspect "$flow_container" --format '{{range $p,$v := .NetworkSettings.Ports}}{{$p}} {{end}}' 2>/dev/null)"
    if [ -z "$nets" ] || ! echo "$ports" | grep -q '2055/udp'; then
      echo "  Flow collector container started without its network or port; recreating it once."
      docker compose up -d --force-recreate flow >/dev/null 2>&1 || true
      flow_container="$(docker compose ps -q flow 2>/dev/null | head -1)"
      nets="$(docker inspect "$flow_container" --format '{{range $k,$v := .NetworkSettings.Networks}}{{$k}} {{end}}' 2>/dev/null)"
      ports="$(docker inspect "$flow_container" --format '{{range $p,$v := .NetworkSettings.Ports}}{{$p}} {{end}}' 2>/dev/null)"
    fi
    if [ -n "$nets" ] && echo "$ports" | grep -q '2055/udp'; then flow_ok=1; fi
  fi
  if [ "$flow_ok" -eq 1 ]; then
    echo "  Flow collector: running (network: $(echo "$nets" | awk '{print $1}'), UDP port published)."
  else
    echo "  WARNING: the flow collector container is not running correctly. Run 'docker compose up -d --force-recreate flow'"
    echo "  and 'docker compose logs flow --tail 20'; see docs/troubleshooting.md 'Collector unreachable'."
  fi
fi

# -- Flow collector: clear stale kernel tracking for its UDP port ----------
# Recreating the flow container gives it a new internal address, but a
# NetFlow exporter that never stops sending keeps the kernel's existing
# UDP tracking entry alive -- and that entry still points at the OLD
# address, so flows silently stop until it is cleared (seen on every update
# during the v2.13 beta). Flushing the entries for the port is harmless:
# the next packet simply creates a fresh one.
if grep -q 'port-sight/flow' docker-compose.yml 2>/dev/null; then
  FLOW_PORT_VALUE="$(grep -E '^FLOW_PORT=' .env 2>/dev/null | cut -d= -f2- | tr -d '[:space:]')"
  if [ -z "$FLOW_PORT_VALUE" ]; then
    if grep -q 'PORT_SIGHT_CHANNEL: beta' docker-compose.yml; then FLOW_PORT_VALUE=2056; else FLOW_PORT_VALUE=2055; fi
  fi
  if command -v conntrack >/dev/null 2>&1; then
    if conntrack -D -p udp --dport "$FLOW_PORT_VALUE" >/dev/null 2>&1; then
      echo "  Cleared kernel UDP tracking for the flow collector port ($FLOW_PORT_VALUE) so exporters reach the new container."
    fi
  else
    echo "  Note: if NetFlow exporters are already sending, flows can stall after an update until the kernel's stale"
    echo "  UDP tracking is cleared. Install the tool once (apt-get install -y conntrack) and future updates handle it."
  fi
fi

# Refresh the maintenance script from the releases repo (falls back to the
# copy already here), run the cleanup now, and make it a daily job.
if curl -fsSL "$SCRIPTS_URL/maintenance.sh" -o maintenance.sh.new 2>/dev/null; then
  mv maintenance.sh.new maintenance.sh
fi
if [ -f maintenance.sh ]; then
  chmod +x maintenance.sh
  ./maintenance.sh run "$INSTALL_DIR"
  if [ "$(uname -s)" = "Linux" ] && [ -d /etc/cron.d ]; then
    if [ "$(id -u)" -eq 0 ]; then
      ./maintenance.sh install-cron "$INSTALL_DIR"
    elif command -v sudo >/dev/null 2>&1 && sudo -n true 2>/dev/null; then
      sudo ./maintenance.sh install-cron "$INSTALL_DIR"
    elif ! ls /etc/cron.d/port-sight-maintenance* >/dev/null 2>&1; then
      echo ""
      echo "  To keep old image versions from filling the disk, install the daily job once:"
      echo "    sudo $INSTALL_DIR/maintenance.sh install-cron $INSTALL_DIR"
    fi
  fi
else
  echo "maintenance.sh not available; removing unused images with a plain prune."
  docker image prune -f
fi

echo ""
docker compose ps
echo ""
echo "  Port-Sight updated. Version: $(docker compose exec -T backend python -c 'from app.core.config import APP_VERSION; print(APP_VERSION)' 2>/dev/null || echo 'see Admin > System')"
