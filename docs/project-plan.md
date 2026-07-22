# Project plan and phase register

## Current gate

Current phase: **0 — Authorization and rules of engagement**

Gate status: **OPEN**

Next permitted action: complete and approve `docs/rules-of-engagement.md`.

Phases 1-11 are intentionally not started. In particular, Evilginx staging is
prohibited until Phases 0-3 have each passed their approval gate.

## Phase register

| Phase | Deliverable/gate | Status |
|---|---|---|
| 0 | Written authorization and explicit production exclusions | In progress |
| 1 | Architecture and threat model; security/network review | Not started |
| 2 | Isolated Entra tenant/identities; no production dependencies | Not started |
| 3 | Segmented infrastructure; routing proof and kill-switch test | Not started |
| 4 | User-managed black-box staging; peer/scope review | Not authorized |
| 5 | Three repeatable baseline runs and sub-60-second reset | Not authorized |
| 6 | Report-only hardened controls, pilot validation, then approval | Not authorized |
| 7 | Sanitized dashboard/detections and offline fixtures | Not authorized |
| 8 | Incident-response showcase | Not authorized |
| 9 | Three rehearsals, review, freeze, checksums | Not authorized |
| 10 | Authorized event execution | Not authorized |
| 11 | Teardown, sanitization, and after-action review | Not authorized |

## Phase 0 work items

| ID | Work item | Owner | Status | Evidence |
|---|---|---|---|---|
| P0-01 | Nominate owners and unilateral stop authorities | Repository owner / requesting user | In progress — exercise director and kill-switch owner confirmed; formal name, contact, and other owners remain | ROE §2 |
| P0-02 | Set start, event, expiry, and teardown dates | `[REQUIRED]` | Open | ROE §3 |
| P0-03 | Enumerate exact tenant/accounts/domains/IPs/devices | `[REQUIRED]` | Open | ROE §4 |
| P0-04 | Confirm explicit production exclusions | Security approver | Drafted | ROE §5 |
| P0-05 | Approve evidence fields, storage, retention, disposal | `[REQUIRED]` | Open | ROE §7 |
| P0-06 | Confirm incident contacts and escalation policy | `[REQUIRED]` | Open | ROE §8 |
| P0-07 | Collect written approvals | Exercise director | Open | ROE §9 |
| P0-08 | Run Phase 0 validation and link sanitized output | Exercise director | Open | ROE §10 |

## Decision log

| Date | Decision | Rationale | Owner/status |
|---|---|---|---|
| 2026-07-22 | Use repository name `entra-aitm-defensive-showcase` | Required by the governing skill | Recorded |
| 2026-07-22 | Treat Phase 0 as the only active phase | Authorization must precede design and execution | Recorded |
| 2026-07-22 | Prefer no public ingress | Reduces exposure; exact exceptions require governance/network approval | Recorded |
| 2026-07-22 | Never invent approval or in-scope identifiers | Written, accountable scope is the Phase 0 gate | Recorded |
| 2026-07-22 | Repository owner/requesting user holds unilateral stop authority | Confirmed directly by the user; formal name and contact remain required | Recorded |
| 2026-07-22 | Prepare an offline infra design package while gates remain open | Supports review without provisioning, routing, firewall, tenant, or public-ingress changes; Phase 3 remains not started | Recorded |

## Risk register

| ID | Risk | Control/response | Owner | State |
|---|---|---|---|---|
| R-01 | Accidental production interaction | Exact allowlist, explicit exclusions, abort on mismatch | `[REQUIRED]` | Open |
| R-02 | Authentication material retained or displayed | Field allowlist, secret tests, immediate stop/incident path | `[REQUIRED]` | Open |
| R-03 | Unexpected public reachability | No public ingress by default; later network review and kill switch | `[REQUIRED]` | Open |
| R-04 | Approval expires before event/teardown | Explicit expiry and change-control review | `[REQUIRED]` | Open |
| R-05 | Stop or incident contact unavailable | Named primary/backup contacts and rehearsal | `[REQUIRED]` | Open |
| R-06 | Repository/remote name differs from intended name | Rename local folder/remote in an authorized administrative step | Project owner | Open |

## Phase 0 evidence

- Governing plan: `skill/SKILL.md` (source copy also currently at root).
- Draft authorization: `docs/rules-of-engagement.md`.
- Safety policy: `SECURITY.md`.
- Gate validator: `tests/Test-Phase0.ps1`.
- Offline infra design evidence: `infra/`; static validation at `tests/Test-InfraStatic.ps1` (preparatory only, not a Phase 3 exit claim).
- Written approvals: **not yet supplied**.

## Next gate

Phase 0 exits only after all required fields are resolved, all approval rows are
signed and linked, the validation script passes, and the exercise director
records the gate decision. Until then, Phase 1 must not begin.
