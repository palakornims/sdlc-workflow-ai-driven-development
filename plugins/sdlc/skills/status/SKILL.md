---
name: status
description: Show where every feature sits in the workflow (approvals, tasks, open findings, defects, validation) and the next command to run.
argument-hint: [STORY-NNN|TASK-NNN]
disable-model-invocation: true
allowed-tools: Read, Glob, Grep
---

# /sdlc:status — workflow state

Filter: $ARGUMENTS

## Document approvals

!`grep -H -m1 -E '^\| Status' docs/01-plan/*.md docs/01-plan/tickets/*.md docs/02-design/*.md docs/03-tasks/*.md 2>/dev/null || echo "no documents yet"`

## Task backlog

!`sed -n '/^## Tasks/,$p' docs/03-tasks/backlog.md 2>/dev/null || true`

## Open findings (triage sheets)

!`grep -H -E '\| (Open|Escalated) \|' docs/05-review/TRIAGE-*.md 2>/dev/null || echo "none"`

## Open defects

!`grep -E '\| (Open|In progress) \|' docs/06-test/defects.md 2>/dev/null || echo "none"`

## Latest log lines

!`for f in docs/05-review/review-log.md docs/06-test/test-log.md docs/07-validation/validation-log.md; do echo "### $f"; tail -n 5 "$f" 2>/dev/null; done || true`

## Report

Summarise, filtered to the argument if given:

1. Each story or feature and the furthest phase it has reached, with what is blocking it
   (unapproved document, task not Done, open FND-, open DEF-, missing test report).
2. Tasks by status.
3. Open findings and defects with owners.
4. **Next command** for each item: one of `/sdlc:plan`, `/sdlc:design`, `/sdlc:breakdown`,
   `/sdlc:implement TASK-NNN`, `/sdlc:review TASK-NNN`, `/sdlc:triage TASK-NNN`, `/sdlc:test STORY-NNN`,
   `/sdlc:validate STORY-NNN`, or a `/sdlc:log` the human still owes.

Do not change any file.
