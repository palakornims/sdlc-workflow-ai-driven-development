---
name: test
description: Phase 6 Test. Drive the qa-engineer agent and the Playwright planner, generator, and healer agents in order for one story, ending in an approved test report.
argument-hint: STORY-NNN
disable-model-invocation: true
allowed-tools: Agent, Read, Glob, Grep, Bash(npx playwright:*), Bash(npm run:*), Bash(dotnet test:*)
---

# /sdlc:test — Phase 6: Test

You are the main session orchestrating Phase 6 of `WORKFLOW.md` for **$ARGUMENTS**. The
`sdlc:qa-engineer` agent decides what happens; you invoke the Playwright agents it asks for, because
subagents cannot spawn agents. The `playwright-test` MCP server from `.mcp.json` must be
approved in this session.

## Existing specs and tests

!`ls specs/ tests/e2e/ 2>/dev/null || true`

!`tail -n 10 docs/06-test/test-log.md 2>/dev/null || true`

## Cycle

Steps 2 to 4 are **conditional**: run them only for scenarios the coverage audit marks as a
gap. A story whose tests were already written during Implement may go straight from step 1 to
step 5. That is a correct outcome, not a shortcut.

1. **Audit, then plan.** Invoke `sdlc:qa-engineer` (`subagent_type: "sdlc:qa-engineer"`): "Test
   phase for $ARGUMENTS. Verify preconditions (tasks Done, Code Review clean). Do the coverage
   audit first: for every acceptance scenario find whether a non-vacuous test already exists,
   proving non-vacuity by mutation for must-have scenarios. Then write the test plan under
   docs/06-test/ including the coverage audit table, prepare tests/e2e/seed.spec.ts, and tell
   me either the exact playwright-test-planner prompt for the gaps, or that there are no gaps."
2. **Explore (only if the audit found gaps).** Invoke `playwright-test-planner` with the
   prompt QA gave. It writes `specs/<story>.md` covering the gaps only. If QA reported no gaps,
   skip to step 5.
3. **Review plan.** Invoke `sdlc:qa-engineer`: "Review specs/<file> for $ARGUMENTS against the
   acceptance criteria; edit if needed; log; then list each test case with the exact
   playwright-test-generator prompt (test-suite, test-name, test-file, seed-file, body)."
4. **Generate.** Invoke `playwright-test-generator` once per case with the prompt QA gave.
5. **Review and run.** Invoke `sdlc:qa-engineer`: "Review the generated tests under tests/e2e/
   against your quality standard, run `dotnet test` and `npx playwright test`, log results, and
   list failing tests with a playwright-test-healer prompt for each."
6. **Heal.** Invoke `playwright-test-healer` per failing test with the prompt QA gave.
7. **Triage and report.** Invoke `sdlc:qa-engineer`: "Triage healer outcomes for $ARGUMENTS
   (accept test patches; open DEF- for application defects), write the test report, log every
   step, run the Test gate checklist, and stop for approval."
8. Relay the verdict, coverage table, defects, and report path. Application defects go to
   `/sdlc:triage <TASK>` for the task they belong to. Remind: the test report must be Approved before
   `/sdlc:validate`.

Repeat steps 5 to 7 until the suite is green or every failure has a DEF-.
