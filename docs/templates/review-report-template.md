# REVIEW-TASK-NNN-<n>: <Task title>

| Field | Value |
|-------|-------|
| Task | TASK-NNN |
| Branch / PR | task/TASK-NNN-<title> / <link> |
| Base | main @ <sha> |
| Reviewer | code-reviewer agent |
| Date | <YYYY-MM-DD> |
| Verdict | Approve / Approve with comments / Request changes |
| Second reviewer | codex:rescue (supplied / requested / not needed) / sonnet-review (Codex off / Codex unavailable: <reason>) |

## Summary

## Findings

| ID (FND-) | Severity | Area | File:line | Finding | Required change |
|-----------|----------|------|-----------|---------|-----------------|

## Review standard results

| Area | Result | Notes |
|------|--------|-------|
| Scope and traceability | | |
| Correctness | | |
| Clean Architecture conformance | | |
| .NET / C# best practice (skills consulted: ...) | | |
| Slopwatch | | |
| Tests | | |
| Operability | | |

## OWASP Top 10:2025

| Code | Affected by this change? | Control from threat model | Correctly implemented? | Notes |
|------|--------------------------|---------------------------|------------------------|-------|
| A01:2025 Broken Access Control | | | | |
| A02:2025 Security Misconfiguration | | | | |
| A03:2025 Software Supply Chain Failures | | | | |
| A04:2025 Cryptographic Failures | | | | |
| A05:2025 Injection | | | | |
| A06:2025 Insecure Design | | | | |
| A07:2025 Authentication Failures | | | | |
| A08:2025 Software or Data Integrity Failures | | | | |
| A09:2025 Security Logging and Alerting Failures | | | | |
| A10:2025 Mishandling of Exceptional Conditions | | | | |

## Second-reviewer findings

Codex findings when Codex review is on; `sonnet-review` findings when it is off or unavailable.

| ID (FND-) | Source (rescue / review / adversarial / sonnet-review) | Finding | Verification | Classification | Action |
|-----------|----------------------------------------|---------|--------------|----------------|--------|

Suggested `/codex:rescue` or second-opinion prompt (if coverage is missing):

## Triage sheet

`docs/05-review/TRIAGE-TASK-NNN-<n>.md` (opened by this review; all findings above registered there).

## Instructions for the human

- [ ] Run `/codex:review` (only if Codex review is on)
- [ ] Run `/codex:adversarial-review` (only if Codex review is on; required for core/complex changes)
- [ ] Check `/codex:result` and send findings to Claude to act on (only if Codex review is on)
- [ ] Route required changes to the dotnet-developer agent for TASK-NNN
