# TASK-NNN: <Title>

| Field | Value |
|-------|-------|
| Epic | EPIC-NNN |
| Tier | 0 Foundation / 1 Walking skeleton / 2 Main feature / 3 Components / 4 Hardening / 5 Could-have |
| Milestone | M1 |
| Story | STORY-NNN |
| Requirements | REQ-NNN |
| Design elements | DES-NNN |
| Layers touched | entities / use cases / interface adapters / frameworks |
| Size | S / M / L |
| Risk | Low / Medium / High: <reason> |
| Status | **See `docs/03-tasks/backlog.md`** - the backlog row is the single source of truth. Do not repeat the status here. |
| Depends on | TASK-NNN |
| Blocks | TASK-NNN |
| Can run in parallel with | TASK-NNN |
| Branch | task/TASK-NNN-<kebab-title> |
| PR | <link when opened> |

## Goal

One or two sentences: what this task delivers and why it comes at this point in the order.

## Scope

Expected files or modules to create or change, by layer. What is explicitly not part of this task.

## Sub-tasks

- [ ] <sub-task>
- [ ] <sub-task>
- [ ] Write tests listed below
- [ ] Update docs / backlog status

## Acceptance criteria

```gherkin
Scenario: <name>
  Given <precondition>
  When <action>
  Then <observable outcome>
```

## Test expectation

| Level | Tests that must exist when done |
|-------|---------------------------------|
| Unit | |
| Integration / contract | |
| End-to-end | |

## Security expectation

Threat-model controls this task must implement (OWASP code and DES reference), or "none".

## Definition of Ready

- [ ] Design approved
- [ ] Acceptance criteria present
- [ ] Dependencies merged or scheduled earlier
- [ ] Test expectation defined
- [ ] No open question blocks this task

## Definition of Done

- [ ] PR merged after human review
- [ ] CI green (lint, types, tests)
- [ ] Tests in the test expectation exist and pass
- [ ] Acceptance criteria demonstrated
- [ ] Documentation updated where affected
- [ ] Status set to Done in `docs/03-tasks/backlog.md`

## Review and fix log

Append-only. Links to every review report and triage sheet for this task, and one line per fix
commit. Kept in sync with `docs/05-review/review-log.md`.

| Timestamp | Actor | Action | Finding(s) | Artifact / commit |
|-----------|-------|--------|------------|-------------------|

## Notes

Open questions, assumptions, links.
