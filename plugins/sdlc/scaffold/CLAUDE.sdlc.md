<!-- sdlc-plugin:begin (managed by /sdlc:init; edit freely, the marker is only used to avoid duplicate insertion) -->
# AI-Driven SDLC workflow (sdlc plugin)

## Mandatory workflow rule

This repo follows the seven-phase workflow in `WORKFLOW.md`. **Plan, Design, and Breakdown MUST
each produce a written document in `docs/` with the details noted down, and those documents MUST
be approved by a human before any development starts.** If asked to implement something that has
no approved plan, design, and task breakdown, stop and create the missing documents first, then
ask for approval.

## Slash commands (skills)

Run a phase with its skill: `/sdlc:plan`, `/sdlc:design`, `/sdlc:breakdown`, `/sdlc:implement TASK-NNN`,
`/sdlc:review TASK-NNN`, `/sdlc:triage TASK-NNN [Codex output]`, `/sdlc:test STORY-NNN`, `/sdlc:validate STORY-NNN`,
plus `/sdlc:log` to record a human action, `/sdlc:status` to see where everything stands, and
`/sdlc:doctor` to diagnose a silent environment problem (missing browser tools, a stale MCP
server process, a port conflict, status drift). Skills come from the `sdlc` plugin (`plugins/sdlc/skills/`) and run in the main session; they check the gate, invoke the right agents
in order, and relay the result. They are not model-invocable: a human starts every phase.

## Subagents

- `product-owner` (`plugins/sdlc/agents/product-owner.md`): runs the Plan phase and the Validation
  phase. Plan mode: give it a raw requirement; it writes the PRD, `REQ-` items with
  Given/When/Then scenarios, and `STORY-` tickets under `docs/01-plan/`, then stops for
  approval. Validation mode (after development, review, and test are finished): it walks every
  acceptance scenario on the running system, builds the traceability matrix, routes `VAL-`
  findings, and writes the validation report under `docs/07-validation/`, then stops for
  sign-off. Templates are in `docs/templates/`.
  Runs on Fable 5.1 (`model: fable`); if unavailable it must fall back to Opus at minimum, via
  `fallbackModel` in `.claude/settings.json`. Never downgrade it to Sonnet or Haiku.
- `solution-architect` (`plugins/sdlc/agents/solution-architect.md`): runs the Design phase. Requires
  approved Plan documents. Produces architecture, ADRs, data model, API contracts, threat model
  (OWASP Top 10:2025, checks for a newer edition each run), and gap analysis under
  `docs/02-design/`, following Clean Architecture. Same model policy as product-owner.
- `project-manager` (`plugins/sdlc/agents/project-manager.md`): runs the Breakdown phase. Requires
  approved Plan and Design documents. Produces `TASK-` tickets, a delivery plan (tiers,
  milestones, dependency graph, risk register), and the execution-ordered backlog under
  `docs/03-tasks/`. Core structure and main feature always come first. Same model policy.
- `dotnet-developer` (`plugins/sdlc/agents/dotnet-developer.md`): runs the Implement phase. One
  approved `TASK-` per run on branch `task/TASK-NNN-*`, ending in a PR for human review. Uses
  the `dotnet-skills` plugin, Clean Architecture project layout, .NET/C# best practice, and the
  OWASP Top 10:2025 controls from the threat model. Same model policy.
- `code-reviewer` (`plugins/sdlc/agents/code-reviewer.md`): runs the Code Review phase. Review-only.
  Reviews the full diff for correctness, Clean Architecture, .NET best practice, OWASP Top
  10:2025, and tests; verifies Codex findings passed to it; writes `docs/05-review/REVIEW-*.md`
  with a verdict. Same model policy.

- `qa-engineer` (`plugins/sdlc/agents/qa-engineer.md`): principal QA engineer for the Test phase.
  Writes the test plan from acceptance criteria, drives the Playwright agents (below) through
  the main session, audits .NET tests, runs the full suite, triages to `DEF-` defects, and
  writes the test report under `docs/06-test/`. Same model policy.
- `playwright-test-planner`, `playwright-test-generator`, `playwright-test-healer`: generated
  by `npx playwright init-agents --loop=claude`. Never hand-edit; regenerate with
  `npm run playwright:agents` after a Playwright upgrade. They need the `playwright-test` MCP
  server declared in `.mcp.json`.

## Playwright test workflow (Phase 6)

Playwright is the main end-to-end and API test tool. The main session drives the cycle in the
order `qa-engineer` specifies: qa-engineer (plan) → playwright-test-planner (explore app, write
`specs/`) → qa-engineer (review plan) → playwright-test-generator (one call per case, writes
`tests/e2e/`) → qa-engineer (review, run `npx playwright test` and `dotnet test`) →
playwright-test-healer (per failing test) → qa-engineer (triage, report). `tests/e2e/seed.spec.ts` is the
bootstrap the planner and generator start from; `BASE_URL` selects the host under test.
Application defects found in testing become `DEF-NNN` entries and go back to `dotnet-developer`
through the Phase 5 triage loop, logged like any other finding.

## Codex review workflow (after any code change)

The OpenAI Codex plugin (`codex@openai-codex`) is the second reviewer. Its command frontmatter
fixes who may run what:

- `/codex:review`, `/codex:adversarial-review`, `/codex:status`, and `/codex:result` are
  `disable-model-invocation: true`. Claude has no path to run these itself, in this repo or any
  other. Only `/codex:rescue` and `/codex:setup` are model-invocable.
- `/codex:rescue` spawns the `codex:codex-rescue` subagent via the Agent tool, so only the main
  session can run it; subagents (including `code-reviewer`) cannot.

So after any code change in this repo:

1. The main session proactively runs `/codex:rescue` to investigate and find bugs, especially
   when the change touches core logic: auth model, per-user data isolation, JWT issuance and
   validation, EF Core migrations and queries.
2. The main session invokes the `code-reviewer` agent with the PR or branch and the rescue
   output. The reviewer verifies every Codex finding and writes the review report.
3. The main session tells the user to run `/codex:review` and, for core or complex changes,
   `/codex:adversarial-review`, and reminds them to check `/codex:result`. Claude must not run
   those three or `/codex:status` on its own initiative.
4. If the user runs one of those and asks Claude to act on the findings, treat it the same as a
   `/codex:rescue` finding: fix genuine bugs (through `dotnet-developer`), but do not
   self-trigger the review commands next time.
5. Findings are never fixed straight away. The main session runs the triage loop: `code-reviewer`
   registers each finding with an `FND-` ID in `docs/05-review/TRIAGE-TASK-NNN-<n>.md`, then
   `solution-architect` (design impact) and `dotnet-developer` (code impact) each record a
   decision, then the developer fixes only agreed findings on the same branch with one commit
   per finding (`TASK-NNN: fix FND-NNN <summary>`), then `code-reviewer` re-reviews.

## Mandatory logging rule

Every step and every change in the workflow MUST be logged when it happens: one line in the
triage sheet's append-only activity log, one row in `docs/05-review/review-log.md`, and one row
in the task ticket's "Review and fix log", each with timestamp, actor, action, finding IDs, and
artifact or commit SHA. Findings are never deleted, only closed with a decision and evidence.
Earlier log lines are never edited. A step without a log line counts as not done.

Codex is configured via `.codex/config.toml` at the repo root (pins the model and a
reasoning-effort setting). Respect whatever is set there; never override it per invocation.

## Setting up on a new machine

Run `./scripts/setup.sh` once. It registers the `dotnet-skills` and `openai-codex`
marketplaces, installs both plugins at project scope, installs the Playwright npm dependencies
and browsers, regenerates the Playwright agents, and checks for the Codex CLI, .NET SDK,
GitHub CLI, and Docker. `.claude/settings.json`
also declares the marketplace under `extraKnownMarketplaces`, so trusting the repo folder
registers it automatically, but the plugin itself still needs the install step. Restart Claude
Code (or run `/reload-plugins`) afterwards.

## Tech stack and tooling

- Backend is .NET / C#. The `dotnet-skills` plugin (marketplace `Aaronontheweb/dotnet-skills`,
  enabled at project scope in `.claude/settings.json`) is the source of .NET practice; invoke
  its skills before coding in an area rather than working from memory. Key ones:
  `dotnet-project-structure`, `package-management`, `modern-csharp-coding-standards`,
  `csharp-nullable-reference-types`, `dependency-injection-patterns`,
  `microsoft-extensions-configuration`, `efcore-patterns`, `opentelemetry-net-instrumentation`,
  `testcontainers-integration-tests`, `dotnet-slopwatch`.
- Quality loop before any PR: `dotnet format --verify-no-changes`, `dotnet build -warnaserror`,
  `dotnet test`, `dotnet list package --vulnerable --include-transitive`, then slopwatch.
  Never disable tests, suppress warnings, or add empty catch blocks to get green.
- Solution layout, once created by the Design phase, follows Clean Architecture: Domain,
  Application, Infrastructure, Api projects with references pointing inward, guarded by an
  architecture test.
## Environment gotchas (verified in a full run, do not re-derive)

- **Playwright MCP port is 4280, never 5000.** macOS AirPlay Receiver holds 5000 permanently.
  The MCP server is a separate child process and does not read `playwright.config.ts`; its port
  comes from the `env` block in `.mcp.json`. Both must agree.
- **`browser_*` tools need `planner_setup_page` first**, or they fail with `Must setup test
  before interacting with the page`. If that tool is not available, drive Playwright through a
  standalone script via `Bash`.
- **`/reload-plugins` does not respawn a running MCP server.** After editing `.mcp.json`, kill
  the `run-test-mcp-server` process or the old config keeps serving tool calls, silently.
- **`dotnet test --collect:"XPlat Code Coverage"` reports `Zero tests ran`** on xunit v3 with
  Microsoft.Testing.Platform, while plain `dotnet test` passes. Known collector mismatch, not a
  regression. Run plain `dotnet test`; do not bisect it.
- **No agent pins a model.** Agents inherit the session model. Override per call with the Agent
  tool's `model` parameter when a phase deserves a frontier model.

Run `/sdlc:doctor` when something Playwright-related behaves strangely; it checks all of these.

<!-- sdlc-plugin:end -->
