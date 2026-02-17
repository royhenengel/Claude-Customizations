# Registry Consistency Check Research

## Problem Analysis

### Problem Domain

The Feature Registry in `planning/STATE.md` is a manually maintained markdown table that tracks feature lifecycle: name, type, status, branch, and worktree path. It's updated at lifecycle transitions (drafted, ready, active, complete) by the /start, /plan, and /build workflows.

Drift occurs because:

- Worktrees can be manually deleted without updating the registry
- Branches can be deleted (after merge) without clearing the registry entry
- Features can be completed and merged but registry status not updated
- New worktrees can be created outside the workflow (manual `git worktree add`)
- The /build step 13 (finalize changes) should clean up, but interruptions or skipped steps leave stale data

### Current State

No validation exists today. The /start workflow on main reads the registry and discovers worktrees independently but does not cross-reference them. If the registry says a feature is "active" with worktree at `.worktrees/foo`, and that directory doesn't exist, /start will silently show stale data.

The current STATE.md has 15 registry entries. 13 are "complete" with no branch/worktree (clean). 1 is "active" (instruction-compliance) and 1 is "drafted" (incident-report-command). Plus the current worktree (registry-consistency-check) is not yet registered.

## Information Gathered

### Codebase Analysis

**Registry format** (from STATE.md):

```markdown
| Feature | Type | Status | Branch | Worktree |
|---------|------|--------|--------|----------|
| feature-name | feature | active | branch-name | .worktrees/path |
```

**Status values**: drafted, ready, active, complete

**Where registry is read**:
- `/start` on main (start.md Step 1): reads registry, discovers worktrees
- `/build` Step 2 (build.md): reads registry to find features to build
- `/build` Step 4 (build.md): updates registry status to active
- `/build` Step 11 (build.md): updates registry status to complete
- `/plan` Step 9 (plan.md): adds new feature to registry as ready
- `/start` Option 1 (start.md): registers new feature as drafted

**Where worktrees are discovered**:
- `/start` on main: `git worktree list --porcelain`
- git-worktrees skill: creates worktrees in `.worktrees/`

**Worktree lifecycle**:
1. Created during /start (before /plan)
2. Registered in STATE.md as drafted/ready
3. Updated to active during /build
4. Set to complete after build
5. Removed during /build Step 13 (finalize)

### External Research

Not applicable. This is an internal workflow improvement.

## Tradeoff Analysis

| Factor | Choice Made | Alternative | Why This Choice |
|--------|-------------|-------------|-----------------|
| Implementation as skill vs script | Skill (SKILL.md) | Shell script in scripts/ | Skills are the project's pattern for Claude-executed logic. A script would need to parse markdown tables, which is complex in bash. Claude can parse the table natively. |
| Integration point | /start on main | Standalone only | /start is where developers see project state. Validation at this point catches issues early. Standalone remains available for on-demand use. |
| Fix mode | Report + suggest fixes | Auto-fix | Matches docs-enforcer pattern (audit by default, fix on request). Auto-fix risks losing data if the "correct" state is ambiguous. |
| Scope | Non-complete entries only | All entries | Complete entries with `-` for branch/worktree are already clean. Validating them adds noise with no value. |

### Risks

- Registry table format could change: mitigation is that the skill reads the table dynamically, not with hardcoded parsing
- /start workflow modification could conflict with other changes: mitigation is minimal, additive change (new substep)

## Architectural Implications

### System Boundaries

This feature sits between the Feature Registry (data) and the git/filesystem (reality). It acts as a consistency bridge.

### Dependencies

- `planning/STATE.md` Feature Registry table
- `git branch --list` for branch validation
- `git worktree list` for worktree validation
- Filesystem checks for worktree paths

### Integration Points

- `/start` workflow (start.md Step 1, main branch path): invoke validation after reading registry
- Standalone: invocable via `/validate-registry` or similar trigger

## Approach

Create a new skill at `skills/Planning/validate-registry/SKILL.md` that defines validation checks Claude should perform. Integrate a call to this validation into the /start workflow on main, after the Feature Registry is read but before the dashboard is displayed. The skill operates in audit mode by default (report only) with optional fix mode.

## Alternatives Considered

| Option | Pros | Cons | Decision |
|--------|------|------|----------|
| Skill (Claude instructions) | Fits project patterns, natural markdown parsing, interactive fix mode | Relies on Claude execution | SELECTED |
| Shell script (scripts/) | Automated, CI-runnable | Complex markdown parsing, no interactive fix | Rejected: project uses skills for workflow logic |
| Extend docs-enforcer | Reuses existing agent | docs-enforcer is for documentation structure, not registry state | Rejected: different concern |

## Key Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Implementation form | Skill (SKILL.md) | Consistent with project patterns, Claude can parse markdown natively |
| Where to validate | /start main + standalone | Catches issues at the natural checkpoint, also available on demand |
| Default behavior | Audit (read-only) | Safe default, matches docs-enforcer pattern |
| What to validate | Non-complete entries + unregistered worktrees | Complete entries with `-` paths are already clean |

## Open Questions

None. Requirements are clear from the backlog item.
