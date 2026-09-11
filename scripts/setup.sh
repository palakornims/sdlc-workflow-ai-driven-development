#!/usr/bin/env bash
# Bootstrap this workflow on a new machine.
#
# Required Claude Code plugins (installed at project scope, recorded in .claude/settings.json):
#   dotnet-skills@dotnet-skills   .NET / C# practices used by dotnet-developer and code-reviewer
#   codex@openai-codex            OpenAI Codex second reviewer used in the Code Review phase
#
# Playwright (Phase 6): installs npm deps and browsers, regenerates the Playwright agents
#   (.claude/agents/playwright-test-*.md) with `npx playwright init-agents --loop=claude`.
#
# Required tools checked (warn only): Codex CLI, .NET SDK, GitHub CLI, Docker.
# Idempotent: safe to rerun. Usage: ./scripts/setup.sh
set -euo pipefail

# name|github repo|plugin id
PLUGINS=(
  "dotnet-skills|Aaronontheweb/dotnet-skills|dotnet-skills@dotnet-skills"
  "openai-codex|openai/codex-plugin-cc|codex@openai-codex"
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
if command -v codex >/dev/null 2>&1; then
  ok "Codex CLI $(codex --version 2>/dev/null | head -1) (config: .codex/config.toml)"
else
  warn "Codex CLI not found. Install with: npm install -g @openai/codex   (then run /codex:setup inside Claude Code)"
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
ok "Setup complete. Start or restart Claude Code in this directory; run /reload-plugins in an open session."
