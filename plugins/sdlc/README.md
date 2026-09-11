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
| `skills/` | `/sdlc:init`, `/sdlc:plan`, `/sdlc:design`, `/sdlc:breakdown`, `/sdlc:implement`, `/sdlc:review`, `/sdlc:triage`, `/sdlc:test`, `/sdlc:validate`, `/sdlc:log`, `/sdlc:status` |
| `.mcp.json` | `playwright-test` MCP server for the Playwright agents |
| `scaffold/` | Everything `/sdlc:init` copies into a project: docs, templates, logs, WORKFLOW.md, CLAUDE.md section, settings, Codex and Playwright config, setup script |
| `scripts/init.sh` | The idempotent scaffold installer |

Dependencies (auto-installed): `dotnet-skills@dotnet-skills`, `codex@openai-codex`.
Playwright agents are generated per project by `npx playwright init-agents --loop=claude`
(run by `scripts/setup.sh`), not shipped here.

Release: bump `version` in `.claude-plugin/plugin.json` and `../../.claude-plugin/marketplace.json`,
commit, then `claude plugin tag --push` from this directory.
