# Isolated lab infrastructure package

Status: **Prepared for review; not authorized or deployed**

This directory defines a deny-by-default Hyper-V lab plan without changing the
host. It deliberately contains no router forwarding, public ingress, Evilginx
installation, tenant configuration, credentials, certificates, or secrets.

## Deliverables

- `topology.md` — zones, trust boundaries, flows, isolation requirements, and
  kill-switch behavior.
- `config/lab.example.psd1` — reviewed configuration contract with required
  approval placeholders.
- `scripts/Test-LabConfig.ps1` — offline semantic validation; no host changes.
- `scripts/Test-LabHost.ps1` — read-only Hyper-V host readiness inventory.
- `scripts/New-LabPlan.ps1` — produces a sanitized JSON implementation plan;
  it does not create switches, disks, VMs, routes, or firewall rules.

## Safe workflow

```powershell
Copy-Item infra/config/lab.example.psd1 infra/config/lab.local.psd1
# Complete exact, approved values in lab.local.psd1. Do not commit that file.
pwsh infra/scripts/Test-LabConfig.ps1 -ConfigPath infra/config/lab.local.psd1
pwsh infra/scripts/Test-LabHost.ps1 -ConfigPath infra/config/lab.local.psd1
pwsh infra/scripts/New-LabPlan.ps1 -ConfigPath infra/config/lab.local.psd1
```

`lab.local.psd1` and generated plans are ignored because they may disclose
internal host/network inventory. Store approval records outside Git and put
only their non-secret references in local configuration.

## Gate

Generating a plan is not authorization to deploy it. Provisioning remains
blocked until Phases 0-2 pass, Security and Network approve the exact topology,
the production-deny list is complete, and the named kill-switch owner accepts
the shutdown procedure. Deployment tooling is intentionally absent while this
gate is open.

No public ingress is part of this design. Any future exception requires a new
written governance and network decision for an exact design.
