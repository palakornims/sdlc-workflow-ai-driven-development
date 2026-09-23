---
name: codex
description: Turn the optional OpenAI Codex second review on or off for this project, or show its current state and whether the Codex CLI, login, and plugin are ready.
argument-hint: on | off | status
disable-model-invocation: true
allowed-tools: Read, Write, Edit, Bash(date:*), Bash(codex:*), Bash(command:*), Bash(claude plugin list:*)
---

# /sdlc:codex — toggle the Codex second review

Requested: $ARGUMENTS (empty means `status`)

## Current setting

!`cat sdlc.config.json 2>/dev/null || echo "no sdlc.config.json (Codex review is OFF by default)"`

## Codex readiness

!`command -v codex >/dev/null 2>&1 && { codex --version 2>/dev/null | head -1; codex login status 2>&1 | head -2; } || echo "Codex CLI not installed"`

!`claude plugin list 2>/dev/null | grep -i 'codex@openai-codex' || echo "codex@openai-codex plugin not installed"`

Timestamp now: !`date '+%Y-%m-%d %H:%M'`

## What Codex review does

When `codexReview` is `true`, `/sdlc:implement` and `/sdlc:review` run `/codex:rescue` on each
branch and the human is asked to run `/codex:review` (and `/codex:adversarial-review` for core
changes). When it is `false`, nothing touches Codex and `/sdlc:review` uses a Sonnet run of
`code-reviewer` (second-opinion mode) as the second, independent reviewer instead. Codex needs
a ChatGPT plan or OpenAI API key; projects without one keep it off.

## Steps

1. **status** (or no argument): report the setting, and for each readiness item above say OK or
   what is missing. Change nothing.
2. **on**:
   - Set `"codexReview": true` in `sdlc.config.json` at the project root, creating the file as
     `{ "codexReview": true }` if missing and keeping any other keys.
   - If the CLI is missing, not logged in, or the plugin is not installed, still save the
     setting but tell the user exactly what to run:
     `npm install -g @openai/codex`, then `codex login`, then
     `claude plugin install codex@openai-codex --scope project`, then `/reload-plugins` and
     `/codex:setup`. Until then the workflow reports Codex as unavailable and falls back to
     the Sonnet second review; it does not fail.
3. **off**: set `"codexReview": false`, same file rules. Mention the Codex plugin can stay
   installed; it is simply not called, and reviews use the Sonnet second opinion.
4. For on or off, append one row to `docs/05-review/review-log.md` (logging rule):
   `| <timestamp> | — | — | human | Codex review turned <on/off> | sdlc.config.json | <readiness summary> |`.
5. Any other argument: explain the three forms and change nothing.
