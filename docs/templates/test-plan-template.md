# Test plan: STORY-NNN <Title>

| Field | Value |
|-------|-------|
| Story | STORY-NNN |
| Requirements | REQ-NNN, ... |
| Tasks under test | TASK-NNN, ... |
| Author | qa-engineer agent |
| Approver | <name> |
| Status | Draft / Approved |
| Environment | BASE_URL=<url>; seed: `tests/e2e/seed.spec.ts`; credentials via env vars |

## 1. Strategy

Which levels cover which scenarios and why. Reference the design's test strategy and budgets.

## 2. Scenario matrix

| TEST-ID | Source (REQ/STORY) | Scenario (Given / When / Then) | Level | Priority | Playwright spec / test file | Status |
|---------|--------------------|--------------------------------|-------|----------|-----------------------------|--------|

## 3. Negative and edge cases

| TEST-ID | Source | Case | Level |
|---------|--------|------|-------|

## 4. Security abuse cases (from threat model)

| TEST-ID | OWASP code | Abuse case | Level |
|---------|------------|------------|-------|

## 5. Test data and fixtures

## 6. Out of scope

## 7. Playwright agent hand-offs

| Step | Agent | Input | Output | Done |
|------|-------|-------|--------|------|
| Plan | playwright-test-planner | this file, seed | `specs/STORY-NNN-*.md` | [ ] |
| Generate | playwright-test-generator | each case in spec | `tests/e2e/...` | [ ] |
| Heal | playwright-test-healer | failing tests | patched tests or app-defect report | [ ] |
