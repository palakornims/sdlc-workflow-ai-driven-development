# Threat model: <Feature or system>

| Field | Value |
|-------|-------|
| Status | Draft / Approved |
| OWASP Top 10 edition used | 2025 |
| Architecture doc | architecture-<feature>.md |

## 1. Assets

What must be protected, its classification (public / internal / confidential / restricted),
and the owner.

## 2. Trust boundaries and entry points

Diagram or list of boundaries (browser to API, API to database, service to third party, CI to
production) and every entry point crossing them.

## 3. Actors and abuse cases

For each actor (including malicious insiders and compromised dependencies): what they could
attempt. Write abuse cases in Given / When / Then form so they become tests.

## 4. STRIDE per boundary

| Boundary | Spoofing | Tampering | Repudiation | Info disclosure | Denial of service | Elevation of privilege |
|----------|----------|-----------|-------------|-----------------|-------------------|------------------------|

## 5. OWASP Top 10:2025 controls

| Code | Category | Control in this design | Implemented by | Status |
|------|----------|------------------------|----------------|--------|
| A01:2025 | Broken Access Control | | DES-NNN | Covered / N/A (reason) / Gap |
| A02:2025 | Security Misconfiguration | | | |
| A03:2025 | Software Supply Chain Failures | | | |
| A04:2025 | Cryptographic Failures | | | |
| A05:2025 | Injection | | | |
| A06:2025 | Insecure Design | | | |
| A07:2025 | Authentication Failures | | | |
| A08:2025 | Software or Data Integrity Failures | | | |
| A09:2025 | Security Logging and Alerting Failures | | | |
| A10:2025 | Mishandling of Exceptional Conditions | | | |

## 6. Residual risks

| Risk | Severity | Accepted by | Date | Review by |
|------|----------|-------------|------|-----------|

## 7. Security requirements added

New `REQ-` items proposed to the product owner as a result of this model.
