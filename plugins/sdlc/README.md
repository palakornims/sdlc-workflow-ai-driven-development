# sdlc plugin

Seven-phase AI-driven SDLC for Claude Code. See the repository root README and `scaffold/WORKFLOW.md`.

```
claude plugin marketplace add palakornims/sdlc-workflow-ai-driven-development
claude plugin install sdlc@sdlc-workflow --scope project
claude
/sdlc:init
```

Local development without installing: `claude --plugin-dir ./plugins/sdlc` from the repo root,
then `/reload-plugins` after edits.

| Component | Contents |
|-----------|----------|
| `agents/` | product-owner, solution-architect, project-manager, dotnet-developer, code-reviewer, qa-engineer |
| `skills/` | `/sdlc:init`, `/sdlc:plan`, `/sdlc:design`, `/sdlc:breakdown`, `/sdlc:implement`, `/sdlc:review`, `/sdlc:triage`, `/sdlc:test`, `/sdlc:validate`, `/sdlc:log`, `/sdlc:status`, `/sdlc:doctor` |
| `scaffold/mcp.json` | `playwright-test` MCP server, installed into the **project** as `.mcp.json` |
| `scaffold/` | Everything `/sdlc:init` copies into a project: docs, templates, logs, WORKFLOW.md, CLAUDE.md section, settings, Codex and Playwright config, setup script |
| `scripts/init.sh` | The idempotent scaffold installer |

## Design notes

- **The MCP server is project-level, not plugin-level, on purpose.** A plugin-declared server
  registers as `mcp__plugin_sdlc_playwright-test__*`, but `npx playwright init-agents` writes
  agents that reference the bare `mcp__playwright-test__*`. Shipping the server in the scaffold
  makes the names match, so the planner, generator, healer, qa-engineer, and product-owner all
  get their browser tools. Do not move it back into the plugin.
- **No agent pins a model.** Agents inherit the session model. Pinned frontier models caused
  five rate-limit stalls in one real seven-phase run. Override per call with the Agent tool's
  `model` parameter, or per project with a copy of the agent in `.claude/agents/`.
- **Port 4280, never 5000.** macOS AirPlay Receiver holds 5000. The port lives in the `env`
  block of the project's `.mcp.json` and in `playwright.config.ts`; both must agree.

Run `/sdlc:doctor` to check all of the above plus stale MCP processes and task-status drift.

Dependencies (auto-installed): `dotnet-skills@dotnet-skills`, `codex@openai-codex`.
Playwright agents are generated per project by `npx playwright init-agents --loop=claude`
(run by `scripts/setup.sh`), not shipped here.

Release: bump `version` in `.claude-plugin/plugin.json` and `../../.claude-plugin/marketplace.json`,
add a `../../CHANGELOG.md` entry, commit, then `claude plugin tag --push` from this directory.

History and the reasoning behind the design notes above: `../../CHANGELOG.md` and
`../../docs/retrospectives/`.
