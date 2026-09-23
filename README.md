# AI-Driven SDLC Workflow

A seven-phase software delivery workflow for Claude Code in which AI subagents draft every
artifact and humans own every approval. Backend stack is .NET / C#; end-to-end testing is
Playwright; the second code reviewer is OpenAI Codex when turned on, otherwise a Sonnet review.

```
Plan ──▶ Design ──▶ Breakdown ──▶ Implement ──▶ Code Review ──▶ Test ──▶ Validation
```

| Phase | Agent | Produces |
|-------|-------|----------|
| 1 Plan | `product-owner` | PRD, `REQ-` with Given/When/Then, `STORY-` tickets |
| 2 Design | `solution-architect` | Architecture (Clean Architecture), ADRs, contracts, threat model (OWASP Top 10:2025), gap analysis |
| 3 Breakdown | `project-manager` | `TASK-` tickets in tiers, delivery plan, risk register |
| 4 Implement | `dotnet-developer` | One task per branch and PR, using the `dotnet-skills` plugin |
| 5 Code Review | `code-reviewer` + second reviewer (Codex, or Sonnet when Codex is off) | Review report, `FND-` triage sheet, logged fixes |
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
/sdlc:init            # scaffolds docs, templates, logs, WORKFLOW.md, CLAUDE.md section, settings, Playwright, sdlc.config.json
/sdlc:doctor          # anytime: checks MCP tools, ports, stale processes, status drift
/sdlc:codex on|off    # optional Codex second review (needs a ChatGPT plan or OpenAI API key)
```

`/sdlc:init` never overwrites files you already have, and runs `scripts/setup.sh` to install the
`dotnet-skills` dependency, Playwright, and the Playwright agents.

**Codex is optional.** `/sdlc:init` writes `sdlc.config.json` with `"codexReview": true` only
when the Codex CLI is installed and logged in, otherwise `false`. With it off, nothing calls Codex:
the second, independent review is a Sonnet run of the `code-reviewer` agent instead. Turn it on later with
`/sdlc:codex on` (it tells you what to install), off with `/sdlc:codex off`, and check with
`/sdlc:codex status`. If it is on but Codex fails at run time (logged out, quota), the phase
reports Codex as unavailable and falls back to the Sonnet review.

## Or start from this repo as a template

```bash
git clone https://github.com/palakornims/sdlc-workflow-ai-driven-development.git
cd sdlc-workflow-ai-driven-development
./scripts/setup.sh      # installs sdlc, dotnet-skills (+ codex if sdlc.config.json enables it), Playwright, checks toolchain
claude
```

Developing the plugin itself: `claude --plugin-dir ./plugins/sdlc`, then `/reload-plugins` after edits.

On first launch, approve the project-scoped `playwright-test` MCP server from `.mcp.json` so
the Playwright agents have browser tools.

Then run the phases as slash commands:

```
/sdlc:plan <your feature>       /sdlc:implement TASK-001   /sdlc:test STORY-001
/sdlc:design <your feature>     /sdlc:review TASK-001      /sdlc:validate STORY-001
/sdlc:breakdown <your feature>  /sdlc:triage TASK-001 [review output]
/sdlc:status                    /sdlc:log <what you approved or ran>
/sdlc:doctor                    # when something Playwright-related misbehaves
/sdlc:codex on|off|status       # toggle the optional Codex second review
```

Each command checks the previous gate, runs the right agents, and stops for your approval.

## What changed and why

[`CHANGELOG.md`](CHANGELOG.md) records every release. Findings from real runs, with the fix for
each, live in [`docs/retrospectives/`](docs/retrospectives/) - start with the
[first production run](docs/retrospectives/2026-09-13-first-production-run.md), which is where
most of v1.1.0 came from.

## Requirements

- Claude Code. No agent pins a model; they inherit your session model, so a frontier model is
  optional rather than required. Pass `model` per Agent call to spend a frontier budget where it
  matters.
- .NET SDK, Node.js 20+, Docker (for Testcontainers), GitHub CLI (for PRs)
- Optional: Codex CLI and a ChatGPT plan or OpenAI API key, only if you turn on Codex review;
  model pinned in `.codex/config.toml`

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
