# Edge Devices

## What we know
- Raspberry Pi-class Linux devices (user `pi`, paths under `/home/pi`).
- Each device has identity metadata at `/home/pi/.metacbs/device.json` (contains an `"ID"`).
- Run the MeshAgent for remote management.
- Deployed to customer premises (privacy/compliance implications — see below).

## Open questions
> TODO(confirm): Hardware revision(s) and OS image baseline.
> TODO(confirm): What application(s) run on the device beyond MeshAgent? (the "Cue Home" product)
> TODO(confirm): How are devices provisioned/onboarded initially?
> TODO(confirm): Connectivity model (always-on? intermittent? cellular?).
> TODO(confirm): Privacy/regulatory constraints for customer-premises devices.
