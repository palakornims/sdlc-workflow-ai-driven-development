---
name: init
description: Scaffold the AI-driven SDLC workflow into the current project - docs folders, templates, logs, WORKFLOW.md, CLAUDE.md section, settings, Codex and Playwright config, setup script. Idempotent; never overwrites existing files.
argument-hint: [--no-setup]
disable-model-invocation: true
allowed-tools: Bash(bash:*), Read, Glob
---

# /sdlc:init — scaffold the workflow into this project

Run the plugin's init script against the project root. It copies the scaffold without
overwriting anything that already exists, appends the workflow section to `CLAUDE.md` once,
deep-merges `.claude/settings.json` (existing keys win), and unless `--no-setup` is passed runs
`scripts/setup.sh` to install the required plugins, Playwright, and the Playwright agents.

```
bash "${CLAUDE_PLUGIN_ROOT}/scripts/init.sh" "${CLAUDE_PROJECT_DIR}" $ARGUMENTS
```

Then:

1. Show the user the script output verbatim.
2. Read the project's `CLAUDE.md` and confirm the sdlc section is present.
3. Tell the user: restart Claude Code or run `/reload-plugins`; approve the `playwright-test`
   MCP server when prompted; if `.codex/config.toml` pins a model they cannot use, change it;
   then start with `/sdlc:plan <feature>`.
4. Do not modify any file the script reported as "exists, kept".
