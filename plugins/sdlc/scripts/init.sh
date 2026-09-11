#!/usr/bin/env bash
# Scaffold the AI-driven SDLC workflow into a project. Idempotent: never overwrites existing files.
# Usage: init.sh <project-dir> [--no-setup]
set -euo pipefail
TARGET="${1:?project dir required}"; shift || true
RUN_SETUP=1; [ "${1:-}" = "--no-setup" ] && RUN_SETUP=0
HERE="$(cd "$(dirname "$0")/.." && pwd)"; SC="$HERE/scaffold"
cd "$TARGET"
ok(){ printf '\033[32m✔\033[0m %s\n' "$*"; }; skip(){ printf '\033[2m·\033[0m %s (exists, kept)\n' "$*"; }

copy() { # copy <src-rel> <dst-rel>
  if [ -e "$2" ]; then skip "$2"; else mkdir -p "$(dirname "$2")"; cp -R "$SC/$1" "$2"; ok "$2"; fi
}
# 1. docs skeleton, templates, logs
for f in $(cd "$SC/docs" && find . -type f | sed 's#^\./##'); do copy "docs/$f" "docs/$f"; done
for d in 01-plan/tickets 02-design/adr 02-design/api 03-tasks/tickets; do mkdir -p "docs/$d"; done
# 2. workflow docs and configs
copy WORKFLOW.md WORKFLOW.md
copy .codex/config.toml .codex/config.toml
copy playwright.config.ts playwright.config.ts
copy package.json package.json
copy tests/e2e/seed.spec.ts tests/e2e/seed.spec.ts
copy specs/README.md specs/README.md
copy scripts/setup.sh scripts/setup.sh; chmod +x scripts/setup.sh
if [ -e .gitignore ]; then
  grep -q 'settings.local.json' .gitignore || { printf '\n# Claude Code local overrides\n.claude/settings.local.json\nnode_modules/\ntest-results/\nplaywright-report/\n' >> .gitignore; ok ".gitignore (appended)"; }
else cp "$SC/gitignore" .gitignore; ok ".gitignore"; fi
# 3. CLAUDE.md section (append once, marker-guarded)
if [ -e CLAUDE.md ] && grep -q 'sdlc-plugin:begin' CLAUDE.md; then skip "CLAUDE.md sdlc section"
else { [ -e CLAUDE.md ] && printf '\n' >> CLAUDE.md || printf '# CLAUDE.md\n\nThis file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.\n\n' > CLAUDE.md; cat "$SC/CLAUDE.sdlc.md" >> CLAUDE.md; ok "CLAUDE.md (sdlc section appended)"; }; fi
# 4. .claude/settings.json deep-merge (existing keys win)
mkdir -p .claude
node - "$SC/settings.sdlc.json" .claude/settings.json <<'JS'
const fs=require('fs');const [src,dst]=process.argv.slice(2);
const add=JSON.parse(fs.readFileSync(src,'utf8'));
let cur={};try{cur=JSON.parse(fs.readFileSync(dst,'utf8'))}catch{}
const merge=(a,b)=>{for(const k of Object.keys(b)){if(Array.isArray(b[k])){a[k]=a[k]??b[k]}else if(b[k]&&typeof b[k]==='object'){a[k]=merge(a[k]??{},b[k])}else if(!(k in a)){a[k]=b[k]}}return a};
fs.writeFileSync(dst,JSON.stringify(merge(cur,add),null,2)+'\n');
JS
ok ".claude/settings.json (merged)"
# 5. Playwright agents (project-local, generated) and plugins/tooling
if [ "$RUN_SETUP" = 1 ]; then
  ./scripts/setup.sh
else
  echo; echo "Skipped setup. Run ./scripts/setup.sh to install plugins, Playwright, and generate the Playwright agents."
fi
echo; ok "sdlc workflow scaffolded. Restart Claude Code (or /reload-plugins), approve the playwright-test MCP server, then run /sdlc:plan <feature>."
