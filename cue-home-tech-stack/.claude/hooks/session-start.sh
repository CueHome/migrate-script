#!/usr/bin/env bash
# SessionStart hook: surfaces workspace context at the top of every Claude Code
# session opened in this directory. Keep output short — it's injected as context.
set -euo pipefail

cat <<'EOF'
=== CueHome Tech Stack workspace ===
Read CLAUDE.md first. Domains: (1) Fleet/device ops via MeshCentral,
(2) Software delivery via GitHub, (3) Ops glue via Microsoft 365.
Docs: docs/tech-stack/overview.md  |  Strategy: strategy/devops-ai-agents/
Reminder: never commit secrets (see migrate.sh install-key flag in CLAUDE.md).
EOF
