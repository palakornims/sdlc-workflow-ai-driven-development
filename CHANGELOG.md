# Changelog

All notable changes to the `sdlc` plugin and this workflow repository.
Versions follow the plugin's `.claude-plugin/plugin.json`, tagged `sdlc--v<version>`.

## [1.1.1] - 2026-09-14

### Added

- `CHANGELOG.md`, this file, so each release records what changed and why.
- `docs/retrospectives/` with a template, and Phase 7 now writes the retrospective there with a
  disposition for every item. The workflow told teams to hold retrospectives but gave the output
  nowhere to live.
- The v1.1.0 findings written up in full at
  [`docs/retrospectives/2026-09-13-first-production-run.md`](docs/retrospectives/2026-09-13-first-production-run.md),
  including which decisions are load-bearing and must not be undone.

## [1.1.0] - 2026-09-13

Fixes from the first full production run of the workflow (a calculator web app: 9 tasks,
~30 review cycles, all seven phases). Full findings and disposition:
[`docs/retrospectives/2026-09-13-first-production-run.md`](docs/retrospectives/2026-09-13-first-production-run.md).

### Fixed

- **Playwright agents silently lost every browser tool.** The plugin declared the
  `playwright-test` MCP server itself, so Claude Code registered it as
  `mcp__plugin_sdlc_playwright-test__*`. But `npx playwright init-agents` generates agents that
  reference the bare `mcp__playwright-test__*`. The names never matched, so the planner,
  generator, healer, `qa-engineer`, and `product-owner` all fell back to generic tools with no
  error. The server now ships in the project scaffold and installs as a project-level
  `.mcp.json`, where the bare names are correct. **Do not move it back into the plugin.**
- **Port 5000 conflict on macOS.** AirPlay Receiver holds 5000 permanently, so interactive page
  setup failed with `address already in use`. The MCP server is a separate child process and
  does not read `playwright.config.ts`. Default is now 4280, set in both the `env` block of
  `.mcp.json` and the Playwright config.
- **`product-owner` and `qa-engineer` browser tools were unusable.** Every `browser_*` call
  failed with `Must setup test before interacting with the page` because the required setup tool
  was missing from their tool lists. Added `planner_setup_page`, and documented the standalone
  Playwright script through `Bash` as a legitimate fallback.

### Changed

- **No agent pins a model.** All six inherit the session model. Pinned frontier models caused
  five rate-limit stalls in one run, one lasting over six hours, with no detectable quality gain.
  Override per call with the Agent tool's `model` parameter, or per project with a copy of the
  agent under `.claude/agents/`.
- **`backlog.md` is the single source of truth for task status.** Ticket files no longer carry a
  `Status` field, which had drifted from the backlog.
- **The Test phase starts with a coverage audit.** Every acceptance scenario is marked Covered,
  Vacuous, or Gap, with non-vacuity proven by mutation for must-have scenarios. The planner and
  generator run only for gaps. Zero gaps is a valid outcome. Previously the phase assumed a
  blank slate and would have duplicated tests written during Implement.

### Added

- **`/sdlc:doctor`** diagnoses the silent failures: MCP tool-prefix mismatch, stale or duplicate
  server processes, port conflicts, and task-status drift. `--fix` kills duplicate servers.
- **Rule: an agent that has reported is done.** After delivering its report an agent stops
  writing to its own output files, and if it finds them changed it flags and asks rather than
  reverting. A validation agent that outlived its report by three hours saw the orchestrator
  record a human sign-off, concluded it had been tampered with, reverted it twice, and escalated
  a false security incident.
- **Rule: prove a test-enforcement change by mutation.** Before committing a change to an
  architecture test, lint rule, or CI gate, show it fails on the violation it targets and still
  passes on what passed before. Two tasks shipped regressions in their own architecture test.
  Also: run CI-equivalent commands locally instead of reasoning about them.
- **Troubleshooting table** in `WORKFLOW.md` and an **Environment gotchas** section in the
  `CLAUDE.md` scaffold, covering the above plus two platform behaviours that cannot be fixed
  from a plugin: `/reload-plugins` does not respawn a running MCP server child process, and
  `dotnet test --collect:"XPlat Code Coverage"` reports `Zero tests ran` on xunit v3 with
  Microsoft.Testing.Platform while plain `dotnet test` passes.
- **Retrospective template and folder** (`docs/retrospectives/`) so Phase 7 output has a home.

## [1.0.0] - 2026-09-11

First release. Seven phases (Plan, Design, Breakdown, Implement, Code Review, Test, Validation),
one subagent per phase, slash commands to run them, document templates, mandatory approval before
development, and mandatory logging of every step. .NET backend via the `dotnet-skills` plugin,
Playwright test agents, OpenAI Codex as second reviewer, and `/sdlc:init` to scaffold a project.
