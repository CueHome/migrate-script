# System Context

A high-level map of how the pieces fit. Refine as the stack is documented.

```
                         ┌─────────────────────────┐
   Developers ──push──▶  │   GitHub (cuehome/*)     │
                         └───────────┬─────────────┘
                                     │  CI/CD + deploy  (TODO: confirm path)
                                     ▼
        ┌──────────────────────────────────────────────┐
        │      MeshCentral  (remote.cuehome.in)         │
        │   remote mgmt · scripting · monitoring        │
        └───────────────┬──────────────────────────────┘
                        │  MeshAgent connections
            ┌───────────┼───────────┬───────────┐
            ▼           ▼           ▼           ▼
        ┌───────┐  ┌───────┐   ┌───────┐   ┌───────┐
        │ Edge  │  │ Edge  │   │ Edge  │   │ Edge  │   (Raspberry Pi-class,
        │device │  │device │   │device │   │device │    customer premises)
        └───────┘  └───────┘   └───────┘   └───────┘

   Support / ops glue:  Microsoft 365 (Outlook · SharePoint · OneDrive)
```

> TODO(confirm): the GitHub → device delivery path, the cloud/backend behind
> `remote.cuehome.in`, and the telemetry/data plane.
