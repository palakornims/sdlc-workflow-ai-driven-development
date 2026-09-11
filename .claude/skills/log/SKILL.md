---
name: log
description: Append a human action to the correct workflow log (review, test, validation, or task ticket) so the mandatory logging rule is satisfied for approvals, Codex runs, dismissals, and sign-offs.
argument-hint: <action> [TASK-NNN|STORY-NNN] [FND-/DEF-/VAL- ids] [detail]
disable-model-invocation: true
allowed-tools: Read, Edit, Bash(date:*), Glob, Grep
---

# /log — record a human action

Timestamp now: !`date '+%Y-%m-%d %H:%M'`

Entry to record: $ARGUMENTS

## Rules

- Actor is `human` unless the entry names a role (tech lead, product owner, reviewer).
- Choose the log from the IDs and action words:
  - `FND-`, "codex", "review", "dismiss", "merge", "PR approve" → `docs/05-review/review-log.md`
    **and** the matching `docs/05-review/TRIAGE-TASK-NNN-<n>.md` activity log.
  - `DEF-`, "test", "coverage" → `docs/06-test/test-log.md`.
  - `VAL-`, "sign off", "release", "UAT" → `docs/07-validation/validation-log.md`.
  - "approve" of a PRD, design, ADR, or backlog → set that document's `Status | Approved`,
    `Approver`, and `Approved on` header fields, and log in the log file of the next phase.
  - Any entry naming a `TASK-` or `STORY-` also gets a row in that ticket's "Review and fix
    log" (tasks) or a "Validation" line (stories).
- Append only. Never edit or delete existing rows. Use the table format already in the file:
  `| <timestamp> | <actor> | <action> | <ids> | <detail> | <artifact> |`.
- If the target is ambiguous, ask one question, then write.
- Confirm back exactly what was written and where.
