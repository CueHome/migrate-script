# Tech Stack — Overview & Index

This is the index for documenting CueHome's full technology stack. Each linked
file covers one layer. Fill these in over time; mark unknowns as
`> TODO(confirm): ...` rather than guessing.

## Index

- [Fleet management — MeshCentral](./fleet-meshcentral.md)
- [Edge devices](./edge-devices.md)
- [CI/CD & source — GitHub](./cicd-github.md)
- [Integrations — Microsoft 365](./integrations-m365.md)

## Stack map (fill in)

| Layer              | Technology | Owner | Status / notes |
|--------------------|-----------|-------|----------------|
| Fleet management   | MeshCentral (`remote.cuehome.in`) | | confirmed from `migrate.sh` |
| Edge device OS     | Linux (Raspberry Pi-class)        | | `/home/pi/...` paths |
| Device agent       | MeshAgent                         | | installed/migrated by `migrate.sh` |
| Source control     | GitHub (`cuehome/*`)              | | |
| CI/CD              | _TODO(confirm)_                   | | GitHub Actions? other? |
| OTA / deploy        | _TODO(confirm)_                  | | how does code reach devices? |
| Backend / cloud    | _TODO(confirm)_                  | | what hosts `remote.cuehome.in`? |
| Data / telemetry   | _TODO(confirm)_                  | | per-device signals, where stored |
| Productivity / support | Microsoft 365 (Outlook, SharePoint, OneDrive) | | |
| Secrets management | _TODO(confirm)_ — currently ad-hoc | | see security flag in CLAUDE.md |

> The fastest way to complete this: have a session walk the `cuehome/*` repos and
> infrastructure and fill each row with confirmed facts.
