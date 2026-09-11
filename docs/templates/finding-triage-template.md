# TRIAGE-TASK-NNN-<n>: Review findings triage

| Field | Value |
|-------|-------|
| Task | TASK-NNN |
| Branch / PR | task/TASK-NNN-<title> / <link> |
| Review report | REVIEW-TASK-NNN-<n> |
| Sources | code-reviewer / codex:rescue / codex:review / codex:adversarial-review / human |
| Opened | <YYYY-MM-DD HH:MM> |
| Status | Open / Fixing / Re-review requested / Closed |

Every finding from every source gets one row and a permanent ID (`FND-NNN`, sequential across
the repo). A finding is never deleted; it is closed with a decision and evidence.

## Findings register

| ID | Source | Severity | Area | File:line | Finding | Architect decision | Developer decision | Final decision | Evidence / commit | Status |
|----|--------|----------|------|-----------|---------|--------------------|--------------------|----------------|-------------------|--------|
| FND-001 | codex:review | Major | Security | | | Fix (design intact) / Design change (ADR-NNNN) / Dismiss: reason | Fix / Dismiss: reason / Escalate | Fix / Dismiss / Design change | `<sha>` | Open / Fixed / Dismissed / Escalated |

Decision rules:
- **Fix**: genuine defect, design unaffected. Developer fixes on the same branch, one commit per
  finding, message `TASK-NNN: fix FND-NNN <summary>`.
- **Design change**: the finding exposes a design flaw. Architect updates the design document
  and/or ADR, gets it re-approved, then the developer fixes. Task returns to Phase 4 for the
  affected part.
- **Dismiss**: not a defect, not reproducible, or out of scope. Reason is mandatory; a human
  must confirm dismissals of Blocker or Major severity.
- **Escalate**: architect and developer disagree, or the decision needs the tech lead or
  product owner. Named owner and due date required.

## Activity log

Append-only. One line per action, newest last. Never edit or delete earlier lines.

| Timestamp | Actor | Action | Finding(s) | Detail | Artifact |
|-----------|-------|--------|------------|--------|----------|
| <YYYY-MM-DD HH:MM> | code-reviewer | Opened triage | FND-001..FND-00N | N findings registered from REVIEW-TASK-NNN-<n> | this file |
| | human | Ran /codex:review | | Pasted output; N new findings | |
| | solution-architect | Reviewed | FND-00X | Decision and reason | ADR-NNNN if any |
| | dotnet-developer | Reviewed | FND-00X | Decision and reason | |
| | dotnet-developer | Fixed | FND-00X | What changed, files, quality loop result | commit `<sha>` |
| | code-reviewer | Re-reviewed | FND-00X | Verified fixed / not fixed | REVIEW-TASK-NNN-<n+1> |
| | human | Closed triage | all | All findings Fixed or Dismissed | |
