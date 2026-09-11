# Specs

Markdown test plans produced by the `playwright-test-planner` agent and reviewed by the
`qa-engineer` agent. One file per feature or story: `specs/<STORY-NNN>-<kebab-title>.md`.

Each plan must reference the `REQ-` and `STORY-` IDs it covers and mirror the Given / When /
Then acceptance criteria from `docs/01-plan/`. The `playwright-test-generator` agent turns each
scenario into a test under `tests/e2e/`, tagged with the same IDs.
