# Security policy

## Purpose and boundary

This repository supports an authorized defensive showcase in an isolated test
environment. It does not authorize activity against production, third parties,
or any identity, domain, IP address, device, application, or network that is
not explicitly listed in the approved rules of engagement.

Do not commit operational Evilginx configuration, phishlets, cloned sign-in
content, capture configuration, lure material, session replay procedures, or
authentication material.

## Prohibited data

Do not store raw passwords, OTPs, cookies, authorization codes or headers,
access tokens, refresh tokens, ID tokens, JWTs, session exports, or real-user
identifiers in Git, logs, dashboards, fixtures, screenshots, recordings,
backups, or support tickets. Use synthetic aliases, hashes/fingerprints,
sanitized metadata, and documentation networks only.

## Mandatory abort conditions

Immediately stop the activity, activate the named kill-switch process when
applicable, preserve only approved sanitized evidence, and notify the contacts
in `docs/rules-of-engagement.md` if any of these occur:

- A production or otherwise non-approved identity, tenant, domain, IP, device,
  workload, data set, or network appears.
- Authentication material is displayed, logged, retained, or disclosed.
- Unexpected public reachability or unauthorized access is detected.
- Production impact, routing, trust, DNS, mail, or application dependency is
  observed.
- Scope, timing, approval, or stop-authority status becomes uncertain.

## Reporting

Use the approved private contact path in the rules of engagement. Do not place
secrets or real identifiers in an issue. Until contacts are completed and the
Phase 0 record is signed, report concerns to the project sponsor and treat all
active testing as prohibited.
