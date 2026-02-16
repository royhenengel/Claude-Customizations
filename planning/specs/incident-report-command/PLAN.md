# Incident Report - /fix Enhancement Plan

## Objective

Enhance the existing `/fix` skill with incident report generation and a defer/fix decision fork after the investigation phase. No new skill. Modify `skills/Code-Quality/fix/SKILL.md`.

## Context

@planning/specs/incident-report-command/SPEC.md
@planning/specs/incident-report-command/RESEARCH.md
@skills/Code-Quality/fix/SKILL.md
@skills/Planning/my-workflow/templates/incident-template.md

## Task Summary

| # | Task | Type | Dependencies | Blocking |
| - | ---- | ---- | ------------ | -------- |
| 1 | Walk through existing /fix flow step by step | research | - | - |
| 2 | Design insertion point and report generation step | design | Task 1 | - |
| 3 | Design decision fork (defer or fix now) | design | Task 2 | - |
| 4 | Implement report generation step in /fix SKILL.md | auto | Task 3 | - |
| 5 | Implement decision fork in /fix SKILL.md | auto | Task 4 | - |
| 6 | Implement defer path (backlog + cross-reference) | auto | Task 5 | - |
| 7 | Update incident-template.md to match report format | auto | Task 4 | - |
| 8 | End-to-end verification | checkpoint:human-verify | Tasks 6-7 | yes |

## Tasks

### Task 1: Walk through existing /fix flow step by step

**Type**: research
**Files**: `skills/Code-Quality/fix/SKILL.md` (read)
**Dependencies**: None

**Context**: Before modifying /fix, understand every step of the current workflow. Read the full SKILL.md and document what each step does, what data it produces, and where incident report content naturally emerges.

**Action**:

1. Read `skills/Code-Quality/fix/SKILL.md` end to end
2. For each step, document: what it does, what output it produces, what data could feed the incident report
3. Identify the exact insertion point for report generation (after Step 5, before Step 6)
4. Note any steps that need adjustment to support the defer path

**Verify**: Complete understanding of current /fix flow documented
**Done**: Step-by-step analysis with insertion point identified

---

### Task 2: Design insertion point and report generation step

**Type**: design
**Files**: `skills/Code-Quality/fix/SKILL.md` (read)
**Dependencies**: Task 1

**Context**: Using the step-by-step analysis from Task 1, design how report generation fits between Step 5 (Root Cause) and Step 6 (Propose Fix). The report should use data already gathered in Steps 2-5.

**Action**:

1. Map each report section to its data source in existing /fix steps
2. Design the new step (Step 5a or renumber): severity classification, report generation, file storage
3. Determine if any existing steps need modification to produce data in the right format
4. Decide whether to use parallel agents or synthesize directly from step outputs

**Verify**: Report generation design uses existing step outputs without duplication
**Done**: Design documented with section-to-step mapping

---

### Task 3: Design decision fork (defer or fix now)

**Type**: design
**Files**: `skills/Code-Quality/fix/SKILL.md` (read)
**Dependencies**: Task 2

**Context**: After the report is generated, the user decides: defer (add to backlog, done) or fix now (continue to Step 6). This must integrate cleanly with the existing flow, including worktree scenarios.

**Action**:

1. Design the decision prompt (presentation of report summary + options)
2. Design the defer path: how to append to BACKLOG.md with cross-reference
3. Ensure the "fix now" path continues seamlessly into existing Step 6
4. Handle worktree scenarios (Scenario A fix worktree, Scenario B feature worktree, main branch)

**Verify**: Both paths work for all worktree scenarios
**Done**: Decision fork design with defer and fix paths specified

---

### Task 4: Implement report generation step in /fix SKILL.md

**Type**: auto
**Files**: `skills/Code-Quality/fix/SKILL.md` (modify)
**Dependencies**: Task 3

**Context**: Insert the report generation step into the existing /fix SKILL.md after Step 5.

**Action**:

1. Add severity classification (if not already captured in Step 1)
2. Add report generation using data from Steps 2-5
3. Write report to `planning/specs/{feature}/INCIDENT-{date}-{slug}.md`
4. Keep the step concise to stay within 400-line limit

**Verify**: Report generates correctly with all required sections
**Done**: Report generation step added to SKILL.md

---

### Task 5: Implement decision fork in /fix SKILL.md

**Type**: auto
**Files**: `skills/Code-Quality/fix/SKILL.md` (modify)
**Dependencies**: Task 4

**Context**: Add the defer/fix decision after report generation.

**Action**:

1. Present report summary with defer/fix options
2. "Fix now" continues to existing Step 6 (no changes needed downstream)
3. "Defer" triggers the backlog integration path

**Verify**: Decision fork presents correctly and both paths route correctly
**Done**: Decision fork integrated into SKILL.md

---

### Task 6: Implement defer path (backlog + cross-reference)

**Type**: auto
**Files**: `skills/Code-Quality/fix/SKILL.md` (modify)
**Dependencies**: Task 5

**Context**: When user chooses "defer," add the issue to BACKLOG.md with a cross-reference to the incident report, then exit the /fix workflow.

**Action**:

1. Read BACKLOG.md to find correct insertion point
2. Append issue with cross-reference to incident report file
3. Display confirmation with backlog entry and report path
4. Exit /fix workflow (skip Steps 6-10)

**Verify**: Backlog entry created with correct cross-reference link
**Done**: Defer path creates backlog entry and exits cleanly

---

### Task 7: Update incident-template.md to match report format

**Type**: auto
**Files**: `skills/Planning/my-workflow/templates/incident-template.md` (modify)
**Dependencies**: Task 4

**Context**: Keep the manual template in sync with the automated report format.

**Action**:
Replace contents of `incident-template.md` with the report template used in Task 4, using `{placeholder}` syntax.

**Verify**: Template matches generated report structure
**Done**: Template updated

---

### Task 8: End-to-end verification

**Type**: checkpoint:human-verify
**Blocking**: yes
**Dependencies**: Tasks 6, 7

**Action**:

1. /fix SKILL.md still under 400 lines
2. Report generation step uses data from Steps 2-5
3. Decision fork handles both defer and fix paths
4. Defer path creates backlog entry with cross-reference
5. Fix path continues to Step 6 unchanged
6. Incident template matches report format
7. No hardcoded paths
8. All worktree scenarios handled

**Verify**: Human reviews and approves
**Done**: Enhancement approved for merge

## Verification

- [ ] /fix SKILL.md modified (not a new skill)
- [ ] SKILL.md under 400 lines
- [ ] Report generation uses existing step outputs (no duplication)
- [ ] Decision fork: defer creates backlog entry with cross-reference
- [ ] Decision fork: fix continues to Step 6 unchanged
- [ ] Report has all required sections
- [ ] `incident-template.md` updated to match
- [ ] No hardcoded paths
- [ ] All worktree scenarios (fix worktree, feature worktree, main) handled

## Success Criteria

- /fix generates an incident report after investigation phase
- Root cause analysis uses Five Whys method and produces actionable findings
- Defer path: issue appears in BACKLOG.md with report cross-reference
- Fix path: continues through existing /fix Steps 6-10 unchanged
- Report format matches standardized template across different incident types
