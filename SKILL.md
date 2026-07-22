---
name: plan-entra-aitm-showcase
description: Plan, implement, document, and validate a governed isolated Microsoft Entra AiTM defensive showcase. Use when working on the entra-aitm-defensive-showcase repository, designing its Hyper-V lab and test tenant, sequencing delivery phases, integrating a user-managed Evilginx instance as a black-box lab component, building sanitized telemetry and dashboards, comparing baseline MFA with hardened Entra controls, rehearsing the event, or performing teardown. Do not provide operational instructions, phishlets, token capture, or replay procedures for real Entra or Microsoft 365 sessions.
---

# Entra AiTM defensive showcase

## Mission

Build a safe, repeatable September event demonstration that explains how an AiTM flow can turn a successful MFA interaction into session abuse and how Microsoft Entra controls reduce the risk.

Use the repository name `entra-aitm-defensive-showcase`.

Treat the system as a segmented, dedicated test environment with tightly controlled connectivity. Do not call a real-Entra test air-gapped: Microsoft cloud access requires internet connectivity.

## Working boundary

Help with:

- Governance, authorization, rules of engagement, architecture, test plans, phase gates, repo structure, infrastructure guardrails, telemetry, dashboard, detection content, Conditional Access validation, incident response, rehearsals, event operations, teardown, and documentation.
- A local mock-IdP variant that uses lab-only cookies and cannot authenticate to external services.
- High-level placement and lifecycle of Evilginx as a user-installed, user-managed black-box component.

Do not create or supply:

- Evilginx installation commands, phishlets, Microsoft sign-in cloning, proxy/capture configuration, credential or OTP capture, raw-cookie/token export, or session-replay instructions against Entra ID, Microsoft 365, or third-party services.
- Public phishing deployment, lure delivery, evasion, persistence, or production targeting.

If asked for restricted operational content, state the boundary briefly and continue with the closest safe work item. Do not stall the entire project.

## Non-negotiable constraints

- Exclude the production Teams Phone VM, production tenant, production identities, corporate DNS, mail, data, endpoints, and network segments.
- Use a dedicated Hyper-V host or explicitly approved lab host, dedicated Linux server VM, isolated vSwitch/VLAN, deny-by-default firewall, snapshots, and a named kill-switch owner.
- Use a separate Entra test tenant, synthetic identities, test devices, test workload, and non-production data.
- Do not configure public exposure or router forwarding until governance and network approval explicitly authorize the exact design. Prefer no public ingress.
- Keep raw passwords, OTPs, cookies, authorization codes, access tokens, refresh tokens, and authorization headers out of dashboards, retained logs, screenshots, recordings, backups, and Git.
- Display fingerprints/hashes and sanitized metadata only.
- Start Conditional Access changes in report-only mode, scope them to pilot groups, verify emergency access, and enforce only after reviewing impact.
- Abort on any production identity, non-approved domain, leaked authentication material, unexpected public reachability, production impact, or unauthorized access.

## Architecture

Use five zones:

1. **Test user zone:** victim-client VM and attacker-validation VM.
2. **Isolated lab network:** lab DNS, firewall/gateway, AiTM test-engine VM, operator console, and kill switch.
3. **Identity/application:** dedicated Entra test tenant, synthetic accounts, test application or M365 test workload, and Conditional Access.
4. **Detection/evidence:** Entra sign-in/audit logs, sanitized event collector, scenario correlation, and showcase dashboard.
5. **Management/recovery:** admin workstation, configuration inventory, clean snapshots, offline fixtures, reset procedure, and teardown controls.

Maintain this conceptual flow:

```text
Victim VM -> lab DNS -> AiTM test engine -> controlled gateway -> Entra test tenant -> test workload
                                                     |
Entra sanitized logs -> collector <- lab events -----+-> dashboard

Attacker-validation VM -> approved replay validation point in test scope
Admin workstation -> operator console / Entra controls
Kill switch -> lab gateway
```

Do not install any lab component on the production Teams Phone server. Low load does not remove risks from shared ports, packages, DNS/TLS, firewall changes, scanner traffic, resource contention, or operator mistakes.

## Component inventory

Prepare:

- Hyper-V host and internal vSwitch or isolated VLAN.
- Firewall/gateway with deny-by-default policy and immediate kill switch.
- Lab DNS and approved time synchronization.
- Dedicated Linux AiTM VM (`lab-aitm-01`).
- Windows/browser victim VM (`lab-victim-01`).
- Separate attacker-validation VM (`lab-attacker-01`).
- Monitoring/dashboard VM (`lab-monitor-01`), optionally combined with the server only when resources require it.
- Dedicated Entra test tenant.
- Bootstrap administrator, Conditional Access administrator, Security Reader, emergency-access accounts, test victims, and an unprivileged validation identity.
- Groups such as `LAB-Baseline-Users`, `LAB-Hardened-Users`, `LAB-CA-Pilot`, `LAB-Emergency-Access`, and `LAB-Dashboard-Readers`.
- Test application or test-only M365 workload.
- Entra sign-in and audit logs, event collector, dashboard, snapshot store, and offline backup presentation.

## Repository layout

Create the repository as:

```text
entra-aitm-defensive-showcase/
├─ README.md
├─ SECURITY.md
├─ docs/
│  ├─ architecture.md
│  ├─ rules-of-engagement.md
│  ├─ project-plan.md
│  ├─ demo-runbook.md
│  ├─ incident-response.md
│  └─ teardown.md
├─ dashboard/
├─ collector/
├─ scenarios/
├─ detections/
├─ infra/
├─ tests/
└─ skill/
   └─ SKILL.md
```

Keep user-managed Evilginx configuration and authentication material outside Git. Commit only safe integration contracts, sanitized schemas, guardrails, and documentation.

## Delivery phases

Execute phases in order and do not begin Evilginx staging until Phases 0-3 pass.

### Phase 0 — Authorization and rules of engagement

Define owners, stop authority, scope, approved tenant/accounts/domains/IPs, participants, retention, contacts, start/end dates, and incident handling. Exit only with written approval and explicit production exclusions.

### Phase 1 — Architecture and threat model

Document authentication/session flow, trust boundaries, network flows, baseline and hardened scenarios, evidence fields, expected results, failure modes, and test cases. Exit after security and network review.

### Phase 2 — Entra test tenant and identities

Create isolated identities, emergency access, pilot groups, test workload, authentication-method sets, licenses, and logging. Verify no production trust, guest, application, or data dependency.

### Phase 3 — Isolated infrastructure

Provision the four VMs, internal switch/VLAN, firewall, DNS, time source, snapshots, administration path, and kill switch. Prove the lab cannot route to production and document every approved cloud flow.

### Phase 4 — Evilginx staging and integration

Treat Evilginx as a user-installed black box on the dedicated Linux VM. Record owner, pinned version, checksum, configuration revision, approved test scope, start/stop procedure, access policy, reset procedure, and emergency shutdown. Ensure dashboards and archives never ingest raw authentication material. Exit only after peer review, scope validation, kill-switch test, and clean snapshot.

### Phase 5 — Baseline attack-success scenario

Run only with authorized synthetic identities and data. Demonstrate ordinary MFA followed by a session-context change in the approved test scope. Show authentication result, MFA result, IP/device/context transition, applicable policy gap, risk signals, and SOC response. Require three repeatable runs and a reset under 60 seconds.

### Phase 6 — Hardened controls

Pilot phishing-resistant authentication strength, compliant/registered-device requirements, risk-based Conditional Access when licensed, and Token Protection only for supported clients/resources. Start report-only, use What If and sign-in logs, verify emergency access, then enforce only for the test pilot. Do not imply Token Protection has universal browser/platform coverage.

### Phase 7 — Detection and dashboard

Correlate sanitized Entra and lab metadata with a scenario ID. Provide panels for authentication timeline, identity/device/IP context, session fingerprint transition, Conditional Access evaluation, risk/detection signals, containment, and before/after comparison. Provide offline fixtures for event-day resilience.

### Phase 8 — Incident response showcase

Demonstrate alert validation, blocking new sign-ins when justified, session revocation, device investigation, sign-in/audit/mailbox/OAuth review as applicable, credential reset when evidence supports it, recovery, and sanitized evidence preservation.

### Phase 9 — Security review and rehearsal

Test exposure, DNS/TLS scope, routing, secret retention, authorization, rollback, kill switch, dashboard failure, internet failure, and offline backup. Freeze versions/configuration and checksum the release after three successful timed rehearsals.

### Phase 10 — Event execution

Restore a clean snapshot, verify checksums/routes/firewall/operators/test identities/policy state, announce the authorized simulation, run baseline, analyze telemetry, show response, reset, run hardened case, compare results, and explain control limitations. Stop immediately on any abort condition.

### Phase 11 — Teardown and after-action review

Stop the engine, cut connectivity, revoke test sessions, reset or disable identities, revert/destroy VMs, remove temporary DNS/TLS/endpoints, confirm no public exposure remains, retain only approved sanitized evidence, and publish lessons learned within the approved retention period.

## Scenario definitions

### Baseline

Use ordinary non-phishing-resistant MFA, an unmanaged test device, and deliberately limited session/device controls. Explain that successful MFA and protection of the resulting session are separate security properties.

### Hardened

Use phishing-resistant authentication, compliant/registered devices, risk-aware policies, supported token/device binding, monitoring, and response. Explain defense in depth; never present one control as a universal solution.

## Dashboard contract

Show only:

- Scenario/event IDs, timestamps, synthetic actor aliases, documentation-range IPs, device state, authentication strength, risk level, Conditional Access result, reason code, session fingerprint, and response status.

Forbid fields or values containing:

- `password`, `otp`, `cookie`, `authorization`, `access_token`, `refresh_token`, `id_token`, raw JWTs, session exports, or real user identifiers.

Use documentation networks `192.0.2.0/24`, `198.51.100.0/24`, and `203.0.113.0/24` for simulated public IPs.

## Definition of done

- Produce two repeatable seven-minute scenarios: baseline allowed and hardened blocked/restricted.
- Operate without production dependencies and preserve an offline demo fallback.
- Reset the environment in under 60 seconds.
- Prove through tests that dashboards, logs, recordings, backups, fixtures, and Git contain no authentication secrets.
- Show attack chain, relevant controls, detection evidence, response, limitations, and before/after comparison clearly from audience distance.
- Complete three clean rehearsals, event go/no-go review, teardown, and after-action report.

## Schedule

Use this default sequence relative to the event:

- T-8 to T-7 weeks: Phases 0-2.
- T-6 weeks: Phase 3.
- T-5 weeks: Phase 4.
- T-4 weeks: Phase 5 and start Phase 7.
- T-3 weeks: Phases 6 and 8.
- T-2 weeks: security review and corrections.
- T-1 week: Phase 9 and configuration freeze.
- Event day: Phase 10.
- T+1 day: Phase 11.

## First actions in a new thread

When invoked in a fresh repository:

1. Inspect the repository and local instructions without modifying unrelated files.
2. Confirm the current phase and list its unmet entry criteria.
3. Create or update a concise task plan.
4. Implement only the current approved phase.
5. Verify deliverables against the phase exit criteria.
6. Record decisions, risks, evidence, and the next gate in repository documentation.
7. Do not skip ahead to Evilginx staging before Phases 0-3 are approved.

## Authoritative defensive references

Prefer current official Microsoft documentation for:

- Entra token threats and defenses: <https://learn.microsoft.com/en-us/entra/identity/devices/concept-tokens-microsoft-entra-id>
- Protecting tokens: <https://learn.microsoft.com/en-us/entra/identity/devices/protecting-tokens-microsoft-entra-id>
- Token Protection requirements and limitations: <https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-token-protection>
- Authentication strengths: <https://learn.microsoft.com/en-us/entra/identity/authentication/concept-authentication-strengths>
- Conditional Access deployment: <https://learn.microsoft.com/en-us/entra/identity/conditional-access/plan-conditional-access>
- CA insights/reporting: <https://learn.microsoft.com/en-us/entra/identity/conditional-access/howto-conditional-access-insights-reporting>
- Emergency access: <https://learn.microsoft.com/en-us/entra/identity/role-based-access-control/security-emergency-access>
- Session revocation: <https://learn.microsoft.com/en-us/entra/identity/users/users-revoke-access>
- Safe phishing simulations: <https://learn.microsoft.com/en-us/defender-office-365/attack-simulation-training-get-started>

Check current documentation before asserting changing product support, licensing, or policy behavior.
