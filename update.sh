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

echo "Updating Port-Sight in $INSTALL_DIR"
docker compose pull
docker compose up -d
# The frontend container is only recreated when its image changed; a plain
# "up -d" has been seen to leave it on the old image after a pull.
docker compose up -d --force-recreate frontend >/dev/null 2>&1 || true

# Refresh the maintenance script from the releases repo (falls back to the
# copy already here), run the cleanup now, and make it a daily job.
if curl -fsSL "$RELEASES_URL/maintenance.sh" -o maintenance.sh.new 2>/dev/null; then
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
