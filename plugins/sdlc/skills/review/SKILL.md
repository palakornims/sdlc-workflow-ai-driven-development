---
name: review
description: Phase 5 Code Review. Review a task's PR with the code-reviewer agent plus a second independent reviewer - Codex (/codex:rescue and the human-only Codex commands) when Codex review is on, otherwise a Sonnet second-opinion review.
argument-hint: TASK-NNN
disable-model-invocation: true
allowed-tools: Agent, Skill, Read, Glob, Grep, Bash(git:*)
---

# /sdlc:review — Phase 5: Code Review (first pass)

You are the main session orchestrating Phase 5 of `WORKFLOW.md` for task **$ARGUMENTS**.

## Branches and recent review log

!`git branch --list 'task/*' 2>/dev/null || true`

!`tail -n 15 docs/05-review/review-log.md 2>/dev/null || true`

## Codex review setting

!`cat sdlc.config.json 2>/dev/null || echo "no sdlc.config.json: codexReview is false"`

Codex review is **on** only if `codexReview` is `true` above. Every review gets a second,
independent reviewer: Codex when on, a Sonnet second opinion when off or when Codex turns out
to be unavailable. When off, never call any `codex:*` skill.

## Steps

1. **Gate check.** The task must have an open PR (or a "PR" section in its ticket) and status
   In review. Otherwise stop.
2. **Second reviewer.**
   - **Codex on:** if this session has not already run `/codex:rescue` for this branch, invoke
     the `codex:rescue` skill now with a focused bug-hunting prompt for the branch diff. You may
     run it; subagents cannot. Keep the output verbatim for step 3. If the skill is missing or
     Codex fails (not installed, not logged in, no subscription, quota), note
     "Codex unavailable: <reason>" and fall through to the Sonnet review below.
   - **Codex off or unavailable:** invoke the `sdlc:code-reviewer` subagent with
     `subagent_type: "sdlc:code-reviewer"` and `model: "sonnet"`. Prompt: "Second-opinion mode
     for $ARGUMENTS. Independently review the task branch diff against the default branch for
     bugs, security issues (OWASP Top 10:2025, threat-model controls), Clean Architecture
     violations, and missing tests, focusing on core logic if touched. Write no files and assign
     no FND- IDs; return a numbered finding list with file, line, severity, and evidence."
     Keep the output verbatim for step 3.
3. Invoke the `sdlc:code-reviewer` subagent (`subagent_type: "sdlc:code-reviewer"`, no model
   override). Prompt: "Review $ARGUMENTS on its task branch against the default branch. Follow
   your full review standard. Codex review: <on | off | unavailable: reason>. Second reviewer
   output (<codex:rescue | sonnet-review>) follows; verify and classify every item and register
   it with that source: <paste output>. Assign FND- IDs, write the review report and triage
   sheet under docs/05-review/, log the step, and give a verdict."
4. Relay the verdict, findings by severity (including how many second-reviewer items were
   confirmed), and report paths.
5. **Human-only Codex commands (only if Codex on and it ran).** Tell the user, verbatim from the
   reviewer's instructions: run `/codex:review`; for core or complex changes also run
   `/codex:adversarial-review`; then check `/codex:result` and paste the output into
   `/sdlc:triage $ARGUMENTS`. You must not run `/codex:review`, `/codex:adversarial-review`,
   `/codex:status`, or `/codex:result` yourself.
   Otherwise: tell the user the next step is `/sdlc:triage $ARGUMENTS` for the findings (or
   their PR approval if there are none).
6. If Codex ran, remind the user to record their Codex run with `/sdlc:log` (the logging rule
   applies to humans).
