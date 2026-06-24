# Autonomy & Guardrails

Non-negotiables for any agent that can touch the fleet or production systems.

## Autonomy levels
- **Suggest-only** — agent investigates and drafts; human approves every change.
- **Act-with-approval** — agent auto-handles bounded safe actions (retry, restart,
  verify); asks before anything destructive or wide-blast-radius.
- **Fully autonomous (bounded)** — end-to-end within a defined domain, behind
  guardrails + kill-switch. Reserved for proven, low-risk domains.

## Required guardrails (every agent)
1. **Credential model** — no hardcoded secrets. Source from a vault/secrets
   manager; least-privilege, per-agent identities. (Rotate the `migrate.sh` key now.)
2. **Blast-radius limits** — cap how many devices a single action touches at once
   (e.g. canary → 1% → 10% → fleet). Never all-at-once on first action.
3. **Kill-switch** — a single, fast way to halt an agent mid-operation.
4. **Rollback** — every autonomous device action must have a defined rollback.
5. **Canary fleet** — test against non-customer / staging devices before prod.
6. **Audit log** — every agent action recorded: what, when, why, result.
7. **Human-in-the-loop gates** — explicit approval required above a risk threshold.
8. **Data boundaries** — define what customer-premises data agents must never
   read or exfiltrate (privacy/regulatory).

## Open guardrail questions
> TODO(confirm): vault/secrets manager in use?
> TODO(confirm): canary/staging device availability?
> TODO(confirm): compliance constraints for customer-premises devices?
