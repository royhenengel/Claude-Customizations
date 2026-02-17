---
name: fix
description: Thorough fix workflow with git history, root cause analysis, and regression prevention
arguments:
  - name: issue
    description: Description of the issue to fix (or leave blank for interactive)
    required: false
---

# /fix - Thorough Fix Workflow

A disciplined fix process that ensures complete solutions by consulting git history, respecting project conventions, and preventing regressions.

> **Timestamp Rule**: Whenever modifying STATE.md or PROGRESS.md in any step below, always update its `**Last Updated**` field to the current date.

## Step 1: Understand the Issue

Say:
```text
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔍 Investigating Project
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**If `{{issue}}` provided with sufficient detail** (covers the problem, expected behavior, and how to reproduce):

Summarize your understanding and proceed to Step 2. If the issue description has gaps, ask only for what's missing.

**If no `{{issue}}` provided or it lacks detail:**

### 1a. Relate to Past Work

Scan `planning/specs/` for feature directories. For each directory containing a SUMMARY.md, extract:
- Feature name (directory name, converted from kebab-case to title case)
- First sentence from the first `##` section after the metadata block

Present as a numbered list:

```
Is this related to past work?

1. {Feature Name} - {one-line summary}
2. {Feature Name} - {one-line summary}
...
N. Not related to past work

Pick a number, or describe the context directly:
```

If `planning/specs/` does not exist or contains no SUMMARY.md files, skip this step.

If user selected a feature, automatically include that feature's context (SPEC.md, PLAN.md, SUMMARY.md) in the git history search (Step 2).

### 1b. Gather Details

```
Please describe:
1. What's happening (the problem)
2. What should happen (expected behavior)
3. How to reproduce it (if known)
```

## Step 1a: Worktree Detection and State Setup

```bash
# Detect if running in a worktree
if [ -f .git ]; then echo "WORKTREE"; else echo "MAIN"; fi
```

**If in a worktree:**

Derive name from branch:
```bash
git branch --show-current
```

Check PROGRESS.md to determine context:
```bash
ls planning/specs/{name}/PROGRESS.md 2>/dev/null
```

Detect scenario: if PROGRESS.md has `**Type**: fix` or no PROGRESS.md exists → **fix worktree**. If PROGRESS.md has `**Type**: feature` or no Type field → **feature worktree**.

```text
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔍 Fix context: inside worktree ({name})
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Ask first (all worktree contexts):

```
Is this fix related to what you're working on now ({name})?

1. Yes, related
2. No, unrelated
```

**Related (option 1):**

- **Fix worktree**: If no PROGRESS.md exists, create fix state:
  ```bash
  mkdir -p planning/specs/{fix-name}
  ```
  Create `planning/specs/{fix-name}/PROGRESS.md` with `**Type**: fix`, `**Stage**: investigating`, Issue section from Step 1, and placeholder Root Cause / Proposed Fix sections. Update `planning/STATE.md` Feature Registry. Continue to Step 2 with full state tracking (Steps 2-10).

- **Feature worktree**: No separate fix state. Track findings in feature PROGRESS.md Notes section. Fix becomes part of the feature PR. Run Steps 2-8, skip Steps 9a and 10 (quality gates run with the feature's /build completion).

**Unrelated (option 2):**

Add to `planning/BACKLOG.md` for separate handling. Options:
  a. Create a fix worktree from main (commit current work first)
  b. Note for later, continue current work

Continue to Step 2 (related only).

**If on main** (not in a worktree):

Redirect to worktree creation. Fixes should not be developed directly on main.

```
Fixes require a dedicated worktree. Create one now?

1. Yes → Create fix worktree from main (invoke /git-worktrees)
2. No → Add to backlog for later
```

If yes, create worktree and restart /fix in the new worktree context. If no, add to `planning/BACKLOG.md` and exit.

## Step 2: Git History Search

**Check existing solutions first:** If `planning/solutions/` exists, search for matching problems. Present matches with filenames and titles. If user wants to review, read and assess applicability. Apply directly if matching; otherwise proceed.

Search for related past work via git log (keyword search, file-specific changes, recent commits). Document: related past fixes, similar issues addressed, patterns used, what was tried and why.

## Step 3: Read Project Conventions

Read CLAUDE.md, .editorconfig, linter configs, and other convention files. Identify code style, constraints the fix must respect, and project-specific rules.

## Step 4: Map Affected Areas

Identify what might be impacted: direct dependencies (what imports the code), reverse dependencies (what the code imports), related functionality (shared logic), and tests covering this area. Search for usages and test files.

## Step 5: Root Cause Analysis (Five Whys)

Analyze WHY the issue exists using the Five Whys method:

1. Start with the symptom (what user sees)
2. Ask "Why?" repeatedly until you reach the actionable root cause
3. Each "Why?" must be backed by evidence, not speculation
4. Stop when fixing the answer would prevent the original symptom (not all issues need 5 levels)

Document the analysis (adjust depth as needed):
```
Why 1: {symptom} → Because {immediate cause}
Why 2: {immediate cause} → Because {deeper cause}
[Continue until root cause reached]

Root Cause: {the fundamental issue to fix}
```

**State update** (worktree only): Update fix PROGRESS.md - set "Root Cause" section, stage → `proposed`.

## Step 5a: Incident Report

Classify severity (ask user): **critical** (production/data/security), **major** (broken functionality, workaround exists), **minor** (cosmetic/edge case).

Create `planning/incidents/` directory if needed. Generate `INCIDENT-{YYYY-MM-DD}-{slug}.md` (slug: kebab-case from issue description, max 5 words) using the incident report template, populated from investigation steps:

| Section | Source |
|---|---|
| Frontmatter (date, feature, severity) | Auto-detect + severity from above. Set Status: `open` |
| Summary | Synthesize Steps 1 + 5 (2-3 sentences) |
| What Happened | Step 1 issue description + Step 2 git history |
| Root Cause | Step 5 Five Whys output (direct copy) |
| Impact | Step 4 affected areas (narrative) |
| Affected Artifacts | Step 4 file mapping (reshape to table: File/Component, Impact) |
| Resolution | "Pending" |
| Prevention | Derived from root cause (actionable items) |
| Lessons Learned | Synthesis from all investigation steps |

Say:
```text
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 Incident Report Generated
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Report: planning/incidents/INCIDENT-{date}-{slug}.md
Severity: {severity}

Summary: {2-3 sentence summary}
```

## Step 5b: Triage Decision

```
How do you want to proceed?

1. Fix now → Continue to Step 6 (Propose Fix)
2. Defer → Add to backlog and exit
```

**Fix now (option 1):** Continue to Step 6.

**Defer (option 2):**

1. Create `planning/BACKLOG.md` if it doesn't exist. Append:
   ```
   - [ ] {Issue summary} - See [INCIDENT-{date}-{slug}](planning/incidents/INCIDENT-{date}-{slug}.md)
   ```
2. Update incident report: Status → `deferred`, Resolution → `Deferred to backlog. See planning/BACKLOG.md.`
3. Display confirmation and **exit /fix workflow** (skip Steps 6-10)

**State update** (worktree only): Update fix PROGRESS.md with triage decision, stage → `deferred`.

## Step 6: Propose Fix

Present the fix proposal with clear rationale:

```markdown
## Proposed Fix

### What
[Specific changes to make]

### Why
[How this addresses the root cause identified in Step 5]

### How it relates to past work
[Reference findings from Step 2 - why this approach vs. others]

### Risks
[What could go wrong, what else might be affected]
```

**State update** (worktree only): Update fix PROGRESS.md - set "Proposed Fix" section.

**STOP HERE** - Wait for user approval before implementing.

## Step 7: Implement & Verify

After approval:

1. **Implement** the fix
2. **Run tests** if they exist:
   ```bash
   # Run relevant tests
   npm test 2>/dev/null || yarn test 2>/dev/null || pytest 2>/dev/null || go test ./... 2>/dev/null
   ```
3. **Verify** the fix resolves the original issue

**State update** (worktree only): Update fix PROGRESS.md - stage → `implementing`, update Current State (What's Working, What's Not Working).

**Incident report update**: Update the report's Resolution section with the actual fix applied. Update Status: `open` → `resolved`.

## Step 8: Regression Checklist

Identify related areas for manual verification:

```markdown
### Regression Checklist

Based on the affected areas mapped in Step 4, please verify:

- [ ] [Specific file/feature 1]: [What to check]
- [ ] [Specific file/feature 2]: [What to check]
- [ ] [Specific file/feature 3]: [What to check]
```

Be specific - file names, functionality, scenarios to test.

**State update** (worktree only): Update fix PROGRESS.md - stage → `verifying`, update What's Working with verified items.

## Step 9: Convention Check

> **Note**: The incident report (Step 5a) already captures Prevention items from root cause analysis. Step 9 focuses on convention/process gaps, not the technical fix itself. Some overlap is expected and acceptable.

Evaluate if the fix reveals something convention-worthy:

**Ask yourself:**
- Did this issue stem from a missing convention or unclear guideline?
- Would a documented rule have prevented this issue?
- Is there a pattern here that should be formalized?

**If yes:**
1. Notify user inline:
   ```
   ⚠️ Convention Opportunity: This fix revealed [description]. Consider updating project conventions to [recommendation].
   ```
2. Propose backlog entry (if planning/BACKLOG.md exists). Present for user approval before appending:
   ```
   - [ ] [Convention description] - discovered during fix for [issue]
   ```

## Step 9a: Auto-Capture Solution

If the fix involved a non-trivial root cause (not a typo, missing import, or obvious error):

Automatically invoke `/compound` with context from this fix session. Pass the root cause analysis from Step 5 as context. If `/compound` fails for any reason, log a note and continue. Do not block the /fix workflow.

Do not prompt the user. After capture completes, display:

```text
Solution captured: planning/solutions/{category}/{filename}.md
```

The user can review, edit, or delete solutions at any time.

Skip for trivial fixes (typos, missing imports, obvious errors).

## Step 9b: Documentation & Quality Review

**Applies to all fix scenarios** (worktree fixes and main-branch fixes):

### Documentation Review

Launch **docs-enforcer** agent: audit documentation for the fix. Focus on fix state directory completeness, misplaced files, and documentation type system compliance. Provide results with severity levels.

### PR Review

After PR is created in Step 10, launch three review agents in parallel on the full PR diff:

1. **code-reviewer**: Code quality and consistency
2. **test-coverage-reviewer**: Test coverage, flag untested paths
3. **contracts-reviewer**: Public APIs, data models, type definitions for breaking changes

Present consolidated findings. Critical issues must be addressed before merge.

## Step 10: Finalize Changes

When user says "complete", "mark as complete", or similar:

All fixes run in worktrees (Step 1a redirects main to worktree creation).

1. **Commit and push**:
   - Stage all changes
   - Create conventional commit with fix summary
   - Push to remote

2. **Create PR** with fix summary

3. **Update incident report** with PR link (if report exists from Step 5a):
   Add to Resolution section: `Fixed in PR #{number} ({url})`

4. **Run Step 9b PR reviewers** (3 review agents first, then doc-enforcer last)

5. **Address critical findings** before merge

6. **Merge PR and delete branch**

7. Remove worktree: `git worktree remove {path}`

8. Update fix PROGRESS.md: stage → `complete`

9. Update project STATE.md Feature Registry: fix status → `complete`

**Note**: For in-feature fixes (Scenario B-related from Step 1a), Step 10 does not apply. The fix is committed as part of the feature's /build finalization.
