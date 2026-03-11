#!/usr/bin/env bash

set -u

NEW_SERVER="https://remote.cuehome.in"
INSTALL_KEY='AED3OdxW512t0YP2pK8@vFxU@M5BDmygbAD1$UBMa7adE2SXU9EHjO@nxJ2Ctj3j'

LOG_FILE="/var/log/mesh-migration.log"
LOCK_FILE="/tmp/mesh-migration.lock"
SUCCESS_FILE="/tmp/mesh-migration.success"
DEVICE_JSON="/home/pi/.metacbs/device.json"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

die() {
    log "ERROR: $*"
    exit 1
}

cleanup() {
    [ -n "${WORK_DIR:-}" ] && rm -rf "$WORK_DIR"
    rm -f "$LOCK_FILE"
}
trap cleanup EXIT

# Must run as root. In MeshCentral, choose: Run as agent
if [ "$(id -u)" -ne 0 ]; then
    die "Must run as root. In MeshCentral, select 'Run as agent'."
fi

# Prevent parallel runs
exec 9>"$LOCK_FILE" || die "Cannot open lock file"
if ! flock -n 9; then
    die "Another migration is already running"
fi

if [ -f "$SUCCESS_FILE" ]; then
    log "Migration already completed earlier. Exiting."
    exit 0
fi

WORK_DIR="$(mktemp -d /tmp/mesh-migrate.XXXXXX)" || die "Failed to create temp directory"
INSTALL_SCRIPT="$WORK_DIR/meshinstall.sh"

download_installer() {
    wget "$NEW_SERVER/meshagents?script=1" --no-check-certificate -O "$INSTALL_SCRIPT" -T 30 \
    || wget "$NEW_SERVER/meshagents?script=1" --no-proxy --no-check-certificate -O "$INSTALL_SCRIPT" -T 30 \
    || curl -L -k "$NEW_SERVER/meshagents?script=1" -o "$INSTALL_SCRIPT"
}

stop_old_agent() {
    log "Stopping existing MeshAgent service/processes..."

    systemctl stop meshagent 2>/dev/null || true
    service meshagent stop 2>/dev/null || true

    pkill -TERM -f '^/usr/local/mesh_services/meshagent/meshagent([[:space:]]|$)' 2>/dev/null || true
    sleep 5

    if pgrep -f '^/usr/local/mesh_services/meshagent/meshagent([[:space:]]|$)' >/dev/null 2>&1; then
        log "Old MeshAgent still running, forcing stop..."
        pkill -KILL -f '^/usr/local/mesh_services/meshagent/meshagent([[:space:]]|$)' 2>/dev/null || true
        sleep 2
    fi

    log "Stop command issued"
}

patch_agent_name() {
    local device_id=""

    [ -f "$DEVICE_JSON" ] || return 0

    device_id="$(sed -n 's/.*"ID":[[:space:]]*"\([^"]*\)".*/\1/p' "$DEVICE_JSON" | head -n 1)"

    if [ -z "$device_id" ]; then
        log "device.json found, but ID could not be extracted. Skipping agentName patch."
        return 0
    fi

    log "Extracted device ID: $device_id"

    if grep -q 'echo "StartupType=\$starttype" >> ./meshagent2.msh' "$INSTALL_SCRIPT"; then
        sed -i '/echo "StartupType=\$starttype" >> \.\/meshagent2\.msh/a\  echo "agentName='"$device_id"'" >> ./meshagent2.msh' "$INSTALL_SCRIPT" \
            || die "Failed to patch installer with agentName"
        log "Patched installer with agentName=$device_id"
    else
        log "Installer patch point not found. Skipping agentName patch."
    fi
}

run_install() {
    (
        cd "$WORK_DIR" || exit 1
        bash "$INSTALL_SCRIPT" "$NEW_SERVER" "$INSTALL_KEY"
    ) >>"$LOG_FILE" 2>&1
    return $?
}

log "=========================================="
log "MeshCentral migration started"
log "Hostname: $(hostname)"
log "Target server: $NEW_SERVER"
log "Work dir: $WORK_DIR"
log "=========================================="

download_installer || die "Failed to download MeshCentral install script"
chmod 755 "$INSTALL_SCRIPT" || die "Failed to chmod installer"

patch_agent_name
stop_old_agent

log "Running MeshCentral installer..."
if run_install; then
    log "Installer completed successfully"
else
    rc=$?
    log "Installer failed with exit code $rc, retrying once..."
    stop_old_agent
    run_install || die "Installer failed again with exit code $?"
fi

sleep 10

if pgrep -f '/meshagent([[:space:]]|$)' >/dev/null 2>&1; then
    log "MeshAgent process is running"
else
    log "MeshAgent process not detected yet; it may still be starting"
fi

if [ -f /usr/local/mesh_services/meshagent/meshagent ] || [ -f /usr/local/mesh/meshagent ]; then
    touch "$SUCCESS_FILE"
    log "Migration completed successfully"
    exit 0
fi

die "MeshAgent binary not found after installation"
