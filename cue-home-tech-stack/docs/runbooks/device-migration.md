# Runbook — Device MeshAgent Migration

Source of truth: `cuehome/migrate-script` → `migrate.sh`.

## Purpose
Migrate a device's MeshAgent from the old MeshCentral server to the new one
(`https://remote.cuehome.in`), preserving device identity.

## What the script does
1. Requires root (MeshCentral: "Run as agent").
2. Takes a lock (`/tmp/mesh-migration.lock`); skips if already succeeded
   (`/tmp/mesh-migration.success`).
3. Downloads the installer from `"$NEW_SERVER/meshagents?script=1"`.
4. Extracts device `ID` from `/home/pi/.metacbs/device.json` and patches the
   installer to set `agentName=<ID>`.
5. Stops the old MeshAgent (systemctl/service, then TERM, then KILL).
6. Runs the installer against the new server + install key; retries once on failure.
7. Verifies the MeshAgent binary/process exists; writes success marker.
8. Logs to `/var/log/mesh-migration.log`.

## Operational gaps / improvement ideas (agent candidates)
- Triggering is manual per-device. → Fleet-wide orchestration + progress tracking.
- Success/failure is per-device log only. → Centralized reporting + auto-retry of failures.
- Install key is hardcoded. → Source from a vault; rotate the leaked key.

> TODO(confirm): exact fleet rollout procedure and how failures are currently chased.
