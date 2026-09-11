---
name: breakdown
description: Phase 3 Breakdown. Decompose an approved design into tiered TASK- tickets, delivery plan, and execution-ordered backlog via the project-manager agent.
argument-hint: <feature name>
disable-model-invocation: true
allowed-tools: Agent, Read, Glob, Grep
---

# /breakdown — Phase 3: Breakdown

You are the main session orchestrating Phase 3 of `WORKFLOW.md`.

## Approval state of plan and design documents

!`grep -H -m1 -E '^\| Status' docs/01-plan/*.md docs/02-design/*.md docs/02-design/adr/*.md 2>/dev/null || echo "no documents found"`

## Steps

1. **Gate check.** Plan documents and the architecture, ADRs, and gap analysis for
   "$ARGUMENTS" must all be Approved. Otherwise stop and name the missing approval.
2. Invoke the `project-manager` subagent (`subagent_type: "project-manager"`).
   Prompt: "Break down the feature: $ARGUMENTS. Read the approved plan and design, follow your
   full Breakdown process (tiers: foundation, walking skeleton, main feature, components,
   hardening, could-haves), write task tickets, delivery plan, and backlog under docs/03-tasks/,
   run the Breakdown gate checklist, and stop for tech lead approval."
3. If the PM sends design elements back, relay them and suggest `/design` to revise.
4. Relay the final report: milestones, task count, critical path, human-input tasks, gate.
5. Remind: the backlog must be Approved before `/implement`. Offer `/log`.
