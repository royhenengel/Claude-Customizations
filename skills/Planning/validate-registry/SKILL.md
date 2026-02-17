---
name: validate-registry
description: Validate Feature Registry consistency against git branches, worktrees, and filesystem state. Detects stale entries, unregistered worktrees, and status mismatches.
---

Validate the Feature Registry in `planning/STATE.md` against actual git and filesystem state. Detect stale entries, unregistered worktrees, and status mismatches. Two modes: audit (default, read-only) and fix (applies corrections).

## When to Use

Triggers: "validate registry", "check registry", "registry health", "registry consistency"

## Audit Mode (Default)

Run all checks below, collect findings, and report. Do not modify any files.

### Step 1: Parse the Feature Registry

Read `planning/STATE.md` and extract the Feature Registry table. For each row, extract:

- **Feature**: the feature name
- **Type**: feature, fix, etc.
- **Status**: drafted, ready, active, complete
- **Branch**: branch name or `-`
- **Worktree**: path or `-`

Store all entries for use in the checks below.

### Step 2: Gather git state

```bash
git branch --list
```

```bash
git worktree list
```

```bash
git worktree list --porcelain
```

Store the branch list, worktree list, and porcelain output for use in checks.

Identify the main worktree (first entry in `git worktree list` output) and exclude it from unregistered-worktree detection.

### Step 3: Run validation checks

Run checks 1-5 against non-complete entries only. Run check 6 against complete entries only.

**Check 1 - Branch exists**

For each non-complete entry where Branch is not `-`:

```bash
git branch --list {branch}
```

If the result is empty, flag: `{feature}: Branch '{branch}' not found locally`

**Check 2 - Worktree path exists**

For each non-complete entry where Worktree is not `-`:

- If the path starts with `~`, expand it to the full home directory path
- If the path is relative (e.g., `.worktrees/foo`), resolve it from the git repository root

```bash
ls -d {resolved_path} 2>/dev/null
```

If the path does not exist, flag: `{feature}: Worktree path '{worktree}' does not exist`

**Check 3 - Git worktree registered**

For each non-complete entry where Worktree is not `-` and the path exists on disk (passed Check 2):

Check if the resolved path appears in the `git worktree list` output from Step 2.

If the path exists on disk but is not in the worktree list, flag: `{feature}: Path '{worktree}' exists but is not a registered git worktree`

**Check 4 - Unregistered worktrees**

From the `git worktree list` output (Step 2), exclude the main worktree (first entry).

For each remaining worktree path, check if any registry entry's resolved Worktree path matches it.

If a worktree has no matching registry entry, extract the branch name from the porcelain output (`branch refs/heads/{name}` line). If the worktree is in detached HEAD state (no `branch` line, or line reads `detached`), use "(detached)" as the branch name.

Flag: `Unregistered worktree: '{path}' on branch '{branch}' has no registry entry`

**Check 5 - Status consistency**

For each non-complete entry where Status is "active", "drafted", or "ready":

If both Branch is `-` (or branch does not exist per Check 1) AND Worktree is `-` (or path does not exist per Check 2), flag: `{feature}: Status is '{status}' but no branch or worktree exists (stale)`

**Check 6 - Complete but not cleaned**

For each complete entry where Worktree is not `-`:

Resolve the path (same rules as Check 2) and check if it exists on disk.

If the path exists, flag: `{feature}: Status is 'complete' but worktree at '{worktree}' still exists`

### Step 4: Report findings

Count total registry entries checked and total git worktrees found (excluding main).

**If issues were found:**

```text
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔍 Registry Validation
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Checked: {n} registry entries, {m} git worktrees

Issues:
- {feature}: {description} → Fix: {suggestion}

Run /validate-registry --fix to resolve.
```

For each issue, append a fix suggestion:

| Issue Type | Fix Suggestion |
|------------|---------------|
| Branch not found | Remove branch from registry or set status to complete |
| Worktree path missing | Clear worktree path or set status to complete |
| Path exists but not git worktree | Re-register worktree or remove path from registry |
| Unregistered worktree | Add entry to registry with status active |
| Stale status | Set status to complete |
| Complete but worktree exists | Run `git worktree remove {path}` and clear path |

**If no issues found:**

```text
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔍 Registry Validation
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Checked: {n} registry entries, {m} git worktrees

✅ No issues found
```

## Fix Mode

Invocation: `/validate-registry --fix`

### Step 1: Run audit

Execute all audit mode checks (Steps 1-3 above). Collect every issue with its type, feature name, and relevant details (branch, path, status).

If no issues are found, report the clean audit result and stop.

### Step 2: Propose fixes

For each issue, determine the proposed fix:

| Issue Type | Proposed Fix |
|------------|-------------|
| Branch not found | Remove branch value from registry (set to `-`) or set status to `complete` |
| Worktree path missing | Clear worktree path (set to `-`) or set status to `complete` |
| Path exists but not git worktree | Re-register with `git worktree add` or remove path from registry |
| Unregistered worktree | Add new entry to Feature Registry with discovered branch name and status `active` |
| Stale status (active/drafted, no branch/worktree) | Set status to `complete` and clear branch/worktree to `-` |
| Complete but worktree exists | Run `git worktree remove {path}` and `git branch -d {branch}` |

Present all proposed fixes:

```text
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔧 Registry Fix Mode
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Found {n} issues:

1. {feature}: {issue} → Proposed: {fix description}
2. {feature}: {issue} → Proposed: {fix description}

Apply all fixes? (confirm before proceeding)
```

### Step 3: Wait for confirmation

Do NOT apply any changes until the user confirms. If the user declines or wants to modify the plan, adjust accordingly.

### Step 4: Apply fixes

After confirmation, apply each fix in order:

**Registry table modifications** (branch, worktree, status changes):

Use the Edit tool to update the corresponding row in the Feature Registry table in `planning/STATE.md`. Match the row by feature name and replace the old cell values with the new ones.

**Worktree cleanup** (for "complete but worktree exists"):

```bash
git worktree remove {path}
```

```bash
git branch -d {branch}
```

If `git branch -d` fails because the branch is not fully merged, report the error and do NOT force-delete. Present the user with options: (a) force-delete with `git branch -D`, (b) skip branch deletion, (c) abort remaining fixes.

If `git worktree remove` fails (e.g., uncommitted changes), report the error and ask whether to force with `--force` or skip.

**Adding new registry entries** (for unregistered worktrees):

Use the Edit tool to append a new row to the Feature Registry table in `planning/STATE.md` with the discovered branch name, worktree path, and status `active`.

### Step 5: Report results

```text
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Registry Fixed
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Applied {n} fixes:
- {fix 1 summary}
- {fix 2 summary}
```
