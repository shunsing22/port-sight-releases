#!/usr/bin/env bash
# Port-Sight host maintenance.
#
# Docker keeps every image version ever pulled until something removes it --
# about half a gigabyte per Port-Sight release -- and a full disk stops
# PostgreSQL cold. This script removes the Port-Sight image versions that no
# container uses, clears untagged leftovers, and (as root) keeps the kernel's
# free memory defragmented so containers can always start. It never touches
# data volumes or another application's tagged images.
#
# Installed by install.sh / update.sh as a daily cron job; safe to run by
# hand at any time:
#
#   ./maintenance.sh run [INSTALL_DIR]           # clean up now
#   sudo ./maintenance.sh install-cron INSTALL_DIR   # daily job (Linux)
#   sudo ./maintenance.sh remove-cron [INSTALL_DIR]   # one install, or all
#
set -u

REPO="ghcr.io/shunsing22/port-sight"
# Pre-2.9.1 shared file; installs now get one file each, see cron_file_for().
CRON_FILE="/etc/cron.d/port-sight-maintenance"
BIN_PATH="/usr/local/sbin/port-sight-maintenance"
LOG_FILE="/var/log/port-sight-maintenance.log"

log() { echo "$(date '+%Y-%m-%d %H:%M:%S') $*"; }

cron_file_for() {
  # /opt/port-sight-beta -> /etc/cron.d/port-sight-maintenance-opt-port-sight-beta
  # (cron.d names must be [A-Za-z0-9_-] only, or cron silently ignores the file).
  local tag
  tag=$(printf '%s' "$1" | sed 's#^/##; s#[^A-Za-z0-9_-]#-#g')
  echo "/etc/cron.d/port-sight-maintenance-$tag"
}

run_cleanup() {
  local install_dir="${1:-$(pwd)}"
  local keep="latest"
  # The tag the stack is configured to run (so a stopped stack keeps its images).
  if [ -f "$install_dir/.env" ]; then
    local v
    v=$(grep -E '^PORT_SIGHT_VERSION=' "$install_dir/.env" 2>/dev/null | tail -1 | cut -d= -f2- | tr -d '[:space:]"'"'")
    [ -n "$v" ] && keep="$v"
  fi

  if ! docker info >/dev/null 2>&1; then
    log "docker is not reachable; nothing done"
    return 0
  fi

  local removed=0 ref
  # Old Port-Sight versions: remove by tag. Docker refuses to remove a tag any
  # container (running or stopped) still uses, which is exactly the guard we want.
  for ref in $(docker images --filter "reference=$REPO/*" --format '{{.Repository}}:{{.Tag}}' 2>/dev/null | grep -v ':<none>$'); do
    case "$ref" in
      *:"$keep") continue ;;
    esac
    if docker image rm "$ref" >/dev/null 2>&1; then
      log "removed $ref"
      removed=$((removed + 1))
    fi
  done

  # Untagged leftovers (the previous ":latest" becomes an untagged image after
  # every pull). Dangling-only prune: images with no tag and no container.
  local pruned
  pruned=$(docker image prune -f 2>/dev/null | grep -E '^Total reclaimed' || true)
  [ -n "$pruned" ] && log "untagged leftovers: $pruned"

  # Memory: defragment free pages so the kernel can always hand Docker the
  # contiguous blocks a new container needs (root only; harmless, seconds).
  if [ -w /proc/sys/vm/compact_memory ]; then
    echo 1 > /proc/sys/vm/compact_memory 2>/dev/null && log "memory compacted"
  fi

  # Report where Docker keeps its data and how full that disk is.
  local root
  root=$(docker info -f '{{.DockerRootDir}}' 2>/dev/null || echo /var/lib/docker)
  log "removed $removed image tag(s); disk for $root: $(df -h "$root" 2>/dev/null | awk 'NR==2 {print $4 " free of " $2 " (" $5 " used)"}')"
}

install_cron() {
  local install_dir="${1:-}"
  if [ -z "$install_dir" ]; then
    echo "usage: $0 install-cron INSTALL_DIR" >&2
    return 2
  fi
  if [ "$(id -u)" -ne 0 ]; then
    echo "install-cron must run as root (sudo)" >&2
    return 1
  fi
  if [ ! -d /etc/cron.d ]; then
    echo "/etc/cron.d not found; install a cron daemon or run '$0 run' from your own scheduler" >&2
    return 1
  fi
  # Root runs a root-owned copy, never a script from a user-writable folder.
  install -m 0755 -o root -g root "$0" "$BIN_PATH"
  local cron_file
  cron_file=$(cron_file_for "$install_dir")
  rm -f "$CRON_FILE"   # the pre-2.9.1 shared file
  cat > "$cron_file" <<EOF
# Port-Sight daily maintenance for $install_dir (installed by install.sh / update.sh).
# Removes old Port-Sight image versions and defragments memory. Log: $LOG_FILE
17 3 * * * root $BIN_PATH run "$install_dir" >> $LOG_FILE 2>&1
EOF
  chmod 0644 "$cron_file"
  echo "Daily maintenance installed: $cron_file (03:17, log $LOG_FILE)"
}

remove_cron() {
  if [ "$(id -u)" -ne 0 ]; then
    echo "remove-cron must run as root (sudo)" >&2
    return 1
  fi
  local install_dir="${1:-}"
  if [ -n "$install_dir" ]; then
    rm -f "$(cron_file_for "$install_dir")"
    echo "Daily maintenance removed for $install_dir"
  else
    rm -f "$CRON_FILE" /etc/cron.d/port-sight-maintenance-* "$BIN_PATH"
    echo "Daily maintenance removed (all installs)"
  fi
}

case "${1:-run}" in
  run)          run_cleanup "${2:-}" ;;
  install-cron) install_cron "${2:-}" ;;
  remove-cron)  remove_cron "${2:-}" ;;
  *) echo "usage: $0 {run [INSTALL_DIR]|install-cron INSTALL_DIR|remove-cron [INSTALL_DIR]}" >&2; exit 2 ;;
esac
