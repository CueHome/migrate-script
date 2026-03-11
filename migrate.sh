#!/bin/bash
#==============================================================================
# MeshCentral Agent Migration Script v3.0
# Background-safe, GitHub-deployable, Production-ready
#==============================================================================

#===========================================
# Configuration
#===========================================
NEW_SERVER="https://remote.cuehome.in"
INSTALL_KEY='AED3OdxW512t0YP2pK8@vFxU@M5BDmygbAD1$UBMa7adE2SXU9EHjO@nxJ2Ctj3j'
MIGRATION_LOG="/var/log/mesh-migration.log"
WORK_DIR="$(mktemp -d /tmp/meshinstall.XXXXXX)"
INSTALL_SCRIPT="$WORK_DIR/meshinstall.sh"
LOCK_FILE="/tmp/mesh-migration.lock"
SUCCESS_MARKER="/tmp/mesh-migration-success"

#===========================================
# Prevent Multiple Simultaneous Runs
#===========================================
if [ -f "$SUCCESS_MARKER" ]; then
    echo "[$(date)] Migration already completed successfully. Exiting."
    exit 0
fi

if [ -f "$LOCK_FILE" ]; then
    LOCK_PID=$(cat "$LOCK_FILE")
    if ps -p "$LOCK_PID" > /dev/null 2>&1; then
        echo "[$(date)] Migration already running (PID: $LOCK_PID). Exiting."
        exit 0
    else
        echo "[$(date)] Stale lock file found. Removing..."
        rm -f "$LOCK_FILE"
    fi
fi

echo $$ > "$LOCK_FILE"

cleanup() {
    rm -f "$LOCK_FILE"
    rm -rf "$WORK_DIR"
}
trap cleanup EXIT

#===========================================
# Functions
#===========================================
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a $MIGRATION_LOG
}

log_error() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $1" | tee -a $MIGRATION_LOG
}

log_success() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] SUCCESS: $1" | tee -a $MIGRATION_LOG
}

get_agent_version() {
    local version="unknown"
    if [ -f /usr/local/mesh_services/meshagent/meshagent ]; then
        local mod_date=$(stat -c %y /usr/local/mesh_services/meshagent/meshagent 2>/dev/null | cut -d' ' -f1)
        if [ -n "$mod_date" ]; then
            version="Installed on $mod_date"
        fi
    fi
    echo "$version"
}

check_already_migrated() {
    # Check if agent is already pointing to new server
    if [ -f /usr/local/mesh_services/meshagent/meshagent.msh ]; then
        if strings /usr/local/mesh_services/meshagent/meshagent.msh 2>/dev/null | grep -q "remote.cuehome.in"; then
            log "Agent already configured for remote.cuehome.in"
            return 0
        fi
    fi
    return 1
}

#===========================================
# Pre-flight Checks
#===========================================
log "=========================================="
log "MeshCentral Agent Migration Started"
log "=========================================="
log "Hostname: $(hostname)"
log "IP Address: $(hostname -I | awk '{print $1}')"
log "Current User: $(whoami)"
log "Target Server: $NEW_SERVER"
log "Script PID: $$"

# Check if already migrated
if check_already_migrated; then
    log_success "Device already migrated. Verifying connectivity..."
    if pgrep -f "meshagent" > /dev/null; then
        log_success "Agent is running. Migration not needed."
        touch "$SUCCESS_MARKER"
        exit 0
    else
        log "Agent not running. Proceeding with migration..."
    fi
fi

# Check internet connectivity
if ! ping -c 1 -W 2 8.8.8.8 >/dev/null 2>&1; then
    log_error "No internet connectivity detected"
    exit 1
fi
log_success "Internet connectivity verified"

# Check disk space
AVAILABLE_SPACE=$(df /tmp | tail -1 | awk '{print $4}')
if [ $AVAILABLE_SPACE -lt 51200 ]; then
    log_error "Insufficient disk space in /tmp"
    exit 1
fi
log_success "Disk space check passed ($((AVAILABLE_SPACE/1024))MB available)"

#===========================================
# Backup Current Agent Info
#===========================================
if [ -f /usr/local/mesh_services/meshagent/meshagent ]; then
    OLD_AGENT_VERSION=$(get_agent_version)
    log "Current agent: $OLD_AGENT_VERSION"
fi

#===========================================
# Download Installation Script
#===========================================
log "Downloading MeshCentral installation script..."

wget "$NEW_SERVER/meshagents?script=1" --no-check-certificate -O $INSTALL_SCRIPT -q -T 30

if [ $? -ne 0 ]; then
    log "Primary download failed, trying with --no-proxy..."
    wget "$NEW_SERVER/meshagents?script=1" --no-proxy --no-check-certificate -O $INSTALL_SCRIPT -q -T 30
    
    if [ $? -ne 0 ]; then
        log_error "Failed to download installation script"
        exit 1
    fi
fi

log_success "Installation script downloaded"

# Verify script
if [ ! -f $INSTALL_SCRIPT ]; then
    log_error "Installation script file not found"
    exit 1
fi

SCRIPT_SIZE=$(stat -c%s "$INSTALL_SCRIPT" 2>/dev/null || stat -f%z "$INSTALL_SCRIPT" 2>/dev/null)
if [ $SCRIPT_SIZE -lt 1024 ]; then
    log_error "Downloaded script appears invalid (size: $SCRIPT_SIZE bytes)"
    exit 1
fi

log_success "Script validation passed (size: $SCRIPT_SIZE bytes)"

#===========================================
# Assign ID in MeshCentral
#===========================================
id=$(sed -n 's/.*"ID":[[:space:]]*"\([^"]*\)".*/\1/p' /home/pi/.metacbs/device.json)

if [ -z "$id" ]; then
    log_error "Could not extract ID from /home/pi/.metacbs/device.json"
    exit 1
fi

log_success "ID extracted: $id"

sed -i '/echo "StartupType=\$starttype" >> \.\/meshagent2\.msh/a\  echo "agentName='"$id"'" >> ./meshagent2.msh' "$INSTALL_SCRIPT"

#===========================================
# Make Script Executable
#===========================================
chmod 755 $INSTALL_SCRIPT

#===========================================
# Install New Agent
#===========================================
log "Installing new MeshCentral agent..."
log "This may take 30-60 seconds..."

(
    cd "$WORK_DIR" || exit 1
    sudo -E bash "$INSTALL_SCRIPT" "$NEW_SERVER" "$INSTALL_KEY"
) >> "$MIGRATION_LOG" 2>&1
INSTALL_EXIT_CODE=$?

if [ $INSTALL_EXIT_CODE -eq 0 ]; then
    log_success "Agent installation completed"
else
    log "Installation returned code $INSTALL_EXIT_CODE, trying fallback..."
    (
        cd "$WORK_DIR" || exit 1
        bash "$INSTALL_SCRIPT" "$NEW_SERVER" "$INSTALL_KEY"
    ) >> "$MIGRATION_LOG" 2>&1
    INSTALL_EXIT_CODE=$?

    if [ $INSTALL_EXIT_CODE -eq 0 ]; then
        log_success "Agent installation completed (fallback method)"
    else
        log_error "Agent installation failed with exit code: $INSTALL_EXIT_CODE"
        exit 1
    fi
fi

#===========================================
# Wait for Agent Initialization
#===========================================
log "Waiting for agent to initialize..."
sleep 20

#===========================================
# Verify Agent Installation
#===========================================
log "Verifying agent installation..."

# Check if process is running
MAX_RETRIES=5
RETRY_COUNT=0
while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    if pgrep -f "meshagent" > /dev/null; then
        AGENT_COUNT=$(pgrep -f "meshagent" | wc -l)
        AGENT_PID=$(pgrep -f "meshagent" | head -1)
        log_success "MeshAgent process running (PID: $AGENT_PID, count: $AGENT_COUNT)"
        break
    else
        RETRY_COUNT=$((RETRY_COUNT + 1))
        log "Attempt $RETRY_COUNT/$MAX_RETRIES: Agent not running yet, waiting..."
        sleep 5
    fi
done

if [ $RETRY_COUNT -eq $MAX_RETRIES ]; then
    log_error "Agent process not found after $MAX_RETRIES attempts"
    exit 1
fi

# Check if agent binary exists
if [ -f /usr/local/mesh_services/meshagent/meshagent ]; then
    NEW_AGENT_VERSION=$(get_agent_version)
    log_success "Agent binary found: $NEW_AGENT_VERSION"
else
    log_error "Agent binary not found at expected location"
    exit 1
fi

# Check systemd service
if command -v systemctl >/dev/null 2>&1; then
    if systemctl is-enabled meshagent >/dev/null 2>&1; then
        log_success "MeshAgent service is enabled"
    fi
    
    if systemctl is-active meshagent >/dev/null 2>&1; then
        log_success "MeshAgent service is active"
    fi
fi

#===========================================
# Verify Network Connectivity
#===========================================
log "Checking network connectivity..."
sleep 10

CONNECTIONS=0
if command -v netstat >/dev/null 2>&1; then
    CONNECTIONS=$(netstat -tulpn 2>/dev/null | grep meshagent | wc -l)
elif command -v ss >/dev/null 2>&1; then
    CONNECTIONS=$(ss -tulpn 2>/dev/null | grep meshagent | wc -l)
fi

if [ $CONNECTIONS -gt 0 ]; then
    log_success "Agent has $CONNECTIONS active network connection(s)"
else
    log "Note: Network connections not detected yet (agent may still be initializing)"
fi

#===========================================
# Cleanup
#===========================================
rm -f $INSTALL_SCRIPT
log_success "Temporary files cleaned up"

#===========================================
# Mark as Successfully Completed
#===========================================
touch "$SUCCESS_MARKER"

#===========================================
# Final Summary
#===========================================
log "=========================================="
log "Migration Summary:"
log "  Status: SUCCESS ✓"
log "  Server: $NEW_SERVER"
log "  Hostname: $(hostname)"
log "  IP Address: $(hostname -I | awk '{print $1}')"
log "  Agent PID: ${AGENT_PID:-N/A}"
log "  Agent Version: $NEW_AGENT_VERSION"
log "  Network Connections: ${CONNECTIONS}"
log "=========================================="
log "Migration completed successfully!"
log ""
log "Next Steps:"
log "  1. Verify in web UI at $NEW_SERVER"
log "  2. Check device '$(hostname)' appears online"
log "  3. Test terminal/remote desktop functionality"
log "=========================================="

exit 0

