---
name: review
description: Phase 5 Code Review. Review a task's PR with the code-reviewer agent using /codex:rescue findings, then instruct the user to run the human-only Codex review commands.
argument-hint: TASK-NNN
disable-model-invocation: true
allowed-tools: Agent, Skill, Read, Glob, Grep, Bash(git:*)
---

# /sdlc:review — Phase 5: Code Review (first pass)

You are the main session orchestrating Phase 5 of `WORKFLOW.md` for task **$ARGUMENTS**.

## Branches and recent review log

!`git branch --list 'task/*' 2>/dev/null || true`

!`tail -n 15 docs/05-review/review-log.md 2>/dev/null || true`

## Steps

1. **Gate check.** The task must have an open PR (or a "PR" section in its ticket) and status
   In review. Otherwise stop.
2. **Codex rescue.** If this session has not already run `/codex:rescue` for this branch,
   invoke the `codex:rescue` skill now with a focused bug-hunting prompt for the branch diff.
   You may run it; subagents cannot. Keep the output verbatim for step 3.
3. Invoke the `sdlc:code-reviewer` subagent (`subagent_type: "sdlc:code-reviewer"`).
   Prompt: "Review $ARGUMENTS on its task branch against the default branch. Follow your full
   review standard. Codex rescue output follows; verify and classify every item:
   <paste rescue output>. Assign FND- IDs, write the review report and triage sheet under
   docs/05-review/, log the step, and give a verdict."
4. Relay the verdict, findings by severity, and report paths.
5. **Human-only Codex commands.** Tell the user, verbatim from the reviewer's instructions:
   run `/codex:review`; for core or complex changes also run `/codex:adversarial-review`;
   then check `/codex:result` and paste the output into `/sdlc:triage $ARGUMENTS`. You must not run
   `/codex:review`, `/codex:adversarial-review`, `/codex:status`, or `/codex:result` yourself.
6. Remind the user to record their Codex run with `/sdlc:log` (the logging rule applies to humans).
