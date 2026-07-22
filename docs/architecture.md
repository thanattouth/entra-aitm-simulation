# Architecture and threat model

Status: **Phase 1 draft for Security and Network review**

This design supports a real Microsoft Entra **test tenant** while keeping the
AiTM engine a user-managed black box. It does not authorize public ingress,
credential/token collection, or session replay. Production tenants, identities,
workloads, networks, and the Teams Phone VM remain excluded.

## Showcase outcomes

The seven-minute story has two test-only cases:

1. **Baseline:** a synthetic user completes ordinary MFA; sanitized evidence
   explains that successful authentication and protection of the resulting
   session are separate properties.
2. **Hardened:** a pilot-scoped control requires phishing-resistant
   authentication and an approved device/session condition; the changed context
   is blocked or restricted and the reason is shown.

No dashboard, recording, fixture, or Git artifact may contain a password, OTP,
cookie, authorization code/header, access/refresh/ID token, raw JWT, session
export, or real-user identifier.

## System context

```text
lab-victim-01 ---- approved lab DNS ---- user-managed black box
       |                                         |
       |                                         +---- controlled egress
       |                                                   |
       +---------------------------------------- Entra test tenant
                                                          |
                                                  test-only workload

Entra sign-in/audit logs ---- sanitized adapter ---- collector ---- dashboard
black-box scenario marker --- manual sanitizer -----------^

lab-attacker-01 = approved validation point (no raw session material retained)
lab-monitor-01  = sanitized evidence plane
lab-aitm-01     = dedicated Linux VM; clean checkpoint; deny-incoming baseline
```

The current Linux base VM is installed and checkpointed. Public forwarding and
AiTM software staging remain separate gated actions.

## Trust boundaries

| Boundary | Untrusted side | Trusted side | Required control |
|---|---|---|---|
| Internet/NAT | Public network | Lab NAT segment | No inbound by default; exact time-bound exception only after approval |
| Lab/production | Lab components | Production environment | No production route, identity, DNS, data, or workload dependency |
| Black box/evidence | User-managed engine | Collector/dashboard | Manual or one-way sanitized contract; never ingest raw engine logs |
| Test user/identity | Browser and test VM | Entra test tenant | Synthetic identities, test workload, pilot groups, scoped policies |
| Management/lab | Admin path | Hyper-V and lab VMs | Named operators, strong access, logging, kill switch, no public admin ports |
| Entra/log consumer | Entra activity data | Dashboard | Least privilege, field allowlist, retention and access controls |

## Network-flow register

Every allowed flow requires exact source, destination, port, owner, approval,
and expiry in the local inventory. This table states intent, not an active rule.

| Flow | Default | Review requirement |
|---|---|---|
| Hyper-V console to lab VM | Allow on management plane | Named operator and host audit |
| Lab VM outbound to Ubuntu update endpoints | Temporary allow | Patch window and checksum evidence |
| Test VMs outbound to approved Entra/test-workload endpoints | Deny until listed | Exact destination review and Network approval |
| Test VM to black-box listener | Deny until scenario approval | Test-only source, exact port, time window, kill switch |
| Black box to sanitized collector | Prohibited directly | Use sanitized event adapter only |
| Entra logs to collector | Deny until logging design approved | Reports Reader/least privilege and field allowlist |
| Internet inbound to any lab component | Deny | A future exception requires new written approval |
| Any lab component to production | Deny and abort on observation | Never permitted |

## Threat model

| Threat/failure | Impact | Prevent/detect/respond |
|---|---|---|
| Production identity or tenant appears | Unauthorized production interaction | Exact tenant/account allowlist; abort immediately; incident path |
| Raw authentication material reaches logs/dashboard | Secret disclosure | Never ingest raw black-box logs; schema allowlist; static/fixture tests |
| Public service is scanned or exploited | Lab compromise or spillover | No ingress by default; patching; exact time-boxed rules; kill switch |
| Lab VM reaches another workload on its subnet | Lateral impact | Confirm lab-only NAT boundary; host/network review; outbound controls |
| Conditional Access locks out administration | Tenant loss of control | Two emergency accounts; exclusions; report-only; pilot scope |
| Policy behaves differently from expectation | Incorrect security claim | What If, sign-in logs, three repeatable runs, documented limitations |
| Evidence cannot correlate events | Demo ambiguity | Scenario/event IDs, UTC timestamps, alias mapping outside dashboard |
| Internet or tenant unavailable on event day | Demo failure | Sanitized offline fixtures and recorded screenshots with approval |
| Black-box version/config changes | Non-repeatable result | Version/checksum/revision record outside operational content; clean snapshot |

## Evidence contract

Allowed evidence is limited to UTC timestamp, scenario/event ID, synthetic
alias, documentation-range display IP, device state, authentication strength,
risk level, Conditional Access result/reason, session fingerprint, and response
status. See `collector/schema/sanitized-event.schema.json`.

Real internal/public IP values may exist only in restricted operational records;
audience fixtures use `192.0.2.0/24`, `198.51.100.0/24`, or
`203.0.113.0/24`.

## Test cases and expected results

| ID | Case | Expected result |
|---|---|---|
| ARCH-01 | Production tenant/account/domain appears | Automatic/manual abort; no further request |
| ARCH-02 | Event contains a forbidden field | Validator rejects it; collector stores nothing |
| ARCH-03 | Baseline synthetic sign-in | Timeline shows authentication/MFA and approved policy result without secrets |
| ARCH-04 | Hardened pilot sign-in | Phishing-resistant/device control result and reason are visible |
| ARCH-05 | Emergency account review | Account remains available and excluded from blocking CA policies |
| ARCH-06 | Public inbound probe before approval | No lab listener is reachable |
| ARCH-07 | Kill-switch activation | Egress/inbound path closes and engine stops within the agreed target |
| ARCH-08 | Dashboard unavailable | Offline sanitized fixture tells the same story |
| ARCH-09 | Reset from clean state | Environment returns to the approved state within 60 seconds target |

## Phase 1 review gate

- [ ] Security accepts the threat model and evidence contract.
- [ ] Network accepts the exact flow register and isolation proof.
- [ ] Identity owner accepts the tenant/group/policy design.
- [ ] Incident and kill-switch owners accept abort/restart behavior.
- [ ] Test owners accept expected results and limitations.

**Gate status: OPEN. This document is a review draft, not execution approval.**
