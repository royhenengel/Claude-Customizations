# Registry Consistency Check Implementation Plan

## Objective

Create a validation skill that detects drift between the Feature Registry in STATE.md and actual git/filesystem state. Integrate it into the /start workflow so discrepancies surface automatically when viewing the project dashboard.

## Context

@planning/specs/registry-consistency-check/SPEC.md
@planning/specs/registry-consistency-check/RESEARCH.md
@skills/Planning/my-workflow/workflows/start.md
@skills/Git/git-worktrees/SKILL.md

## Task Summary

| # | Task | Type | Dependencies | Blocking |
|---|------|------|--------------|----------|
| 1 | Define validation checks and expected behavior | auto | - | - |
| 2 | Create validate-registry skill (SKILL.md) | auto | Task 1 | - |
| 3 | Test skill against current STATE.md | checkpoint:human-verify | Task 2 | yes |
| 4 | Integrate validation into /start workflow | auto | Task 3 | - |
| 5 | Test /start integration on main branch | checkpoint:human-verify | Task 4 | yes |
| 6 | Add fix mode to the skill | auto | Task 3 | - |
| 7 | Final verification and documentation | auto | Tasks 5, 6 | - |

## Tasks

### Task 1: Define validation checks and expected behavior

**Type**: auto
**Files**: (working document, feeds into Task 2)
**Dependencies**: None

**Context**: Before writing the skill, define exactly what checks it performs and what output looks like. This is the "spec" for the skill's behavior.

**Action**:

Define these validation checks:

1. **Branch exists**: For each non-complete entry with a branch value, run `git branch --list {branch}`. Flag if empty.
2. **Worktree path exists**: For each non-complete entry with a worktree path, check `ls -d {path}`. Flag if missing.
3. **Git worktree registered**: For each non-complete entry with a worktree path, verify it appears in `git worktree list` output. Flag if absent (path exists but not a git worktree).
4. **Unregistered worktrees**: Parse `git worktree list` output, exclude main. For each worktree not in the registry, flag as unregistered.
5. **Status consistency**: If status is "active" or "drafted" but neither branch nor worktree exist, flag as stale.
6. **Complete but not cleaned**: If status is "complete" but worktree path still exists, flag as needs cleanup.

Define output format:

```text
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔍 Registry Validation
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Checked: {n} registry entries, {m} git worktrees

Issues:
- {feature}: {description} → Fix: {suggestion}

✅ No issues found (if clean)
```

**Verify**: Checks cover all scenarios from SPEC.md requirements
**Done**: All 6 checks defined with expected output format

---

### Task 2: Create validate-registry skill (SKILL.md)

**Type**: auto
**Files**: `skills/Planning/validate-registry/SKILL.md`
**Dependencies**: Task 1

**Context**: The skill must follow existing skill patterns (frontmatter with name + description, clear instructions for Claude). It should be self-contained and reference no external files except STATE.md.

**Action**:

Create `skills/Planning/validate-registry/SKILL.md` with:

- Frontmatter: name, description, triggers (e.g., "validate registry", "check registry", "registry health")
- Purpose section explaining what it does
- Audit mode (default): read-only, report findings
- Checks section with all 6 validation checks from Task 1
- Each check includes the bash commands to run and how to interpret results
- Output format matching the workflow visual style (thick lines, icons)
- Fix mode section (placeholder, implemented in Task 6)

Follow existing skill patterns:
- Direct, imperative instructions
- Bash commands for data gathering
- Clear decision logic for interpreting results
- Structured output format

**Verify**: Skill file has valid frontmatter, all 6 checks documented, output format defined
**Done**: SKILL.md exists at correct path with complete audit mode instructions

---

### Task 3: Test skill against current STATE.md

**Type**: checkpoint:human-verify
**Blocking**: yes
**Files**: `planning/STATE.md`
**Dependencies**: Task 2

**Context**: The current STATE.md has known state (13 complete, 1 active, 1 drafted, plus this unregistered worktree). Run the validation to verify it produces accurate results.

**Action**:

1. Invoke the skill (run `/validate-registry` or equivalent)
2. Verify it correctly identifies:
   - `instruction-compliance`: check if worktree at `~/worktrees/claude-customizations/instruction-compliance` exists
   - `incident-report-command`: check if worktree at `.worktrees/incident-report-command` exists
   - `registry-consistency-check`: this worktree exists but is NOT in the registry (should be flagged as unregistered)
3. Verify complete entries are skipped
4. Verify output format matches spec

**Verify**: Manual verification of output accuracy
**Done**: Human confirms validation output matches actual state

---

### Task 4: Integrate validation into /start workflow

**Type**: auto
**Files**: `skills/Planning/my-workflow/workflows/start.md`
**Dependencies**: Task 3

**Context**: The /start workflow on main already reads the Feature Registry (Step 1). Validation should run after registry read, before the dashboard display. If issues are found, they appear as a warning block before the normal dashboard.

**Action**:

Add a validation substep to start.md Step 1 (main branch path), after reading the Feature Registry and discovering worktrees but before displaying the dashboard.

Insert between the worktree discovery and the "Project Status" banner:

```text
**Validate registry consistency** (invoke validate-registry skill logic):
1. Run the 6 checks from validate-registry skill
2. If issues found, display warning block before dashboard
3. If no issues, skip silently (don't add noise to clean state)
```

The validation block should appear as:

```text
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚠️ Registry Issues
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

- {issue 1}
- {issue 2}

Run /validate-registry --fix to resolve.
```

Keep the change minimal. Add a reference to the validation skill, not duplicate logic.

**Verify**: start.md has the new substep, references validate-registry skill
**Done**: /start workflow includes registry validation for main branch

---

### Task 5: Test /start integration on main branch

**Type**: checkpoint:human-verify
**Blocking**: yes
**Files**: `skills/Planning/my-workflow/workflows/start.md`
**Dependencies**: Task 4

**Context**: Verify the /start workflow shows validation results when run on main. Requires switching to main branch to test.

**Action**:

1. Switch to main branch (or instruct user to test in main worktree)
2. Run `/start`
3. Verify validation results appear before dashboard (if issues exist)
4. Verify clean state produces no extra output

**Verify**: Manual verification in main worktree
**Done**: Human confirms /start shows validation results correctly

---

### Task 6: Add fix mode to the skill

**Type**: auto
**Files**: `skills/Planning/validate-registry/SKILL.md`
**Dependencies**: Task 3

**Context**: Fix mode should offer to resolve each issue. Some fixes are safe (remove stale entry, add missing entry), others need user input (status correction).

**Action**:

Add fix mode section to the skill:

1. Run all audit checks first
2. For each issue, propose a fix:
   - **Stale entry (branch/worktree gone)**: Suggest removing entry or setting status to complete
   - **Unregistered worktree**: Suggest adding entry with discovered branch name and status "active"
   - **Complete but worktree exists**: Suggest running cleanup (`git worktree remove`)
   - **Status mismatch**: Present options for correct status
3. Present all proposed fixes as a numbered list
4. Wait for user confirmation before applying
5. Apply fixes to STATE.md (Edit tool for registry table)

Invocation: `/validate-registry --fix` or "validate and fix registry"

**Verify**: Fix mode documented with all fix actions for each issue type
**Done**: SKILL.md has complete fix mode instructions

---

### Task 7: Final verification and documentation

**Type**: auto
**Files**: `skills/Planning/validate-registry/SKILL.md`, `skills/Planning/my-workflow/workflows/start.md`
**Dependencies**: Tasks 5, 6

**Context**: Ensure everything is consistent and complete.

**Action**:

1. Re-read the skill and /start integration to verify consistency
2. Verify the skill triggers are discoverable (skill description matches common invocation patterns)
3. Verify the /start integration is minimal and clean
4. Run a final validation against current STATE.md to confirm accuracy

**Verify**: All artifacts consistent, validation produces accurate results
**Done**: Feature ready for PR

## Verification

- [ ] Skill correctly identifies stale registry entries
- [ ] Skill correctly identifies unregistered worktrees
- [ ] Skill correctly identifies status mismatches
- [ ] /start workflow shows validation warnings on main
- [ ] Fix mode proposes correct resolutions
- [ ] No false positives on clean registry entries (complete with `-` values)

## Success Criteria

- Running validation against current STATE.md produces accurate results for all known discrepancies
- /start on main shows discrepancies before presenting the dashboard
- Fix mode resolves issues with user confirmation
