---
name: doctor
description: Diagnose the sdlc workflow environment - MCP tool-name mismatches, stale or duplicate Playwright MCP server processes, port conflicts, missing tools, and status drift between task tickets and the backlog. Reports findings and the exact command to fix each one.
argument-hint: [--fix]
disable-model-invocation: true
allowed-tools: Read, Glob, Grep, Bash(ps:*), Bash(lsof:*), Bash(kill:*), Bash(node:*), Bash(npx:*), Bash(cat:*), Bash(ls:*), Bash(grep:*)
---

# /sdlc:doctor - check the workflow environment

Known failure modes from real runs. Each one is silent: nothing errors, the agent just quietly
cannot do its job. Run this when a Playwright agent reports no browser tools, when a page setup
fails, or at the start of a long session.

## Playwright MCP server processes

```!
ps -eo pid,lstart,command 2>/dev/null | grep -i 'run-test-mcp-server' | grep -v grep || echo "none running"
```

## Port 4280 and the macOS AirPlay port 5000

```!
lsof -nP -iTCP:4280 -sTCP:LISTEN 2>/dev/null || echo "4280 free"
lsof -nP -iTCP:5000 -sTCP:LISTEN 2>/dev/null | head -3 || echo "5000 free"
```

## MCP server declaration and configured port

```!
cat .mcp.json 2>/dev/null || echo "NO .mcp.json - run /sdlc:init or npx playwright init-agents --loop=claude"
```

## Tool-name prefix the agents expect

```!
grep -ho 'mcp__[a-z_]*playwright[a-z_-]*__' .claude/agents/*.md 2>/dev/null | sort -u || echo "no playwright agents found"
```

## Task status drift (ticket header vs backlog)

```!
grep -l '^| Status' docs/03-tasks/tickets/*.md 2>/dev/null | xargs grep -H '^| Status' 2>/dev/null | grep -v 'backlog.md' || echo "no ticket repeats status - good"
```

## Diagnose

Report each check as OK or a finding, with the fix:

1. **Multiple or stale MCP server processes.** More than one `run-test-mcp-server`, or one whose
   start time predates your last `.mcp.json` edit, means tool calls hit a process running the
   old config. `/reload-plugins` re-registers the tool schemas but does **not** respawn the
   child process. Fix: `kill <pid>`, then the next tool call spawns a fresh one.
2. **Port conflict.** If 4280 is taken, change the port in both `.mcp.json` (`env`) and
   `playwright.config.ts`, then kill the server process so it respawns. Never use 5000: macOS
   AirPlay Receiver holds it permanently, and the failure reads as `address already in use`.
3. **Tool-prefix mismatch.** The agents must reference the same prefix the server is registered
   under. A project-level `.mcp.json` registers `mcp__playwright-test__*`. A plugin-declared
   server would register `mcp__plugin_sdlc_playwright-test__*` instead. This plugin ships the
   server in the project scaffold precisely so the bare form matches what
   `npx playwright init-agents` generates. If the grep above shows a `plugin_` prefix, the
   agents were patched for an older layout: regenerate them with `npm run playwright:agents`.
4. **Status drift.** No ticket should carry its own status; `docs/03-tasks/backlog.md` is the
   single source of truth. Report any ticket that repeats it.
5. **Missing tools.** If any check could not run, say which tool is missing.

With `--fix`, additionally: kill duplicate MCP server processes (keep the newest), and report
what you killed. Change no files without saying so first.
