# Delivery plan: <Feature or system>

| Field | Value |
|-------|-------|
| Status | Draft / In review / Approved |
| Author | project-manager agent |
| Approver | <tech lead> |
| Approved on | <YYYY-MM-DD> |
| PRD | PRD-NNN |
| Architecture | architecture-<feature>.md |

## 1. Summary

Tiers, milestone count, task count, total size by milestone (as a range), critical path.

## 2. Tiers and milestones

| Tier | Milestone | Exit criterion (demonstrable) | Tasks | Size total |
|------|-----------|-------------------------------|-------|------------|
| 0 Foundation | M1 | | | |
| 1 Walking skeleton | M2 | | | |
| 2 Main feature | M3 | | | |
| 3 Components and integrations | M4 | | | |
| 4 Hardening | M5 | | | |
| 5 Could-haves | M6 | | | |

## 3. Dependency graph

```mermaid
graph LR
  TASK-001 --> TASK-002
```

**Critical path:** TASK-001 → ... → TASK-NNN

## 4. Parallel lanes

| Lane | Tasks | Shared files to watch |
|------|-------|-----------------------|

## 5. Coverage check

| Source | Item | Covered by tasks |
|--------|------|------------------|
| STORY | STORY-NNN | TASK-NNN |
| DES | DES-NNN | TASK-NNN |
| Threat model | A0X:2025 control | TASK-NNN |
| Gap analysis | <gap> | TASK-NNN |

## 6. Human-input tasks

| Task | Needed by | Owner | Due before |
|------|-----------|-------|------------|

## 7. Risk register

| ID | Risk | Likelihood | Impact | Mitigation / spike | Owner |
|----|------|------------|--------|--------------------|-------|

## 8. Parked (out of scope)

Ideas raised during breakdown that are not traceable to an approved requirement.

## 9. Sent back to design

Design elements that could not be broken into tasks, with reasons.
