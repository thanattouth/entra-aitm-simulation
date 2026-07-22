# Entra AiTM defensive showcase site

Local-only audience storyboard for the defensive showcase. It compares a
synthetic baseline with a hardened scenario and displays allowlisted metadata
that conforms to `../collector/schema/sanitized-event.schema.json`.

The site is not a sign-in service. It has no credential, OTP, cookie, or token
collection and does not clone Microsoft branding or pages.

## Run locally

Prerequisite: Node.js `>=22.13.0`.

```bash
npm install
npm run dev
```

Validate with:

```bash
npm run build
npm test
```

Keep the site on localhost while dependency audit findings remain open. Do not
publish it or place it behind router port forwarding.
