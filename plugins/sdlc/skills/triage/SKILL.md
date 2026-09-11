---
name: triage
description: Phase 5 triage-and-fix loop. Register Codex or human review findings, get solution-architect and dotnet-developer decisions, fix agreed findings one commit each, and re-review, logging every step.
argument-hint: TASK-NNN [paste Codex /codex:result output or finding list]
disable-model-invocation: true
allowed-tools: Agent, Read, Glob, Grep, Bash(git:*)
---

# /sdlc:triage — Phase 5: findings triage and fix loop

You are the main session running the triage loop of `WORKFLOW.md` Phase 5. The first word of
the arguments is the task ID; everything after it is review output to register.

Arguments: $ARGUMENTS

## Open triage sheets

!`ls docs/05-review/TRIAGE-*.md 2>/dev/null || echo "none"`

## Loop (run every step; stop only where stated)

1. **Register.** Invoke `sdlc:code-reviewer` (`subagent_type: "sdlc:code-reviewer"`): "Register the
   following review output for <TASK> as FND- findings in the triage sheet, verify and classify
   each item, log the step: <output>". If the arguments contain no output, skip to step 2 using
   the existing triage sheet.
2. **Architect decision.** Invoke `sdlc:solution-architect`: "Review-findings triage mode for
   <TASK>. Read docs/05-review/TRIAGE-<TASK>-<n>.md, record an Architect decision for every
   finding (Fix / Design change with ADR / Dismiss with reason / Escalate), update design
   documents if needed, and log every decision."
   If any finding is Design change, stop and tell the user the design needs re-approval before
   fixes proceed; resume with `/sdlc:triage <TASK>` after approval.
3. **Developer decision and fixes.** Invoke `sdlc:dotnet-developer`: "Review-findings triage and fix
   mode for <TASK>. Record your Developer decision per finding, fill Final decisions where the
   two columns agree, fix only Final decision = Fix on the existing branch, one commit per
   finding `<TASK>: fix FND-NNN <summary>`, quality loop green, log every change with its SHA,
   set the sheet to Re-review requested."
   If the developer reports Escalate or disagreement, relay it and stop for the human.
4. **Re-review.** Invoke `sdlc:code-reviewer`: "Re-review <TASK>: verify every finding marked Fixed
   in the triage sheet against the new commits, write REVIEW-<TASK>-<n+1>, log, and give a
   fresh verdict."
5. If findings remain Open, summarise and tell the user to run `/sdlc:triage <TASK>` again after the
   remaining decisions. If none are Open, tell the user the PR is ready for their approval and
   merge, and to confirm any dismissed Blocker or Major findings with `/sdlc:log`.

Never fix findings yourself in this session; never merge.
