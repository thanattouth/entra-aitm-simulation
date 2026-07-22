# Entra AiTM Defensive Showcase

Safe planning and evidence repository for a governed, isolated Microsoft Entra
adversary-in-the-middle (AiTM) defensive showcase.

## Status

- Repository name: `entra-aitm-defensive-showcase`
- Current phase: **Phase 0 — Authorization and rules of engagement**
- Gate state: **OPEN — written approval is not yet recorded**
- Later phases: **Not authorized**

No simulation, tenant configuration, lab provisioning, public exposure, or
AiTM tooling may begin until the Phase 0 approval gate is closed. Evilginx is
treated only as a future user-managed black-box component; its configuration
and authentication material never belong in this repository.

## Start here

1. Complete [rules of engagement](docs/rules-of-engagement.md).
2. Resolve the open decisions and risks in the [project plan](docs/project-plan.md).
3. Obtain written approval from the required approvers.
4. Run `pwsh ./tests/Test-Phase0.ps1` and attach its sanitized output to the
   approval record.

## Safety boundary

Only a dedicated Entra test tenant, synthetic identities, test devices,
non-production workloads, and documentation-range example IP addresses are in
scope. Production tenants, identities, systems, networks, DNS, mail, data, and
endpoints are explicitly excluded. See [SECURITY.md](SECURITY.md) for handling
and abort requirements.

## Repository map

- `docs/` — governance, plans, runbooks, response, and teardown records
- `dashboard/` — future sanitized visualizations only
- `collector/` — future sanitized telemetry contracts and code
- `scenarios/` — future approved scenario definitions
- `detections/` — future defensive detection content
- `infra/` — future lab guardrails and infrastructure definitions
- `tests/` — automated safety and phase-gate checks
- `skill/` — the defensive showcase planning skill

This repository contains defensive planning material only. It must not contain
credentials, OTPs, cookies, authorization codes or headers, access/refresh/ID
tokens, raw JWTs, session exports, real-user identifiers, or operational
phishing/AiTM configuration.
