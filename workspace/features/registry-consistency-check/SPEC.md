# Registry Consistency Check Specification

## Goal

Detect and report when the Feature Registry in `planning/STATE.md` drifts from actual git/worktree state. Prevent stale entries from accumulating and ensure the registry remains a reliable source of truth for project status.

## User Stories

- As a developer running `/start` on main, I want to see registry discrepancies so that I know which entries are stale before picking work
- As a developer cleaning up after feature completion, I want validation that the registry reflects reality so that nothing is orphaned
- As a developer resuming work, I want confidence that the Feature Registry accurately represents active features

## Requirements

### Functional

- [ ] Cross-reference registry entries against git branches (`git branch --list`)
- [ ] Cross-reference registry entries against worktree paths (filesystem check)
- [ ] Cross-reference registry entries against `git worktree list` output
- [ ] Detect orphaned registry entries: branch/worktree listed but doesn't exist
- [ ] Detect unregistered worktrees: worktree exists but not in registry
- [ ] Detect status mismatches: entry says "active" but no worktree exists, or "complete" but worktree still exists
- [ ] Report discrepancies with clear descriptions and suggested fixes
- [ ] Integrate into /start workflow (main branch dashboard) as automatic check
- [ ] Be invocable standalone for on-demand validation

### Non-Functional

- [ ] Validation completes in under 5 seconds
- [ ] No modifications to files in audit mode (read-only by default)
- [ ] Clear, structured output that fits the workflow visual style

## Constraints

- Must work within the existing my-workflow system (skill-based, markdown-driven)
- Must not require external dependencies (uses git CLI and filesystem checks only)
- Registry format is a markdown table, parsed by Claude (not a script)
- Validation logic lives as a skill (Claude instructions), not a standalone script

## Success Criteria

- [ ] Running validation against current STATE.md produces accurate results
- [ ] /start on main shows discrepancies before presenting the dashboard
- [ ] Stale entries are flagged with actionable fix suggestions
- [ ] Unregistered worktrees are detected and reported
