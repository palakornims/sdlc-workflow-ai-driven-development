# AI-Driven SDLC Workflow

A seven-phase software delivery workflow for Claude Code in which AI subagents draft every
artifact and humans own every approval. Backend stack is .NET / C#; end-to-end testing is
Playwright; OpenAI Codex is the second code reviewer.

```
Plan ──▶ Design ──▶ Breakdown ──▶ Implement ──▶ Code Review ──▶ Test ──▶ Validation
```

| Phase | Agent | Produces |
|-------|-------|----------|
| 1 Plan | `product-owner` | PRD, `REQ-` with Given/When/Then, `STORY-` tickets |
| 2 Design | `solution-architect` | Architecture (Clean Architecture), ADRs, contracts, threat model (OWASP Top 10:2025), gap analysis |
| 3 Breakdown | `project-manager` | `TASK-` tickets in tiers, delivery plan, risk register |
| 4 Implement | `dotnet-developer` | One task per branch and PR, using the `dotnet-skills` plugin |
| 5 Code Review | `code-reviewer` + Codex | Review report, `FND-` triage sheet, logged fixes |
| 6 Test | `qa-engineer` + Playwright agents | Test plan, `specs/`, `tests/e2e/`, test report |
| 7 Validation | `product-owner` (validation mode) | Traceability matrix, `VAL-` findings, release notes |

Two rules hold everything together: **no development starts until Plan, Design, and Breakdown
documents are written and approved**, and **every step and change is logged** with IDs, actors,
timestamps, and commit SHAs. Full detail in [`WORKFLOW.md`](WORKFLOW.md); agent conventions in
[`CLAUDE.md`](CLAUDE.md).

## Use it in any project (plugin)

```bash
cd your-project
claude plugin marketplace add palakornims/sdlc-workflow-ai-driven-development
claude plugin install sdlc@sdlc-workflow --scope project
claude
/sdlc:init            # scaffolds docs, templates, logs, WORKFLOW.md, CLAUDE.md section, settings, Playwright, Codex
/sdlc:doctor          # anytime: checks MCP tools, ports, stale processes, status drift
```

`/sdlc:init` never overwrites files you already have, and runs `scripts/setup.sh` to install the
`dotnet-skills` and `codex` dependencies, Playwright, and the Playwright agents.

## Or start from this repo as a template

```bash
git clone https://github.com/palakornims/sdlc-workflow-ai-driven-development.git
cd sdlc-workflow-ai-driven-development
./scripts/setup.sh      # installs sdlc, dotnet-skills, codex plugins, Playwright, checks toolchain
claude
```

Developing the plugin itself: `claude --plugin-dir ./plugins/sdlc`, then `/reload-plugins` after edits.

On first launch, approve the project-scoped `playwright-test` MCP server from `.mcp.json` so
the Playwright agents have browser tools.

Then run the phases as slash commands:

```
/plan <your feature>          /implement TASK-001        /test STORY-001
/design <your feature>        /review TASK-001           /validate STORY-001
/breakdown <your feature>     /triage TASK-001 <codex output>
/status                       /log <what you approved or ran>
```

Each command checks the previous gate, runs the right agents, and stops for your approval.

## Requirements

- Claude Code with access to Fable 5.1 (agents fall back to Opus via `fallbackModel`)
- .NET SDK, Node.js 20+, Docker (for Testcontainers), GitHub CLI (for PRs)
- Codex CLI for the Code Review phase; model pinned in `.codex/config.toml`

## Layout

```
plugins/sdlc/       the workflow as a plugin: agents/, skills/, scaffold/, scripts/init.sh
.claude-plugin/     marketplace manifest (this repo is the marketplace)
.claude/agents/     generated Playwright agents (project-local)
.claude/settings.json   model fallback, marketplaces, enabled plugins
docs/01-plan … 07-validation   phase artifacts and logs
docs/templates/     one template per artifact
specs/, tests/e2e/  Playwright test plans and generated tests
scripts/setup.sh    bootstrap on a new machine
```
