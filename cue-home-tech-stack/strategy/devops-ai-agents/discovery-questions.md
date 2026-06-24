# DevOps AI Agents — Discovery Questions

Questions to define which autonomous AI agents ("AI employees") CueHome should
build for DevOps. Answer in prose; depth > completeness. Captured 2026-06-24.

## A. Business & Strategic
1. **What hurts most today?** Top 3 operational fires by hours-burned or
   revenue-at-risk, and who fights them?
2. **Fleet scale & growth curve?** Devices under management today and 12–24 month projection.
3. **What does "AI employee" mean in dollars?** Avoid hiring N engineers / speed up
   existing team / cover hours you can't staff?
4. **Risk appetite for autonomy?** suggest-only / act-with-approval / fully
   autonomous (bounded). Worst-case blast radius tolerable on a device?

## B. Critical Ops & Workflow
5. **Migration story:** how is `migrate.sh` triggered (one-by-one / batched /
   scheduled)? How do you learn a device failed? Recovery loop?
6. **Observability ground truth:** how do you learn a device is down/misbehaving?
   What telemetry exists per device, and where?
7. **Software delivery pipeline:** commit → running on device. CI/CD? OTA? Where does it stall?
8. **Toil inventory:** repetitive tasks that eat the day (log triage, restarts,
   cert/key rotation, onboarding, repeat tickets).
9. **Support ↔ ops boundary:** share of ops work from support (M365 tickets/email)
   vs. monitoring? Could an agent triage/route/resolve inbound?

## C. Technical, Safety & Constraints
10. **Credentials & access:** how are device keys/server creds/secrets managed?
    (Note: hardcoded install key in `migrate.sh` — rotate.) Vault or scattered?
11. **Rollback & kill-switch:** rollback story for autonomous device actions?
    Way to halt an agent mid-fleet-operation?
12. **Environments & canary fleet:** staging/canary devices to test agents on, or all prod?
13. **Compliance & data:** customer-premises (home?) privacy/regulatory constraints.
    Data an agent must not touch/exfiltrate?

## D. Adoption & Org
14. **Who owns the agents?** Who supervises/approves/trusts them day-to-day? Bought in or skeptical?
15. **Definition of success in 90 days:** one measurable outcome from the first
    agent that means "this works, build more."

## Answers (fill in)
> _Paste answers here as they come; the roadmap is derived from these._
