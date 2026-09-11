---
name: implement
description: Phase 4 Implement. Implement one approved TASK- ticket on its own branch via the dotnet-developer agent, then run /codex:rescue on the result.
argument-hint: TASK-NNN
disable-model-invocation: true
allowed-tools: Agent, Skill, Read, Glob, Grep, Bash(git:*)
---

# /sdlc:implement — Phase 4: Implement

You are the main session orchestrating Phase 4 of `WORKFLOW.md` for task **$ARGUMENTS**.

## Task backlog

!`cat docs/03-tasks/backlog.md 2>/dev/null || echo "no backlog found"`

## Git state

!`git status --short --untracked-files=all 2>/dev/null | head -20 || true`

## Steps

1. **Gate check.** Plan, design, and breakdown documents must be Approved, and the task's
   Definition of Ready must be fully checked in its ticket under `docs/03-tasks/tickets/`.
   Working tree must be clean. Otherwise stop and say what blocks the task.
2. Invoke the `sdlc:dotnet-developer` subagent (`subagent_type: "sdlc:dotnet-developer"`).
   Prompt: "Implement $ARGUMENTS. Follow your full Implement process: verify readiness, create
   branch task/$ARGUMENTS-<title>, invoke the relevant dotnet-skills before coding, implement
   inner layers first with tests, run the quality loop (format, build -warnaserror, test,
   vulnerable-package scan, slopwatch), self-review against the OWASP table, update the task
   status, open the PR, and stop for human review."
3. Relay the developer's report: branch, PR, commands run, deviations, gate checklist.
4. **Codex rescue (main session only).** Now invoke the `codex:rescue` skill with the Skill
   tool. Prompt Codex to investigate the branch diff for bugs, naming the task and focusing on
   core logic if touched (auth model, per-user data isolation, JWT issuance/validation, EF Core
   migrations and queries, threat-model controls). Return Codex's output verbatim. Respect
   `.codex/config.toml`; pass no `--model` or `--effort`.
5. Tell the user the task is ready for `/sdlc:review $ARGUMENTS`, which will pass the rescue output
   to the reviewer. Do not merge anything.
