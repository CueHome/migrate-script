# Fleet Management — MeshCentral

## What it is
CueHome manages its edge fleet remotely via **MeshCentral**, reachable at
`https://remote.cuehome.in`. Devices run the **MeshAgent**, which connects back to
the server for remote management, scripting ("Run as agent"), and monitoring.

## Known facts (from `cuehome/migrate-script`)
- New server endpoint: `https://remote.cuehome.in`
- Agent binary locations checked: `/usr/local/mesh_services/meshagent/meshagent`,
  `/usr/local/mesh/meshagent`
- Device identity file: `/home/pi/.metacbs/device.json` (field `"ID"` →
  used as MeshCentral `agentName`)
- Migration script (`migrate.sh`) downloads `"$NEW_SERVER/meshagents?script=1"`,
  patches `agentName`, stops the old agent, and reinstalls against the new server.
- Migrations are triggered per-device via MeshCentral's **"Run as agent"**.

## Open questions
> TODO(confirm): How many devices are under management today? Growth curve?
> TODO(confirm): How is the old→new server migration batched/triggered across the fleet?
> TODO(confirm): How is migration success/failure detected fleet-wide (vs. per device)?
> TODO(confirm): Where does MeshCentral run (host, region, HA)? Who operates it?

## Related
- Runbook: [Device migration](../runbooks/device-migration.md)
