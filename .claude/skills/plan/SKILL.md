---
name: plan
description: Phase 1 Plan. Turn a feature idea into an approved PRD, REQ- requirements with Given/When/Then scenarios, and STORY- tickets via the product-owner agent.
argument-hint: <feature description or PRD-NNN to revise>
disable-model-invocation: true
allowed-tools: Agent, Read, Glob, Grep
---

# /plan — Phase 1: Plan

You are the main session orchestrating Phase 1 of `WORKFLOW.md`. Do not draft planning documents
yourself; the `product-owner` agent does.

## Current plan backlog

!`cat docs/01-plan/backlog.md 2>/dev/null || true`

## Steps

1. Invoke the `product-owner` subagent with the Agent tool (`subagent_type: "product-owner"`).
   Prompt: "Plan mode. Requirement: $ARGUMENTS. Follow your Plan process end to end, write the
   PRD, requirements, and story tickets under docs/01-plan/, run the Plan gate checklist, and
   stop for approval."
2. If the agent stops with clarifying questions, relay them to the user verbatim, wait for
   answers, then re-invoke the agent with the answers appended.
3. Relay the agent's final report: files created, assumptions, open questions, gate checklist.
4. End with the approval reminder: the PRD and stories must be reviewed and marked Approved
   (approver and date in the document header) before `/design` may run. Offer `/log` to record
   the approval.

Never start design or write code from this skill.
