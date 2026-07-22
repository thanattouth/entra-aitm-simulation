# Hyper-V lab topology and trust boundaries

Status: **Design package only — not deployed**

## Zones and components

| Zone | Components | Trust rule |
|---|---|---|
| Management/recovery | Approved admin workstation, offline config inventory, snapshots | Management may enter through one approved path; lab cannot initiate management access |
| Isolated lab | `lab-gateway-01`, internal vSwitch, lab DNS/time controls, operator access | Deny by default; no production route; no public ingress |
| Test users | `lab-victim-01`, `lab-attacker-01` | Synthetic identities and non-production data only; no lateral traffic except explicitly approved services |
| Test engine | `lab-aitm-01` | User-managed black box in a later phase; stopped and disconnected by default |
| Detection/evidence | `lab-monitor-01`, sanitized collector/dashboard | Allowlisted metadata only; authentication material prohibited |
| Identity/application | Dedicated Entra test tenant and test workload | Approved cloud egress only; no production trust or data dependency |

## Conceptual connectivity

```text
approved admin path ---> lab internal vSwitch
                              |
                       lab-gateway-01 ---- approved cloud egress only
                         /    |    \
             lab-victim-01   |   lab-attacker-01
                             |
                       lab-aitm-01
                             |
                       lab-monitor-01

production CIDRs/domains <--- explicit deny; abort on any observed path
public inbound traffic   <--- absent
```

The gateway/firewall is the sole future egress path. The Hyper-V host must not
route between the internal vSwitch and production. Do not bridge the lab switch
to a corporate adapter. An uplink design, if later approved, must terminate on
the gateway and enforce destination allowlists, outbound state tracking, and
inbound deny.

## Proposed address plan

The default internal range is `10.77.0.0/24`; it is only a proposal and must be
checked against corporate, VPN, home, and cloud routes before approval.

| Component | Proposed address | Purpose |
|---|---|---|
| `lab-gateway-01` | `10.77.0.1` | Firewall, controlled DNS forwarding, kill switch |
| `lab-aitm-01` | `10.77.0.10` | Future test engine black box |
| `lab-victim-01` | `10.77.0.20` | Synthetic victim browser |
| `lab-attacker-01` | `10.77.0.30` | Approved validation point |
| `lab-monitor-01` | `10.77.0.40` | Sanitized collector/dashboard |

## Allowed flow contract

No flow is active until its exact source, destination, port, owner, rationale,
expiry, and approval record are entered in the local configuration.

| Source | Destination | Default | Future rationale |
|---|---|---|---|
| Admin workstation | Approved management endpoint | Deny | Restricted administration |
| Test VMs | Gateway DNS/time services | Deny | Controlled name resolution and time |
| Test VMs | Approved Entra/test-workload endpoints | Deny | Test-tenant authentication/workload access |
| Lab components | `lab-monitor-01` | Deny | Sanitized event metadata only |
| Any lab component | Production ranges/domains | Deny | Never permitted |
| Internet | Any lab component | Deny | Public ingress prohibited |

## Kill switch

The requesting repository owner is the currently named kill-switch owner. The
future implementation must disable the gateway's uplink first, preserve the
internal management path only if incident command approves it, and stop the
test-engine VM. Activation must not depend on the test tenant or public cloud.

Before deployment, record an exact command/runbook, backup operator, expected
completion time, and evidence of a successful test from a clean snapshot.

## Required proofs before Phase 3 can close

- The internal vSwitch is not external, bridged, or shared with production.
- No route exists from any lab VM to any approved production-deny range.
- No unsolicited inbound connection reaches the lab.
- Cloud egress matches a reviewed destination/port allowlist.
- All five components have clean snapshots and an inventory checksum.
- The kill switch is tested by both primary and backup operators.
- Reset and recovery paths are documented and timed.
