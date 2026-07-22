# Entra test-tenant blueprint

Status: **Phase 2 preparation draft — no tenant changes performed by this repo**

## Isolation requirements

- Use a dedicated Entra test tenant with its own `onmicrosoft.com` namespace.
- Do not add production guests, custom domains, applications, subscriptions,
  mail, data, devices, federation, synchronization, or cross-tenant trust.
- Use synthetic identities and non-production data only.
- Record the tenant ID and approved domains in the restricted local inventory,
  not audience fixtures.

## Roles and identities

| Purpose | Proposed identity/role | Constraint |
|---|---|---|
| Bootstrap administration | Dedicated cloud-only administrator | Used only to establish scoped roles and emergency access |
| Emergency access | Two cloud-only accounts; Global Administrator | Strong phishing-resistant credentials; excluded from blocking CA; monitored |
| Policy administration | Conditional Access Administrator | No routine Global Administrator use |
| Evidence review | Security Reader or Reports Reader | Read-only, least privilege |
| Baseline participant | Synthetic `baseline-user-01` | Ordinary test MFA; no production data |
| Hardened participant | Synthetic `hardened-user-01` | Phishing-resistant method and approved device condition |
| Validation identity | Synthetic unprivileged account | No administrative role |

Microsoft recommends two or more cloud-only emergency accounts, strong
authentication independent of normal admin methods, exclusion from blocking
Conditional Access policies, monitoring, and regular validation:
<https://learn.microsoft.com/en-us/entra/identity/role-based-access-control/security-emergency-access>.

## Groups

- `LAB-Baseline-Users`
- `LAB-Hardened-Users`
- `LAB-CA-Pilot`
- `LAB-Emergency-Access`
- `LAB-Dashboard-Readers`

Keep memberships explicit and capture a sanitized approval record before each
rehearsal. Dynamic membership is unnecessary for the first PoC.

## Test workload

Use a test-only application or Microsoft 365 test workload that contains no
production data and grants no production access. Record its application/resource
identifier and consent decision in the restricted inventory. Avoid broad tenant
consent and remove unused permissions.

## Conditional Access plan

All policies begin in **report-only**, target only `LAB-CA-Pilot`, and exclude
`LAB-Emergency-Access`. Microsoft recommends pilot deployment, emergency-account
exclusions, registered authentication methods, testing, and monitoring before
enforcement:
<https://learn.microsoft.com/en-us/entra/identity/conditional-access/plan-conditional-access>.

| Policy | Pilot intent | Initial state |
|---|---|---|
| `LAB-CA-BASELINE-MFA` | Observe ordinary MFA for baseline users/test workload | Report-only |
| `LAB-CA-HARDENED-AUTH-STRENGTH` | Require phishing-resistant authentication strength | Report-only |
| `LAB-CA-HARDENED-DEVICE` | Require compliant/registered device where supported | Report-only |
| `LAB-CA-RISK` | Observe risk-based result when licensed | Report-only; optional |
| `LAB-CA-TOKEN-PROTECTION` | Evaluate only supported clients/resources | Not created until support/license review |

Never imply that Token Protection or any single control covers all browsers,
platforms, and resources.

## Logging and evidence

At minimum review interactive sign-ins and audit changes. Entra sign-in logs
describe the identity, client/application, target resource, status, and policy
context, and require an appropriate read-only role:
<https://learn.microsoft.com/en-us/entra/identity/monitoring-health/concept-sign-ins>.

The collector must transform Entra data into the sanitized contract before
storage or display. Do not export authentication material, real identifiers, or
raw request/response headers.

## Phase 2 checklist

- [ ] Dedicated tenant created and tenant ID recorded privately.
- [ ] No production domain, guest, trust, application, subscription, or data.
- [ ] Two emergency accounts registered, stored, excluded, monitored, tested.
- [ ] Scoped admin and read-only roles assigned.
- [ ] Synthetic users and five groups created.
- [ ] Test-only workload assigned with least privilege.
- [ ] Required authentication methods and licenses confirmed.
- [ ] Sign-in/audit logs visible to the read-only evidence role.
- [ ] CA policies reviewed in report-only and scoped only to the pilot.

**Gate status: NOT STARTED. Exact tenant ownership and licenses are required.**
