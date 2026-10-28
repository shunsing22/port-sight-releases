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
#   ./maintenance.sh collect-logs [INSTALL_DIR] [--out FILE] [--lines N]
#                                                # support zip when the app is down
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

# --- collect-logs -----------------------------------------------------------
# A support zip from the host for when the app cannot produce its own bundle.
# Best effort: a failing command writes its error text into that member.
# Never copies .env values; compose file lines whose key looks secret are blanked.

# Run a command in the install dir, capturing stdout+stderr into a file; on a
# non-zero exit append a line saying so (the member then holds the error text).
cl_capture() {
  local dest="$1" dir="$2"; shift 2
  local rc=0
  mkdir -p "$(dirname "$dest")"
  (cd "$dir" && "$@") > "$dest" 2>&1 || rc=$?
  if [ "$rc" -ne 0 ]; then
    echo "[collect-logs] command failed (exit $rc): $*" >> "$dest"
  fi
  return 0
}

# Blank the VALUE of any "key: value" / "key=value" line whose key contains
# password, secret, key or token (any case). The key itself is kept.
cl_redact() {
  sed -E 's/^([[:space:]]*(-[[:space:]]+)?[A-Za-z0-9_."'"'"'-]*([Pp][Aa][Ss][Ss][Ww][Oo][Rr][Dd]|[Ss][Ee][Cc][Rr][Ee][Tt]|[Kk][Ee][Yy]|[Tt][Oo][Kk][Ee][Nn])[A-Za-z0-9_."'"'"'-]*[[:space:]]*[:=][[:space:]]*).+$/\1<redacted>/'
}

cl_json_escape() { printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'; }

collect_logs() {
  local install_dir="" out="" lines=2000
  while [ $# -gt 0 ]; do
    case "$1" in
      --out)   out="${2:-}"; shift; [ $# -gt 0 ] && shift ;;
      --lines) lines="${2:-}"; shift; [ $# -gt 0 ] && shift ;;
      -*)      echo "collect-logs: unknown option $1" >&2; return 2 ;;
      *)       install_dir="$1"; shift ;;
    esac
  done
  case "$lines" in ''|*[!0-9]*) echo "collect-logs: --lines needs a number" >&2; return 2 ;; esac
  [ -z "$install_dir" ] && install_dir="$(pwd)"
  if [ ! -d "$install_dir" ]; then
    echo "collect-logs: install dir not found: $install_dir" >&2
    return 1
  fi
  install_dir=$(cd "$install_dir" && pwd)
  local stamp
  stamp=$(date -u +%Y%m%dT%H%M%SZ)
  [ -z "$out" ] && out="$(pwd)/port-sight-host-logs-$stamp.zip"
  case "$out" in /*|[A-Za-z]:*) ;; *) out="$(pwd)/$out" ;; esac

  local stage
  stage=$(mktemp -d 2>/dev/null || mktemp -d -t psl) || { echo "collect-logs: cannot make a temp dir" >&2; return 1; }
  mkdir -p "$stage/logs" || return 1

  cat > "$stage/README.txt" <<README_EOF
Port-Sight host log collection
Made by: maintenance.sh collect-logs  (UTC $stamp)
Install dir: $install_dir

This archive holds what the host knows about the Port-Sight stack: container
status, the last $lines log lines of each container, the compose file with
passwords/secrets/keys/tokens blanked, the NAMES (never the values) of the
settings in .env, and disk, memory and Docker version figures.

It contains no .env values and no passwords. Please send it to
support@port-sight.com.
README_EOF

  # Channel and image tag (same rules update.sh uses).
  local channel="stable" tag="latest" v c
  if [ -f "$install_dir/.env" ]; then
    v=$(grep -E '^PORT_SIGHT_VERSION=' "$install_dir/.env" 2>/dev/null | tail -1 | cut -d= -f2- | tr -d '[:space:]"'"'")
    [ -n "$v" ] && tag="$v"
    c=$(grep -E '^PORT_SIGHT_CHANNEL=' "$install_dir/.env" 2>/dev/null | tail -1 | cut -d= -f2- | tr -d '[:space:]"'"'")
    if [ -n "$c" ]; then
      channel="$c"
    elif printf '%s' "$tag" | grep -q beta || grep -q 'PORT_SIGHT_CHANNEL: beta' "$install_dir/docker-compose.yml" 2>/dev/null; then
      channel="beta"
    fi
  elif grep -q 'PORT_SIGHT_CHANNEL: beta' "$install_dir/docker-compose.yml" 2>/dev/null; then
    channel="beta"
  fi
  printf '{"made_at": "%s", "tool": "maintenance.sh collect-logs", "install_dir": "%s", "channel": "%s", "image_tag": "%s"}\n' \
    "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$(cl_json_escape "$install_dir")" "$(cl_json_escape "$channel")" "$(cl_json_escape "$tag")" \
    > "$stage/manifest.json"

  # Compose status and per-service logs.
  cl_capture "$stage/compose-ps.txt" "$install_dir" docker compose ps -a
  local svcs svc rc=0
  svcs=$(cd "$install_dir" && docker compose config --services 2>"$stage/logs/_services-error.txt") || rc=$?
  if [ "$rc" -eq 0 ]; then
    rm -f "$stage/logs/_services-error.txt"
  else
    echo "[collect-logs] could not list services (exit $rc)" >> "$stage/logs/_services-error.txt"
    svcs=""
  fi
  for svc in $svcs; do
    cl_capture "$stage/logs/$(printf '%s' "$svc" | tr -c 'A-Za-z0-9_.-' '_').log" "$install_dir" \
      docker compose logs --no-color --tail "$lines" "$svc"
  done

  # Compose file(s), secrets blanked.
  local f
  : > "$stage/compose.yml"
  for f in docker-compose.yml compose.yml docker-compose.override.yml; do
    if [ -f "$install_dir/$f" ]; then
      echo "# ---- $f ----" >> "$stage/compose.yml"
      cl_redact < "$install_dir/$f" >> "$stage/compose.yml" 2>&1 || echo "# [collect-logs] could not read $f" >> "$stage/compose.yml"
    fi
  done
  [ -s "$stage/compose.yml" ] || echo "# no compose file found in $install_dir" > "$stage/compose.yml"

  # .env key names only.
  if [ -f "$install_dir/.env" ]; then
    grep -E '^[[:space:]]*[A-Za-z_][A-Za-z0-9_]*[[:space:]]*=' "$install_dir/.env" 2>/dev/null \
      | sed -E 's/^[[:space:]]*([A-Za-z_][A-Za-z0-9_]*)[[:space:]]*=.*$/\1/' > "$stage/env-keys.txt"
  else
    echo "# no .env in $install_dir" > "$stage/env-keys.txt"
  fi

  # Host facts.
  {
    echo "## uname -a";            uname -a 2>&1
    echo; echo "## df -h $install_dir"; df -h "$install_dir" 2>&1
    echo; echo "## memory"
    if command -v free >/dev/null 2>&1; then free -m 2>&1
    elif command -v vm_stat >/dev/null 2>&1; then vm_stat 2>&1
    else echo "free / vm_stat not available"; fi
    echo; echo "## docker --version";  docker --version 2>&1
    echo; echo "## docker compose version"; docker compose version 2>&1
    echo; echo "## date -u"; date -u 2>&1
  } > "$stage/host.txt" 2>&1

  # Archive: zip, else python zipfile, else tar.gz.
  mkdir -p "$(dirname "$out")" 2>/dev/null
  local members="README.txt manifest.json compose-ps.txt compose.yml env-keys.txt host.txt logs" how="" py=""
  rm -f "$out"
  if command -v zip >/dev/null 2>&1 && (cd "$stage" && zip -qr -D "$out" $members) >/dev/null 2>&1; then
    how="zip"
  else
    for py in python3 python; do
      if command -v "$py" >/dev/null 2>&1 && (cd "$stage" && "$py" -m zipfile -c "$out" $members) >/dev/null 2>&1; then
        how="python zipfile"; break
      fi
    done
  fi
  if [ -z "$how" ]; then
    out="${out%.zip}.tgz"
    if (cd "$stage" && tar -czf "$out" $members) >/dev/null 2>&1; then
      how="tar (gzip)"
    fi
  fi
  rm -rf "$stage"
  if [ -z "$how" ] || [ ! -s "$out" ]; then
    echo "collect-logs: could not write an archive" >&2
    return 1
  fi
  echo "Archive made with: $how"
  echo "$out"
}

case "${1:-run}" in
  run)          run_cleanup "${2:-}" ;;
  install-cron) install_cron "${2:-}" ;;
  remove-cron)  remove_cron "${2:-}" ;;
  collect-logs) shift; collect_logs "$@" ;;
  *) echo "usage: $0 {run [INSTALL_DIR]|install-cron INSTALL_DIR|remove-cron [INSTALL_DIR]|collect-logs [INSTALL_DIR] [--out FILE] [--lines N]}" >&2; exit 2 ;;
esac
