---
name: validate
description: Phase 7 Validation. The product-owner agent walks every acceptance scenario on the running system, builds traceability, routes VAL- findings, and stops for release sign-off.
argument-hint: STORY-NNN [BASE_URL]
disable-model-invocation: true
allowed-tools: Agent, Read, Glob, Grep
---

# /sdlc:validate — Phase 7: Validation

You are the main session orchestrating Phase 7 of `WORKFLOW.md` for **$ARGUMENTS**.

## Test report status

!`grep -H -m1 -E '^\| Verdict' docs/06-test/test-report-*.md 2>/dev/null || echo "no test reports found"`

## Steps

1. **Gate check.** The story's test report must exist with verdict Ready for Validation and be
   Approved; every task Done; no open FND- or Blocker/Critical DEF-. A running build of the
   tested commit must be reachable (BASE_URL from the arguments or the test report). Otherwise
   stop and say what is missing.
2. Invoke the `sdlc:product-owner` subagent (`subagent_type: "sdlc:product-owner"`).
   Prompt: "Validation mode for $ARGUMENTS. Verify preconditions, assemble the acceptance set,
   build the traceability matrix, walk every Given/When/Then scenario on the running system
   with evidence (browser tools for UI, curl for API), check non-goals and scope, classify
   VAL- findings with routes, write the validation report, traceability, release notes, and
   retrospective input under docs/07-validation/, log every step, and give a verdict."
3. Relay the verdict, scenario results, VAL- findings with routes, and report paths.
4. Route findings: built wrong → `/sdlc:triage <TASK>` with the DEF-; built the wrong thing →
   `/sdlc:plan PRD-NNN` to revise the requirement; scope creep → ask the user to decide.
5. Ask the human product owner to sign off with `/sdlc:log`, or name the phase to return to.
   Never release from this session.
