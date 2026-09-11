# Gap analysis: <Feature or system>

Purpose: prove the design leaves nothing uncovered. Every row must end as Covered or a justified
N/A. A row marked Gap must carry an owner and a plan before the design gate can pass.

## 1. Requirements and stories

| ID | Title | Covered by | Status | Owner / plan if gap |
|----|-------|------------|--------|---------------------|
| REQ-NNN | | DES-NNN | Covered / N/A / Gap | |
| STORY-NNN | | DES-NNN | | |

## 2. Cross-cutting concerns

| Concern | Covered by | Status | Owner / plan if gap |
|---------|------------|--------|---------------------|
| Observability | | | |
| Reliability and failure handling | | | |
| Data lifecycle (migrations, retention, backup) | | | |
| Performance and scalability budgets | | | |
| Testability and test strategy | | | |
| CI/CD, environments, rollback | | | |
| Configuration and secrets | | | |
| API design standards | | | |
| Accessibility and i18n | | | |
| Compliance and privacy | | | |
| Operational ownership and runbooks | | | |

## 3. Security (OWASP Top 10, current edition)

| Code | Status | Reference |
|------|--------|-----------|
| A01:2025 | | threat-model §5 |
| ... | | |

## 4. Clean Architecture conformance

| Component | Layers defined | Dependency direction inward | Domain testable without I/O | Status |
|-----------|----------------|-----------------------------|-----------------------------|--------|

## 5. Open gaps

| Gap | Owner | Plan | Due |
|-----|-------|------|-----|
