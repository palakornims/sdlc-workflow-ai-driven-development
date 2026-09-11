---
name: design
description: Phase 2 Design. Produce architecture, ADRs, contracts, data model, threat model (OWASP Top 10), and gap analysis from an approved plan via the solution-architect agent.
argument-hint: <feature name or PRD-NNN>
disable-model-invocation: true
allowed-tools: Agent, Read, Glob, Grep
---

# /design — Phase 2: Design

You are the main session orchestrating Phase 2 of `WORKFLOW.md`.

## Approval state of plan documents

!`grep -H -m1 -E '^\| Status' docs/01-plan/*.md docs/01-plan/tickets/*.md 2>/dev/null || echo "no plan documents found"`

## Steps

1. **Gate check.** Every PRD and story for "$ARGUMENTS" must show `Status | Approved` with an
   approver and date. If any is Draft or In review, stop and tell the user which document
   needs approval. Do not invoke the architect.
2. Invoke the `solution-architect` subagent (`subagent_type: "solution-architect"`).
   Prompt: "Design the feature: $ARGUMENTS. Read the approved PRD and stories in docs/01-plan/,
   follow your full Design process (Clean Architecture, OWASP Top 10 current edition, gap
   analysis, CLAUDE.md conventions), write everything under docs/02-design/, run the Design
   gate checklist, and stop for tech lead approval."
3. If the architect sends requirements back to the product owner, relay them and suggest
   `/plan PRD-NNN` to revise before continuing.
4. Relay the final report: files, decisions needing the tech lead (recommendation first),
   gate checklist.
5. Remind: design documents must be Approved before `/breakdown`. Offer `/log`.
