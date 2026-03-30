#!/usr/bin/env bash
set -Eeuo pipefail

ENV_FILE="/home/pi/CueDesk/frontend/src/environments/environment.prod.ts"
FRONTEND_DIR="/home/pi/CueDesk/frontend"
TARGET_DIR="/home/pi/CueDesk/execute_cuehome"
TARGET_FILE="${TARGET_DIR}/HTTP_Server.js"

# Use the raw GitHub file URL for direct download
DOWNLOAD_URL="https://raw.githubusercontent.com/CueHome/migrate-script/ec2/HTTP_Server.js"

echo "Starting server change script..."

# Check required paths
if [ ! -f "$ENV_FILE" ]; then
  echo "Error: environment file not found at $ENV_FILE"
  exit 1
fi

if [ ! -d "$FRONTEND_DIR" ]; then
  echo "Error: frontend directory not found at $FRONTEND_DIR"
  exit 1
fi

# Backup environment file
cp "$ENV_FILE" "${ENV_FILE}.bak.$(date +%Y%m%d_%H%M%S)"
echo "Backup created for environment.prod.ts"

# Update apiHost line
sed -i 's|apiHost: "http://[^"]*/"|apiHost: "http://deskone.cuehome.in/"|g' "$ENV_FILE"
echo "Updated apiHost in $ENV_FILE"

# Build Angular frontend
cd "$FRONTEND_DIR"
echo "Running ng build..."
ng build

# Ensure target directory exists
mkdir -p "$TARGET_DIR"

# Download and replace HTTP_Server.js
echo "Downloading HTTP_Server.js..."
curl -fL "$DOWNLOAD_URL" -o "$TARGET_FILE"
chmod 644 "$TARGET_FILE"

echo "Replaced $TARGET_FILE"

# Restart services
echo "Restarting nginx..."
sudo systemctl restart nginx

echo "Reloading pm2 processes..."
sudo pm2 reload all

echo "Done."
