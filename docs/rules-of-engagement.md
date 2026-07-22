# Rules of engagement

Document owner: `Repository owner / requesting user (formal name required)`  
Version: `0.1-draft`  
Last reviewed: `2026-07-22`  
Approval state: **DRAFT — NOT AUTHORIZED FOR EXECUTION**

## 1. Purpose

Authorize a time-bounded, defensive Microsoft Entra AiTM showcase that compares
an approved baseline with hardened controls using only synthetic identities and
non-production resources. This document is not approval to stage tooling or run
a scenario until every required field and signature below is complete.

## 2. Owners and stop authority

| Responsibility | Named person | Contact path | Confirmed |
|---|---|---|---|
| Executive/project sponsor | `[REQUIRED]` | `[REQUIRED]` | No |
| Exercise director | Repository owner / requesting user | `[REQUIRED — direct contact path]` | Yes — confirmed 2026-07-22 |
| Security approver | `[REQUIRED]` | `[REQUIRED]` | No |
| Entra test-tenant owner | `[REQUIRED]` | `[REQUIRED]` | No |
| Network/lab owner | `[REQUIRED]` | `[REQUIRED]` | No |
| Incident commander | `[REQUIRED]` | `[REQUIRED]` | No |
| Kill-switch owner | Repository owner / requesting user | `[REQUIRED — direct contact path]` | Yes — confirmed 2026-07-22 |
| Evidence/retention owner | `[REQUIRED]` | `[REQUIRED]` | No |

Every participant has stop authority. The repository owner/requesting user is
the currently named exercise director and kill-switch owner and has explicit
unilateral stop authority. The incident commander will also have unilateral
stop authority once named. A stop call is final until the security approver and
exercise director jointly authorize a restart in writing.

## 3. Time window and participants

| Field | Approved value |
|---|---|
| Preparation start | `[REQUIRED — date/time/time zone]` |
| Authorization expiry | `[REQUIRED — date/time/time zone]` |
| Event window | `[REQUIRED — date/time/time zone]` |
| Teardown deadline | `[REQUIRED — date/time/time zone]` |
| Authorized operators | `[REQUIRED — names/roles]` |
| Authorized observers | `[REQUIRED — names/groups]` |

No work beyond document drafting and passive review is permitted outside the
approved window or by unlisted participants.

## 4. Approved scope

Complete with exact non-production values before approval.

| Scope item | Approved value | Evidence/owner |
|---|---|---|
| Dedicated Entra test tenant ID/name | `[REQUIRED]` | `[REQUIRED]` |
| Synthetic account aliases | `[REQUIRED]` | `[REQUIRED]` |
| Test groups and roles | `[REQUIRED]` | `[REQUIRED]` |
| Test application/workload | `[REQUIRED]` | `[REQUIRED]` |
| Lab domains/subdomains | `[REQUIRED]` | `[REQUIRED]` |
| Internal lab CIDRs/IPs | `[REQUIRED]` | `[REQUIRED]` |
| Approved outbound cloud destinations | `[REQUIRED]` | `[REQUIRED]` |
| Hyper-V host and isolated switch/VLAN | `[REQUIRED]` | `[REQUIRED]` |
| Test devices/VMs | `lab-aitm-01, lab-victim-01, lab-attacker-01, lab-monitor-01 (confirm IDs)` | `[REQUIRED]` |
| Administration path | `[REQUIRED]` | `[REQUIRED]` |
| Evidence stores | `[REQUIRED]` | `[REQUIRED]` |

Documentation and offline fixtures may use only `192.0.2.0/24`,
`198.51.100.0/24`, and `203.0.113.0/24` as simulated public ranges.

## 5. Explicit production exclusions

The following are out of scope without exception:

- The production tenant, production identities, guests, applications, service
  principals, licenses, subscriptions, data, and trust relationships.
- The production Teams Phone VM and every production server or endpoint.
- Corporate DNS, mail, domains, certificates, network segments, VPN, routing,
  proxies, and security controls.
- Real credentials, authentication factors, sessions, cookies, tokens, personal
  data, customer data, and third-party services.
- Public ingress, router forwarding, public phishing delivery, or internet
  exposure not separately approved for an exact design.

An in-scope value resembling or resolving to production makes it out of scope
and triggers an immediate abort.

## 6. Permitted and prohibited activity

Before the Phase 0 gate closes, only planning, documentation, passive inventory,
and approval review are permitted. Later work is limited to the current approved
phase and the exact scope above.

Prohibited activity includes operational phishing instructions, real sign-in
cloning, credential/OTP capture, raw token or cookie export, session replay
against Entra/Microsoft 365/third parties, persistence, evasion, lure delivery,
production targeting, and unapproved scanning or routing changes.

## 7. Data handling and retention

| Decision | Approved value |
|---|---|
| Permitted evidence fields | Scenario/event ID, timestamp, synthetic alias, documentation-range IP, device state, authentication strength, risk level, Conditional Access result/reason, session fingerprint, response status |
| Retention period | `[REQUIRED — duration and deletion date]` |
| Approved storage | `[REQUIRED — location and access group]` |
| Dashboard readers | `[REQUIRED]` |
| Recording/screenshots allowed | `[REQUIRED — yes/no and constraints]` |
| Disposal verification owner | `[REQUIRED]` |

Authentication secrets and real-user identifiers are prohibited everywhere,
including logs, screenshots, recordings, backups, dashboards, fixtures, Git,
and tickets. If exposed, stop immediately and follow Section 8.

## 8. Stop, incident, and restart procedure

1. Any participant calls **STOP** and records a sanitized timestamp/reason.
2. The kill-switch owner cuts lab connectivity when applicable; operators stop
   the test engine and make no further authentication attempts.
3. The incident commander opens the approved private incident channel:
   `[REQUIRED — contact/channel]`.
4. Owners assess production impact and secret exposure without copying raw
   authentication material into evidence.
5. Follow the approved containment and notification obligations:
   `[REQUIRED — incident policy/reference and escalation contacts]`.
6. Preserve only approved sanitized evidence, document actions and decisions,
   and complete recovery/teardown as directed.
7. Restart only with written authorization from the exercise director and
   security approver, plus network approval when connectivity is implicated.

## 9. Approval record

Signatures assert that scope is exact, production exclusions are understood,
contacts and dates are complete, retention is approved, and incident handling
is actionable.

| Approver | Name | Decision | Date/time/time zone | Approval record/link |
|---|---|---|---|---|
| Project sponsor | `[REQUIRED]` | Pending | `[REQUIRED]` | `[REQUIRED]` |
| Security | `[REQUIRED]` | Pending | `[REQUIRED]` | `[REQUIRED]` |
| Entra tenant owner | `[REQUIRED]` | Pending | `[REQUIRED]` | `[REQUIRED]` |
| Network/lab owner | `[REQUIRED]` | Pending | `[REQUIRED]` | `[REQUIRED]` |
| Evidence/privacy owner | `[REQUIRED]` | Pending | `[REQUIRED]` | `[REQUIRED]` |

## 10. Phase 0 exit checklist

- [ ] All owners, contacts, participants, dates, and scope values are exact.
- [ ] Retention, recording, storage, and disposal decisions are approved.
- [ ] Incident, kill-switch, stop, and restart procedures are actionable.
- [x] Production exclusions and mandatory abort conditions are explicit.
- [ ] Every required approver recorded written approval.
- [ ] `tests/Test-Phase0.ps1` passes and its sanitized result is linked.

**Gate decision: OPEN. Phase 1 and all execution remain unauthorized.**
