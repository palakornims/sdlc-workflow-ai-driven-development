#!/usr/bin/env bash
# Bootstrap this workflow on a new machine.
#
# Required Claude Code plugins (installed at project scope, recorded in .claude/settings.json):
#   sdlc@sdlc-workflow            the workflow itself: phase agents and /sdlc:* commands
#   dotnet-skills@dotnet-skills   .NET / C# practices used by dotnet-developer and code-reviewer
#   codex@openai-codex            OPTIONAL OpenAI Codex second reviewer (Code Review phase);
#                                 installed only when sdlc.config.json has "codexReview": true
#
# Playwright (Phase 6): installs npm deps and browsers, regenerates the Playwright agents
#   (.claude/agents/playwright-test-*.md) with `npx playwright init-agents --loop=claude`.
#
# Required tools checked (warn only): .NET SDK, GitHub CLI, Docker; Codex CLI only if codexReview is on.
# Idempotent: safe to rerun. Usage: ./scripts/setup.sh
set -euo pipefail

# name|github repo|plugin id
PLUGINS=(
  "sdlc-workflow|palakornims/sdlc-workflow-ai-driven-development|sdlc@sdlc-workflow"
  "dotnet-skills|Aaronontheweb/dotnet-skills|dotnet-skills@dotnet-skills"
)

ok()   { printf '\033[32m✔\033[0m %s\n' "$*"; }
warn() { printf '\033[33m!\033[0m %s\n' "$*"; }
fail() { printf '\033[31m✘\033[0m %s\n' "$*" >&2; exit 1; }

# 1. Claude Code CLI
if ! command -v claude >/dev/null 2>&1; then
  fail "Claude Code CLI not found. Install it first: https://code.claude.com/docs/en/setup"
fi
ok "Claude Code $(claude --version 2>/dev/null | head -1)"

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CODEX_REVIEW=0
grep -Eq '"codexReview"[[:space:]]*:[[:space:]]*true' "$REPO_DIR/sdlc.config.json" 2>/dev/null && CODEX_REVIEW=1
if [ "$CODEX_REVIEW" = 1 ]; then
  PLUGINS+=("openai-codex|openai/codex-plugin-cc|codex@openai-codex")
else
  ok "Codex review is off (sdlc.config.json); skipping the Codex plugin. Enable with /sdlc:codex on"
fi
plugin_state() {
  # prints "installed enabled" flags for plugin $1 scoped to this repo, e.g. "1 1"
  claude plugin list --json 2>/dev/null | python3 -c '
import json, sys
plugin, repo = sys.argv[1], sys.argv[2]
rows = [r for r in json.load(sys.stdin)
        if r.get("id") == plugin and r.get("scope") == "project" and r.get("projectPath") == repo]
print(int(bool(rows)), int(any(r.get("enabled") for r in rows)))
' "$1" "$REPO_DIR" 2>/dev/null || echo "0 0"
}

for entry in "${PLUGINS[@]}"; do
  IFS='|' read -r MARKETPLACE_NAME MARKETPLACE_REPO PLUGIN <<<"$entry"

  # 2. Marketplace (idempotent)
  if claude plugin marketplace list 2>/dev/null | grep -q "$MARKETPLACE_NAME"; then
    ok "Marketplace '$MARKETPLACE_NAME' already registered"
  else
    claude plugin marketplace add "$MARKETPLACE_REPO"
    ok "Marketplace '$MARKETPLACE_NAME' added from $MARKETPLACE_REPO"
  fi

  # 3. Plugin at project scope for THIS repo
  read -r INSTALLED ENABLED <<<"$(plugin_state "$PLUGIN")"
  if [ "$INSTALLED" = "1" ]; then
    ok "Plugin '$PLUGIN' already installed at project scope"
  else
    claude plugin install "$PLUGIN" --scope project
    ok "Plugin '$PLUGIN' installed at project scope"
    read -r INSTALLED ENABLED <<<"$(plugin_state "$PLUGIN")"
  fi

  # 4. Verify enabled
  if [ "$ENABLED" = "1" ]; then
    ok "Plugin '$PLUGIN' is enabled"
  else
    warn "Plugin '$PLUGIN' is not enabled. Run: claude plugin enable $PLUGIN --scope project"
  fi
done

# 5. Playwright project (Phase 6: Test)
if command -v npm >/dev/null 2>&1; then
  ok "Node $(node --version) / npm $(npm --version)"
  (cd "$REPO_DIR" && npm install --no-audit --no-fund --silent) && ok "Playwright npm dependencies installed"
  if [ "${SKIP_BROWSERS:-0}" = "1" ]; then
    warn "SKIP_BROWSERS=1: skipped Playwright browser download (run: npm run playwright:install)"
  else
    (cd "$REPO_DIR" && npx playwright install --with-deps chromium >/dev/null 2>&1) \
      && ok "Playwright Chromium installed" \
      || warn "Playwright browser install failed; run manually: npx playwright install --with-deps chromium"
  fi
  (cd "$REPO_DIR" && npx playwright init-agents --loop=claude >/dev/null 2>&1) \
    && ok "Playwright agents regenerated (.claude/agents/playwright-test-*.md)" \
    || warn "Playwright agent generation failed; run manually: npm run playwright:agents"
else
  warn "Node.js / npm not found. Install Node 20+ (https://nodejs.org) for the Playwright tests and agents."
fi

# 6. Toolchain checks (warn only; the Design phase pins the exact SDK in global.json)
if [ "$CODEX_REVIEW" = 1 ]; then
  if ! command -v codex >/dev/null 2>&1; then
    warn "Codex review is on but the Codex CLI is not found. Install: npm install -g @openai/codex, then codex login (or turn it off: /sdlc:codex off)"
  elif ! codex login status >/dev/null 2>&1; then
    warn "Codex review is on but Codex is not logged in. Run: codex login (or turn it off: /sdlc:codex off)"
  else
    ok "Codex CLI $(codex --version 2>/dev/null | head -1), logged in (config: .codex/config.toml)"
  fi
fi
if command -v dotnet >/dev/null 2>&1; then
  ok ".NET SDK $(dotnet --version 2>/dev/null)"
else
  warn ".NET SDK not found. Install from https://dotnet.microsoft.com/download before the Implement phase."
fi
if command -v gh >/dev/null 2>&1; then
  ok "GitHub CLI $(gh --version 2>/dev/null | head -1)"
else
  warn "GitHub CLI (gh) not found. The developer agent uses it to open PRs."
fi
if command -v docker >/dev/null 2>&1; then
  ok "Docker available (needed for Testcontainers integration tests)"
else
  warn "Docker not found. Testcontainers-based integration tests will not run."
fi

echo
# 7. Stale Playwright MCP servers from earlier sessions (they serve the OLD config)
STALE=$(ps -eo pid,command 2>/dev/null | grep 'run-test-mcp-server' | grep -v grep | wc -l | tr -d ' ')
if [ "${STALE:-0}" -gt 0 ]; then
  warn "$STALE Playwright MCP server process(es) already running. After changing .mcp.json they keep the old config; /reload-plugins does not respawn them. Run /sdlc:doctor --fix or kill them."
fi

ok "Setup complete. Start or restart Claude Code in this directory; run /reload-plugins in an open session."
echo "  Playwright MCP port is 4280 (never 5000: macOS AirPlay holds it). Run /sdlc:doctor if browser tools misbehave."
