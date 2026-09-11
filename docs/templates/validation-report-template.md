# Validation: STORY-NNN <Title> (run <n>)

| Field | Value |
|-------|-------|
| Story | STORY-NNN |
| Requirements | REQ-NNN, ... |
| PRD | PRD-NNN |
| Build / commit | `<sha>` |
| Environment | BASE_URL=<url> |
| Test report | test-report-STORY-NNN-<n>.md (verdict: Ready for Validation) |
| Validator | product-owner agent (validation mode) |
| Date | <YYYY-MM-DD HH:MM> |
| Verdict | Accept / Accept with notes / Reject |
| Signed off by | <human product owner> on <date> |

## 1. Summary (in user terms)

What the user can now do, and whether it matches what was asked.

## 2. Scenario walkthrough

| REQ / STORY | Scenario | Priority | Result | Meets intent? | Evidence | VAL-ID |
|-------------|----------|----------|--------|---------------|----------|--------|
| REQ-001 | Given ... When ... Then ... | Must | Pass / Fail / Blocked | Yes / No: reason | screenshot / response path | |

## 3. Non-goals and scope check

| Item | Expected | Observed | Result |
|------|----------|----------|--------|
| Non-goal: ... | Not built | | |
| Unrequested behaviour found | None | | |

## 4. Non-functional requirements

| REQ | Budget | Evidence | Result |
|-----|--------|----------|--------|

## 5. Findings

| VAL-ID | Severity | Scenario / REQ | Finding | Route | Linked ID (DEF- / REQ-) | Owner | Status |
|--------|----------|----------------|---------|-------|--------------------------|-------|--------|

Routes: Built wrong → DEF- to dotnet-developer (Phase 5 loop) · Built the wrong thing → REQ-
change in Plan, re-approve · Scope creep → keep (add REQ-) or remove · Accept with note.

## 6. Traceability summary

Pointer to `traceability-STORY-NNN.md`. Must-have requirements with a broken link: none / list.

## 7. Retrospective input

| Deviation from plan | Why | Recommendation (WORKFLOW.md / CLAUDE.md / template) |
|---------------------|-----|------------------------------------------------------|

## 8. Sign-off

- [ ] Human product owner reviewed this report
- [ ] Findings routed and logged
- [ ] Release approved / Returned to phase: ___
