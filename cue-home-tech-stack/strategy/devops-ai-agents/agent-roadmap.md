# DevOps AI Agents — Roadmap (Draft)

Status: **draft / hypothesis.** Candidates are inferred from the stack; they will
be re-prioritized once `discovery-questions.md` is answered.

## Candidate agents

### 1. Fleet Migration & Self-Heal agent
- **Job:** orchestrate `migrate.sh` across the fleet — trigger, track per-device
  status, auto-retry failures, verify, and report a fleet-wide rollout dashboard.
- **Why first:** the migration flow already exists but is manual + per-device with
  no central success/failure view. High, measurable ROI; bounded blast radius.
- **Autonomy:** act-on-low-risk (retry/verify), ask on anything destructive.
- **Needs:** MeshCentral API access, a credential model (not the hardcoded key),
  a canary device set, kill-switch.

### 2. Device Health Triage agent
- **Job:** watch telemetry, detect offline/misbehaving devices, diagnose common
  failure modes, auto-remediate (restart agent, reconnect) or escalate with context.
- **Autonomy:** act-on-low-risk; escalate the rest.
- **Needs:** telemetry source (TODO: confirm), remediation playbooks, kill-switch.

### 3. Secrets / Credential Hygiene agent
- **Job:** find committed secrets, drive rotation, move creds to a vault, enforce
  no-secret-in-repo going forward. (Immediate trigger: the `migrate.sh` install key.)
- **Autonomy:** suggest-only → act-with-approval.

### 4. Software Delivery agent
- **Job:** manage GitHub → device pipeline: build, test, canary OTA rollout,
  auto-rollback on failure signal.
- **Needs:** confirmed CI/CD + delivery path (TODO).

### 5. Support-Triage / Ops-Glue agent
- **Job:** ingest M365 (Outlook/SharePoint) inbound, triage, resolve common issues,
  route the rest with context and a draft response.
- **Autonomy:** suggest-only first (drafts), graduate to act-with-approval.

## Sequencing (crawl → walk → run)
- **Crawl:** Secrets hygiene (#3) + read-only Fleet status reporting (#1 observe-only).
- **Walk:** Fleet Migration self-heal (#1 act-on-low-risk) + Device Health Triage (#2).
- **Run:** Software Delivery (#4) + Support-Triage (#5).

## Decision log
- _record choices + rationale here as the strategy firms up._
