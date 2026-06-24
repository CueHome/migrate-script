# CueHome — Tech Stack & DevOps Workspace

This is the **home workspace for all Claude Code sessions** working on CueHome's
technology stack, fleet operations, and the DevOps AI-agents strategy. Any Claude
Code session opened in this directory should read this file first and treat it as
the source of truth for context and conventions.

> ⚠️ This file is living documentation. Keep it accurate — when the stack changes,
> update the relevant `docs/` file and the summary here in the same change.

---

## What CueHome does (context for any session)

CueHome operates a **fleet of edge / IoT devices** (Raspberry Pi-class hardware,
device identity stored at `/home/pi/.metacbs/device.json`) deployed to customer
premises. The fleet is managed remotely via **MeshCentral** (`remote.cuehome.in`).
DevOps here spans three domains:

1. **Fleet / device ops** — provisioning, migration, health, remote management
   (MeshCentral, the `migrate.sh` agent-migration flow).
2. **Software delivery** — code → CI → device (GitHub-centric).
3. **Ops glue / support** — issues that originate from customers, routed through
   Microsoft 365 (Outlook, SharePoint, OneDrive).

## Tech stack at a glance

| Layer            | Technology                                  | Notes / see |
|------------------|---------------------------------------------|-------------|
| Fleet management | MeshCentral (`remote.cuehome.in`)           | `docs/tech-stack/fleet-meshcentral.md` |
| Edge devices     | Raspberry Pi-class, MeshAgent               | `docs/tech-stack/edge-devices.md` |
| Source / CI      | GitHub (`cuehome/*`)                         | `docs/tech-stack/cicd-github.md` |
| Productivity     | Microsoft 365 (Outlook, SharePoint, OneDrive)| `docs/tech-stack/integrations-m365.md` |
| ...              | _fill in as the stack is documented_        | |

> The table above is intentionally incomplete. Filling it in accurately is one of
> the first jobs for sessions in this workspace — see `docs/tech-stack/overview.md`.

---

## How Claude should work in this directory

- **Read before writing.** Start from `docs/tech-stack/overview.md` and the relevant
  per-area file before answering stack questions. Don't answer from memory.
- **Document, don't guess.** If a fact about the stack is unknown, mark it
  `> TODO(confirm): ...` rather than inventing it. Accuracy beats completeness.
- **Strategy lives in `strategy/`.** The DevOps AI-agents work (discovery,
  roadmap, guardrails) is tracked there.
- **Secrets never get committed.** See the security note below — treat any
  credential as something to reference by name, never to paste.

## Conventions

- Markdown docs, one topic per file, linked from `docs/tech-stack/overview.md`.
- Runbooks (operational procedures) go in `docs/runbooks/`.
- Use `scratch/` for throwaway working files (git-ignored).

---

## 🔒 Security note (read this)

The `cuehome/migrate-script` repo currently has a **hardcoded MeshCentral install
key committed in `migrate.sh`** (and in git history). This is a live secret and
should be **rotated**, then sourced from a secrets manager / env var instead of
being committed. Any automation built around the fleet must adopt a real
credential model — see `strategy/devops-ai-agents/autonomy-guardrails.md`.
