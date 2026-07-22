# User-managed black-box integration contract

Status: **Design only — operational staging is not authorized**

Evilginx, if later approved and installed by the user, is treated as an opaque
component. This repository does not contain its installation commands,
phishlets, cloned sign-in content, proxy/capture configuration, lure material,
authentication data, or replay procedures.

## Required lifecycle metadata

Record outside operational secrets:

- Component owner and backup operator
- Pinned version and source
- Installer/binary checksum
- Configuration revision identifier (not configuration content)
- Approved tenant, synthetic identities, domains, IPs, and time window
- External references to start/stop/reset and kill-switch procedures
- Clean pre-stage and post-reset snapshot identifiers

## Evidence handoff

Never connect the collector to raw engine logs. The approved operator must create
a separate sanitized event containing only the JSON-schema allowlist. The
adapter validates the event before the collector accepts it.

```text
black box -> operator sanitizer -> schema validator -> collector -> dashboard
                 |
                 +-> rejects forbidden fields/values and stores nothing
```

The handoff carries scenario state and fingerprints, not authentication
material. A fingerprint must be a one-way value that cannot be used as a session
credential.

## Abort conditions

Stop immediately on a production identity/domain/tenant, unexpected public
reachability, raw authentication material, unauthorized access, missing scope
record, checksum/config drift, or failure of the sanitizer/kill switch.

## Exit review

- [ ] Phases 0-3 are approved.
- [ ] Owner, version, checksum, revision, and scope are recorded.
- [ ] No raw-log integration exists.
- [ ] Sanitized contract tests pass.
- [ ] Kill switch is demonstrated from a clean snapshot.
- [ ] Security and Network reviewers sign the staging decision.
