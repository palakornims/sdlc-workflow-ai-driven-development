# AI-Driven Development Workflow

A seven-phase software delivery workflow in which an AI coding agent (Claude Code) does the bulk of
the drafting and execution, and humans own decisions and approvals. Every phase produces a
versioned artifact in the repo, and every phase ends with a gate a human must pass before the next
phase begins.

```
Plan ──▶ Design ──▶ Breakdown ──▶ Implement ──▶ Code Review ──▶ Test ──▶ Validation
  ▲                                                                          │
  └──────────────────────── feedback / new iteration ────────────────────────┘
```

## Mandatory rule: document and approve before development

**Every Plan, Design, and Breakdown phase MUST create its document and note down the details in
the repo, and that document MUST be approved by a human before any development starts.**

- No code is written for a feature until `docs/01-plan/`, `docs/02-design/`, and
  `docs/03-tasks/` for that feature exist, are filled in with the details, and are approved.
- Approval is recorded by merging the document PR (or an explicit sign-off note in the document
  with the approver's name and date).
- An AI agent asked to implement something without approved documents must stop and produce the
  missing documents first, then wait for approval.
- Changes to scope or design during development go back into the documents and are re-approved
  before the changed work continues.

## Mandatory rule: log every step and change

**Every step an agent or human takes in the workflow, and every change to code or documents
that results from a review, MUST be logged in the repo at the time it happens.**

- Review findings get a permanent `FND-NNN` ID and are never deleted, only closed with a
  decision (Fix / Dismiss with reason / Design change / Escalate) and evidence.
- Each review cycle has a triage sheet (`docs/05-review/TRIAGE-TASK-NNN-<n>.md`) with a
  findings register and an append-only activity log. Earlier lines are never edited.
- Each fix is one commit `TASK-NNN: fix FND-NNN <summary>`, recorded with its SHA in the
  triage sheet, in `docs/05-review/review-log.md`, and in the task ticket's "Review and fix
  log".
- Design changes caused by a finding are logged with the ADR number and go through
  re-approval before the fix proceeds.
- Humans log their own actions too: running a Codex review command, dismissing a finding,
  approving a design change, approving a PR.
- Any step with no log line did not happen: the gate checklists treat a missing log entry as a
  failed gate.

## Mandatory rule: an agent that has reported is done

A subagent can stay alive after it has delivered its report, and it cannot see what the session
that invoked it does next. In a real run, a validation agent that was still alive watched its
own report get a human sign-off recorded by the orchestrator, concluded it had been tampered
with, reverted the sign-off twice, and escalated it as a security incident. Nothing was wrong.

- Once an agent has delivered its final report and asked for human input, it **stops writing to
  its own output files**. The run is over even if the process is not.
- If it wakes and finds its output changed, the posture is **unverified from where I stand**,
  not illegitimate. It flags the difference, names the file, and asks.
- No agent reverts a decision it did not make, re-opens a closed gate, or declares tampering on
  its own judgement. The orchestrating session and the human have context the agent lacks.
- The append-only logs are the shared record. Read them before drawing a conclusion about a
  change you did not make.

## Principles

1. **Document first, then approve, then build.** See the mandatory rules above.
2. **Log every step and change.** Findings, decisions, fixes, and approvals are written down
   with IDs, actors, timestamps, and commit SHAs as they happen.
3. **Docs as code.** Every artifact lives in the repo under `docs/` and is reviewed through pull
   requests, the same as source code. Nothing important lives only in a chat transcript.
4. **Human gates, AI drafts.** The AI proposes; a human approves. A phase is not complete until its
   gate checklist is satisfied and the artifact is merged.
5. **Traceability.** Every item carries an ID (`REQ-`, `DES-`, `TASK-`, `FND-`, `TEST-`) and references
   the IDs upstream of it. Validation is a check that the chain is unbroken.
6. **No agent pins a model.** Every agent inherits the session model so you choose the
   cost/quality trade-off per run. Pinned frontier models caused five rate-limit stalls in one
   real run, one over six hours. Override per call with the Agent tool's `model` parameter, or
   per project with a copy of the agent under `.claude/agents/`.
7. **Small, independently shippable tasks.** Breakdown must produce tasks that one agent session
   can complete, review, and test in isolation.
8. **Context is explicit.** `CLAUDE.md` holds the conventions the agent must follow; each phase
   has a prompt template so runs are repeatable.

## Roles

| Role | Responsibilities |
|------|------------------|
| Product owner | Owns Plan gate. Provides the problem, priorities, and acceptance criteria. |
| Tech lead | Owns Design and Breakdown gates. Reviews architecture and task sizing. |
| Developer | Drives the agent through Implement and Test. Reviews every AI-authored PR. |
| Reviewer | Owns Code Review gate. Reads the AI review report, runs the human-only Codex review commands, decides merge. |
| QA / reviewer | Owns Validation gate. Confirms acceptance criteria and traceability. |
| AI agent (Claude Code) | Drafts all artifacts, writes code and tests, self-reviews, reports. |

One person may hold several roles on a small team, but the gate must be passed consciously.

---

## Phase 1: Plan

**Goal:** Turn an idea or problem into an agreed, testable set of requirements.

**Inputs:** problem statement, business goals, constraints (time, budget, compliance), existing
system context.

**AI activities**
- Ask clarifying questions until the problem is unambiguous; record answers.
- Draft a Product Requirements Document (PRD): background, goals, non-goals, users, user stories,
  functional and non-functional requirements, risks, open questions.
- Assign each requirement an ID (`REQ-001` ...) and a priority (must / should / could).
- Write acceptance criteria per requirement in Given / When / Then form.
- Group requirements into epics (`EPIC-`) and user stories (`STORY-`) with analysis sub-tasks
  needed before design. Implementation tasks (`TASK-`) come later, in Breakdown.

**Human activities**
- Answer clarifying questions; resolve open questions; set priorities.
- Approve the PRD.

**Agent:** `product-owner` (`plugins/sdlc/agents/product-owner.md`). Invoke it with the raw
requirement; it drafts the documents below, runs the gate checklist, and stops for approval.

**Outputs:** `docs/01-plan/PRD-NNN-<title>.md` (PRD with `REQ-` items and scenarios),
`docs/01-plan/tickets/STORY-NNN-<title>.md` (epics and stories with analysis sub-tasks),
`docs/01-plan/backlog.md` (index). Templates live in `docs/templates/`.

**Gate (Plan complete when):**
- [ ] Every requirement has an ID, priority, and acceptance criteria.
- [ ] Non-goals are stated explicitly.
- [ ] No open questions remain that block design.
- [ ] Product owner has approved via PR merge.

---

## Phase 2: Design

**Goal:** Decide how the system will satisfy the requirements before any code is written.

**Inputs:** approved PRD and requirements.

**AI activities**
- Propose an architecture: components, boundaries, data flow, external integrations.
- Define data models, API contracts (OpenAPI / schema files), and key sequence diagrams.
- Write an Architecture Decision Record (ADR) for each significant choice, listing alternatives
  considered and trade-offs.
- Map each design element (`DES-001` ...) to the requirements it satisfies.
- Apply Clean Architecture: show layers and inward dependency direction per component.
- Write a threat model covering every category of the current OWASP Top 10 edition, with a
  concrete control or a justified "not applicable" for each.
- Identify cross-cutting concerns: observability, reliability, data lifecycle, performance
  budgets, testability, delivery, config and secrets, accessibility, compliance, ownership.
- Write a gap analysis proving every requirement, story, concern, and OWASP category is covered.
- Update `CLAUDE.md` with the conventions the implementation must follow (stack, structure, style).

**Human activities**
- Review trade-offs; choose among alternatives where the AI presents options.
- Approve the design and ADRs.

**Agent:** `solution-architect` (`plugins/sdlc/agents/solution-architect.md`). It refuses to start
without approved Plan documents, applies Clean Architecture and the current OWASP Top 10 (2025),
produces the documents below, and stops for tech lead approval.

**Outputs:** `docs/02-design/architecture-<feature>.md`, `docs/02-design/adr/NNNN-*.md`,
`docs/02-design/api/` (contracts), `docs/02-design/data-model.md`,
`docs/02-design/threat-model-<feature>.md`, `docs/02-design/gap-analysis-<feature>.md`,
updated `CLAUDE.md`. Templates live in `docs/templates/`.

**Gate (Design complete when):**
- [ ] Every must-have requirement maps to at least one design element.
- [ ] Every significant decision has an ADR with alternatives.
- [ ] API contracts and data models are defined precisely enough to code against.
- [ ] Clean Architecture layering and dependency direction are shown for every component.
- [ ] Threat model covers all OWASP Top 10 (current edition) categories.
- [ ] Gap analysis has no open gap without an owner and plan.
- [ ] Tech lead has approved via PR merge.

---

## Phase 3: Breakdown

**Goal:** Decompose the design into ordered, independently implementable tasks.

**Inputs:** approved design.

**AI activities**
- Split work into epics, then tasks. Each task states: ID (`TASK-001` ...), title, description,
  linked `REQ-`/`DES-` IDs, files or modules expected to change, acceptance criteria, test
  expectations, dependencies on other tasks, and a size estimate (S / M / L).
- Order tasks in tiers: foundation (scaffold, CI, config, logging) first, then the walking
  skeleton of the main story through every layer, then the main feature component by
  component, then remaining components and integrations, then hardening, then could-haves.
  Within a tier, order by dependency, then risk, then value.
- Define milestones with demonstrable exit criteria, a dependency graph with critical path,
  parallel lanes, a risk register with early spikes, and Definition of Ready / Done per task.
- Flag tasks that need human input (secrets, third-party accounts, product decisions).
- Optionally sync tasks to the issue tracker (GitHub Issues, Jira) with the same IDs.

**Human activities**
- Check sizing: a task larger than one focused agent session must be split.
- Reprioritise or cut scope; approve the task list.

**Agent:** `project-manager` (`plugins/sdlc/agents/project-manager.md`). It refuses to start without
approved Plan and Design documents, orders work in tiers (foundation, walking skeleton, main
feature, components, hardening, could-haves), produces the documents below, and stops for tech
lead approval.

**Outputs:** `docs/03-tasks/tickets/TASK-NNN-<title>.md` (one per task with sub-tasks, acceptance
criteria, test and security expectations, Definition of Ready and Done),
`docs/03-tasks/delivery-plan.md` (tiers, milestones, dependency graph, critical path, parallel
lanes, risk register, human-input tasks), `docs/03-tasks/backlog.md` (execution-ordered index),
and optionally issues in the tracker. Templates live in `docs/templates/`.

**Gate (Breakdown complete when):**
- [ ] Every design element is covered by at least one task.
- [ ] Every task has acceptance criteria and a test expectation.
- [ ] Dependencies form a DAG with a clear first task; critical path stated.
- [ ] Foundation and walking-skeleton tasks come before any secondary work.
- [ ] Milestones have demonstrable exit criteria; risk register exists.
- [ ] Tech lead has approved.

---

## Phase 4: Implement

**Goal:** Deliver each task as a reviewed, mergeable pull request.

**Preconditions (mandatory):** approved `docs/01-plan/`, `docs/02-design/`, and `docs/03-tasks/`
for the feature. Do not start if any is missing or unapproved.

**Agent:** `dotnet-developer` (`plugins/sdlc/agents/dotnet-developer.md`). The backend is .NET / C#.
The agent implements one `TASK-` ticket per run on its own branch, invokes the installed
`dotnet-skills` plugin skills before coding in each area, enforces Clean Architecture project
references with an architecture test, applies the OWASP Top 10:2025 controls from the threat
model, runs format, build with warnings as errors, tests, vulnerability scan, and slopwatch,
then opens a PR and stops for human review.

**Inputs:** one task from the backlog; `CLAUDE.md`; the design documents.

**AI activities (per task)**
- Create a branch named `task/TASK-NNN-short-title`.
- Restate the task and its acceptance criteria; ask before starting if anything is ambiguous.
- Implement the change following `CLAUDE.md` conventions.
- Write or update unit tests alongside the code (see Phase 6 for the standard).
- Run `dotnet format`, build with warnings as errors, the test suite, the vulnerable-package
  scan, and slopwatch locally; fix failures without suppressing anything.
- Complete a security self-review against the OWASP Top 10 table and include it in the PR.
- Self-review the diff against the acceptance criteria and note any deviations.
- Open a PR whose description lists the task ID, requirement IDs, what changed, how it was
  tested, and anything left out.

**Human activities**
- Review the PR for correctness, design adherence, and hidden scope creep.
- Request changes or approve and merge.

**Outputs:** merged PR per task; updated task status in the backlog.

**Gate (task complete when):**
- [ ] CI is green (format, build with warnings as errors, tests, vulnerability scan, slopwatch).
- [ ] If the task changed a test-enforcement file (architecture test, lint rule, CI gate), the
      PR shows mutation evidence in both directions: the check fails on the violation it is
      meant to catch, and still passes on what passed before.
- [ ] Any CI-equivalent command the change affects was run locally, not reasoned about.
- [ ] PR references the task and requirement IDs and contains the security self-review.
- [ ] Code Review phase (Phase 5) has returned Approve or Approve with comments.
- [ ] A human has reviewed and approved.
- [ ] Task status is updated to done.

---

## Phase 5: Code Review

**Goal:** Catch defects, layering violations, security regressions, and weak tests before a PR
merges, using two independent reviewers: Claude (`code-reviewer` agent) and OpenAI Codex
(`codex@openai-codex` plugin).

**Inputs:** the open PR or branch from Phase 4, the task ticket and its linked design and threat
model, the quality-loop results, and any Codex output.

**Codex review workflow (mandatory).** The Codex plugin's commands have fixed invocation rules:
- `/codex:review`, `/codex:adversarial-review`, `/codex:status`, and `/codex:result` are
  declared `disable-model-invocation: true`. Claude cannot run them, here or in any repo. Only a
  human runs them.
- `/codex:rescue` (and `/codex:setup`) are model-invocable. `/codex:rescue` spawns a Codex
  subagent through the Agent tool, which only the main Claude session has, so the **main session**
  runs it, never a subagent.
- Codex is configured by `.codex/config.toml` at the repo root (model and reasoning effort).
  Respect it; never override per invocation.

**AI activities**
- Main session, after any code change and always when the change touches core logic
  (authentication and authorisation model, per-user data isolation, JWT issuance and
  validation, EF Core migrations and queries, cryptography, money handling, threat-model
  controls): proactively run `/codex:rescue` with a focused investigation prompt to find bugs.
- Main session: invoke the `code-reviewer` agent, passing the PR or branch and the `/codex:rescue`
  output.
- `code-reviewer`: review the full diff for scope, correctness, Clean Architecture, .NET/C#
  best practice (via `dotnet-skills`), slopwatch, OWASP Top 10:2025, tests, and operability;
  verify and classify every Codex finding; write the review report; assign a verdict.
- Main session: relay the verdict and tell the user to run `/codex:review`, plus
  `/codex:adversarial-review` for core or complex changes, and to check `/codex:result`.
- If the user runs those and asks Claude to act on the findings, treat them exactly like
  rescue findings: verify, fix genuine bugs through the `dotnet-developer` agent, and do not
  self-trigger the review commands next time.

**Triage and fix loop (after Codex results arrive)**

```
Codex output ──▶ code-reviewer registers FND-IDs ──▶ solution-architect reviews ──▶ dotnet-developer reviews
                                                          (design impact)                 (code impact)
                                                                 │                              │
                                                                 └──────── Final decision ──────┘
                                                                                 │
                              ┌──────────────────┬───────────────────────────────┼──────────────┐
                              ▼                  ▼                               ▼              ▼
                            Fix            Design change                      Dismiss       Escalate
                   developer fixes on    architect updates ADR/design,      reason logged,   owner + due
                   same branch, one      tech lead re-approves, then        human confirms   date logged
                   commit per FND        developer fixes                    Blocker/Major
                              │                  │
                              └────────┬─────────┘
                                       ▼
                        code-reviewer re-reviews ──▶ all FND closed? ──▶ human approves PR
                                       ▲                    │ no
                                       └────────────────────┘
```

1. Main session passes the Codex output to `code-reviewer`, which registers every item as an
   `FND-` row in the triage sheet, verifies it, and logs the step.
2. Main session invokes `solution-architect` in triage mode: it judges each finding's design
   impact, records Fix (design intact) / Design change (ADR) / Dismiss / Escalate, updates
   design documents if needed, and logs every decision.
3. Main session invokes `dotnet-developer` in triage-and-fix mode: it records its own decision
   per finding, then fixes only findings whose Final decision is Fix, one commit per finding
   (`TASK-NNN: fix FND-NNN <summary>`), quality loop green, each change logged with its SHA.
4. Main session invokes `code-reviewer` for a re-review; it verifies each fix and issues a new
   report. Repeat until no finding is Open.
5. Human confirms dismissals of Blocker or Major findings, approves any design change, and
   approves the PR. Each human action is logged.

**Human activities**
- Read the review report; run `/codex:review` and, for core or complex changes,
  `/codex:adversarial-review`; check `/codex:result`; paste the output back and log the run.
- Confirm or overturn dismissals of Blocker and Major findings; approve design changes.
- Approve and merge, or request changes (which returns the task to Phase 4).

**Agent:** `code-reviewer` (`plugins/sdlc/agents/code-reviewer.md`). Review-only; never edits code and
cannot run `/codex:*` commands itself.

**Outputs:** `docs/05-review/REVIEW-TASK-NNN-<n>.md` (review report), 
`docs/05-review/TRIAGE-TASK-NNN-<n>.md` (findings register with architect, developer, and final
decisions, plus append-only activity log), `docs/05-review/review-log.md` (repo-wide index and
`FND-` counter), the task ticket's "Review and fix log", and fix commits
`TASK-NNN: fix FND-NNN ...`. Templates in `docs/templates/`.

**Gate (Code Review complete when):**
- [ ] Review report exists with a verdict; every finding has a severity.
- [ ] No open Blocker or Major finding.
- [ ] `/codex:rescue` was run by the main session for core-logic changes and its findings are
      classified in the report.
- [ ] Human has run `/codex:review` (and `/codex:adversarial-review` for core/complex changes)
      and checked `/codex:result`; findings are registered with `FND-` IDs.
- [ ] `solution-architect` and `dotnet-developer` have each recorded a decision on every
      finding; every finding has a Final decision.
- [ ] Every Fix is a logged commit with SHA; every Dismiss has a reason (human-confirmed for
      Blocker/Major); every Design change has a re-approved ADR.
- [ ] Re-review confirms no finding is Open.
- [ ] Every step above has a line in the triage activity log, `review-log.md`, and the task
      ticket. A missing line fails this gate.
- [ ] Human approves the PR.

---

## Phase 6: Test

**Goal:** Prove the implementation meets its acceptance criteria at every level.

**Inputs:** merged code; acceptance criteria from requirements and tasks.

**Test levels and ownership**

| Level | Tool | Written when | Source of truth | Runs in |
|-------|------|--------------|-----------------|---------|
| Unit | xUnit | During Implement, with the code | Task acceptance criteria | Every PR |
| Integration | xUnit + Testcontainers / WebApplicationFactory | After the modules they cover exist | API contracts, data model | Every PR |
| Contract / API | Playwright `request` | After the endpoint exists | API contracts | Every PR |
| End-to-end | Playwright browser tests via the Playwright agents | After a user story is fully implemented | Requirement acceptance criteria | Nightly and before release |
| Security abuse cases | Playwright API / browser | After the control is implemented | Threat model | Before release |
| Non-functional | Playwright timing smoke; load tests per design | After the walking skeleton | Performance and security budgets from Design | Before release |

**Playwright test agents.** Generated with `npx playwright init-agents --loop=claude` into
`plugins/sdlc/agents/playwright-test-planner.md`, `playwright-test-generator.md`, and
`playwright-test-healer.md`, backed by the `playwright-test` MCP server in `.mcp.json`. They are
regenerated on every Playwright upgrade (`npm run playwright:agents`) and never hand-edited.
The planner explores the running app from `tests/e2e/seed.spec.ts` and writes a plan to `specs/`; the
generator turns each plan case into a test under `tests/e2e/`, verifying selectors live; the
healer repairs failing tests or reports that the application is broken.

**AI activities**
- `qa-engineer` writes the test strategy and scenario matrix per story from the Given / When /
  Then acceptance criteria, assigning every scenario a level and a `TEST-` ID.
- Main session invokes `playwright-test-planner` with the story, scenario list, and seed;
  `qa-engineer` reviews the resulting `specs/` plan.
- Main session invokes `playwright-test-generator` per test case; `qa-engineer` reviews the
  generated tests against the quality standard (traceability IDs, role-based locators,
  web-first assertions, independence, negative paths, abuse cases).
- `qa-engineer` runs `dotnet test` and `npx playwright test`; main session invokes
  `playwright-test-healer` on failures; `qa-engineer` triages: test defect → accept patch,
  application defect → `DEF-NNN` returned to `dotnet-developer` through the Phase 5 loop.
- `qa-engineer` writes the test report with a requirement coverage matrix and logs every
  step in `docs/06-test/test-log.md`.

**Human activities**
- Review generated tests for meaningfulness, not only for passing.
- Decide on coverage and quality thresholds; approve the test report.

**Agent:** `qa-engineer` (`plugins/sdlc/agents/qa-engineer.md`), a principal QA engineer. It prepares
inputs for and reviews outputs of the Playwright agents, audits the .NET tests, runs the full
suite, triages, and reports. It cannot spawn the Playwright agents itself; the main session
invokes them in the order the QA agent specifies.

**Outputs:** `docs/06-test/test-plan-<STORY-NNN>.md`, `specs/<STORY-NNN>-*.md`,
`tests/e2e/**/*.spec.ts`, `docs/06-test/test-report-<STORY-NNN>-<n>.md`,
`docs/06-test/defects.md`, `docs/06-test/test-log.md`, Playwright and JUnit reports. Templates
in `docs/templates/`.

**Gate (Test complete when):**
- [ ] Coverage audit ran first: every acceptance scenario marked Covered, Vacuous, or Gap,
      with non-vacuity proven by mutation for must-have scenarios marked Covered. The planner
      and generator ran only for gaps. Zero gaps is a valid result.
- [ ] Test plan exists with every acceptance scenario assigned a level and `TEST-` ID.
- [ ] Playwright plan and generated tests reviewed by `qa-engineer`.
- [ ] All levels pass in CI; failures triaged through the healer or to a `DEF-`.
- [ ] Every must-have requirement has at least one passing tagged test; negative paths and
      threat-model abuse cases covered.
- [ ] Coverage meets the agreed threshold; uncovered requirements listed with an owner.
- [ ] Open defects have severity, owner, and a decision (fix now, defer, won't fix).
- [ ] Every step logged in `test-log.md`; human has approved the test report.

---

## Phase 7: Validation

**Goal:** The product owner confirms that what was built is what was asked for and functions as
the user expects, and decides whether to release.

**Preconditions (mandatory):** plan, design, and task documents approved; every task Done with
Code Review clean (no open `FND-`); Test report approved with verdict Ready for Validation and
no open Blocker or Critical `DEF-`; a running build of the tested commit.

**Inputs:** PRD and stories (the acceptance contract), design, task backlog, review reports,
test report, the running system.

**AI activities** (`product-owner` in validation mode)
- Assemble the acceptance set: every `REQ-`/`STORY-` scenario, priority, and non-goal.
- Build the traceability matrix `REQ-` → `DES-` → `TASK-`/PR → `REVIEW-`/`FND-` → `TEST-` →
  validation result; a broken link on a must-have requirement fails validation.
- Walk every acceptance scenario on the running system, through the browser or the API, and
  record Pass / Fail / Blocked with evidence, judging intent as well as letter.
- Check non-goals were not built and nothing was built without a `REQ-`.
- Check non-functional requirements against the evidence.
- Classify each finding as `VAL-NNN` with a route: built wrong → `DEF-` to `dotnet-developer`
  via the Phase 5 loop; built the wrong thing → `REQ-` change in Plan and re-approval; scope
  creep → keep (add `REQ-`) or remove; accept with note.
- Write the validation report, traceability matrix, release notes in user language, and
  retrospective input; log every step in `docs/07-validation/validation-log.md`.
- Give a verdict: Accept / Accept with notes / Reject. Never release.

**Human activities**
- User acceptance testing with real users or stakeholders where the agent's walkthrough is
  not enough.
- Decide on scope-creep findings; approve `REQ-` changes.
- Sign off on release, or send findings back to the phase the report names.
- Hold the retrospective. Write it up in `docs/retrospectives/<date>-<slug>.md` from
  `docs/templates/retrospective-template.md`, giving every item a disposition, then apply its
  recommendations to `WORKFLOW.md`, `CLAUDE.md`, and the templates. A finding with no
  disposition is not finished.

**Agent:** `product-owner` (`plugins/sdlc/agents/product-owner.md`) in validation mode. The same
agent that wrote the requirements validates them, so the acceptance contract is never
reinterpreted by a different role.

**Outputs:** `docs/07-validation/validation-<STORY-NNN>-<n>.md`,
`docs/07-validation/traceability-<STORY-NNN>.md`, `docs/07-validation/release-notes-<version>.md`,
retrospective input in the report (written up after the retrospective as
`docs/retrospectives/<date>-<slug>.md`), `docs/07-validation/validation-log.md`. Templates in
`docs/templates/`.

**Gate (Validation complete when):**
- [ ] Preconditions met.
- [ ] Traceability matrix has no broken link on a must-have requirement.
- [ ] Every acceptance scenario walked on the running system with evidence; every must-have
      scenario Pass on both letter and intent.
- [ ] Non-goals honoured; no unrequested behaviour without a logged decision.
- [ ] Every `VAL-` finding routed with an owner; no open finding rated Reject.
- [ ] No open critical or high security findings.
- [ ] Every step logged in `validation-log.md`.
- [ ] Human product owner has signed off.
- [ ] Retrospective written to `docs/retrospectives/` with a disposition for every item, and
      workflow-level changes applied to `WORKFLOW.md`, `CLAUDE.md`, or a template.

---

## Troubleshooting

Failure modes seen in real runs. All of them are silent: nothing errors, the agent just quietly
cannot do its job. `/sdlc:doctor` checks every one of these.

| Symptom | Cause | Fix |
|---------|-------|-----|
| A Playwright agent reports it has no browser tools | The MCP tool names in the agent do not match how the server is registered. A project-level `.mcp.json` registers `mcp__playwright-test__*`; a plugin-declared server would register `mcp__plugin_sdlc_playwright-test__*`. | This plugin ships the server in the project scaffold so the bare form matches what `npx playwright init-agents` generates. Regenerate the agents with `npm run playwright:agents`. |
| `browser_*` fails with `Must setup test before interacting with the page` | The MCP tools are stateful and need a page session first. | Call `planner_setup_page` before any `browser_*` call. If the tool is unavailable, drive Playwright through a standalone script via `Bash` instead. |
| Page setup fails with `address already in use` | On macOS the AirPlay Receiver holds port 5000 permanently. The MCP server is a separate child process and does not inherit `playwright.config.ts`. | Its port comes from the `env` block in `.mcp.json`. The scaffold defaults to 4280 for this reason. Never set it to 5000. |
| A config change to `.mcp.json` has no effect after `/reload-plugins` | `/reload-plugins` re-registers tool schemas but does not respawn a running MCP server child process. It reports success either way. | `ps -eo pid,lstart,command \| grep run-test-mcp-server`, compare the start time to your edit, and `kill` the stale process. The next tool call spawns a fresh one. |
| Several MCP server processes are alive at once | Each orphan is from an earlier session. They make port and staleness problems much harder to diagnose. | `/sdlc:doctor --fix` kills the duplicates and keeps the newest. Worth running at the start of a long session. |
| `dotnet test --collect:"XPlat Code Coverage"` reports `Zero tests ran` while plain `dotnet test` passes | Known mismatch between the coverage collector and Microsoft.Testing.Platform on xunit v3. | Not your change. Run plain `dotnet test`. Do not bisect it, and do not stash and re-run to prove it. |

## Feedback loops

Work is sent back, not forward, when a gate fails:

| Discovered in | Problem | Return to |
|---------------|---------|-----------|
| Design | Requirement is contradictory or untestable | Plan |
| Breakdown | Design element cannot be sized into tasks | Design |
| Implement | Task is ambiguous or too large | Breakdown |
| Code Review | Finding with Final decision Fix | Implement (same branch, fix mode) |
| Code Review | Finding with Final decision Design change | Design (ADR update, re-approval), then Implement |
| Test | Code fails acceptance criteria | Implement |
| Test | Acceptance criteria are wrong | Plan |
| Validation | Built the wrong thing (`VAL-` → `REQ-` change) | Plan, re-approve, then onward |
| Validation | Built it wrong (`VAL-` → `DEF-`) | Implement via the Phase 5 triage loop |
| Validation | Scope creep | Plan (add `REQ-`) or Implement (remove) |

Each return produces a new PR against the upstream artifact so the change is recorded.

## Repository layout

```
.
├── CLAUDE.md                 # conventions the agent follows during Implement
├── WORKFLOW.md               # this file
├── docs/
│   ├── 01-plan/
│   ├── 02-design/
│   │   ├── adr/
│   │   └── api/
│   ├── 03-tasks/
│   ├── 05-review/
│   ├── 06-test/
│   ├── 07-validation/
│   ├── retrospectives/       # one file per retrospective, every item with a disposition
│   └── templates/            # one template per artifact
├── .claude/
│   ├── agents/               # generated Playwright agents (project-local)
│   └── settings.json         # model fallback, marketplaces, enabled plugins (incl. sdlc)
├── .claude-plugin/marketplace.json   # this repo is also the marketplace for the sdlc plugin
├── plugins/sdlc/             # the workflow as a plugin: agents/, skills/, scaffold/, scripts/init.sh
├── .codex/config.toml        # Codex reviewer model and reasoning effort
├── .mcp.json                 # playwright-test MCP server (project-level, from the scaffold)
├── playwright.config.ts, specs/, tests/e2e/ (incl. seed.spec.ts)   # Phase 6 Playwright project
├── scripts/setup.sh          # bootstrap plugins, Playwright, and toolchain on a new machine
└── src/, tests/              # .NET solution created during Implement
```

Phase 4 has no docs folder because its artifacts are the code and PRs themselves.

## Running a phase with Claude Code

Each phase is a slash command backed by a skill in `plugins/sdlc/skills/<name>/SKILL.md`, shipped by the `sdlc` plugin. Skills run
in the main session, which is the only place that can spawn subagents, run `/codex:rescue`, and
chain the Playwright agents; agents do the work, skills sequence it. Every skill is
`disable-model-invocation: true`, so only a human starts a phase. Each skill checks the
upstream gate, invokes the agent with a fixed prompt, relays the result, and states what must
be approved before the next command.

| Command | Gate it checks | Agents it invokes | Writes |
|---------|----------------|-------------------|--------|
| `/sdlc:plan <feature>` | none | `product-owner` | `docs/01-plan/` |
| `/sdlc:design <feature>` | plan Approved | `solution-architect` | `docs/02-design/`, `CLAUDE.md` |
| `/sdlc:breakdown <feature>` | plan + design Approved | `project-manager` | `docs/03-tasks/` |
| `/sdlc:implement TASK-NNN` | backlog Approved, DoR met | `dotnet-developer`, then `/codex:rescue` | branch + PR |
| `/sdlc:review TASK-NNN` | PR open | `/codex:rescue` if needed, `code-reviewer` | `docs/05-review/REVIEW-*`, `TRIAGE-*` |
| `/sdlc:triage TASK-NNN [output]` | triage sheet exists | `code-reviewer` → `solution-architect` → `dotnet-developer` → `code-reviewer` | fix commits, logs |
| `/sdlc:test STORY-NNN` | tasks Done, review clean | `qa-engineer` ↔ `playwright-test-planner` / `generator` / `healer` | `specs/`, `tests/e2e/`, `docs/06-test/` |
| `/sdlc:validate STORY-NNN` | test report Approved | `product-owner` (validation mode) | `docs/07-validation/` |
| `/sdlc:log <action> ...` | — | none | appends to the right log and ticket |
| `/sdlc:status [id]` | — | none | nothing; reports state and next command |

`/sdlc:log` exists because the logging rule applies to humans too: approvals, Codex runs, dismissals,
and sign-offs are recorded through it.
