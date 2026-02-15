# Incident Report Command Implementation Plan

## Objective

Create a `/incident-report` skill that investigates incidents using parallel analysis agents, performs Five Whys root cause analysis, generates standardized reports, and auto-creates prevention items in the backlog.

## Context

@planning/specs/incident-report-command/SPEC.md
@planning/specs/incident-report-command/RESEARCH.md
@skills/Learning/compound/SKILL.md
@skills/Planning/my-workflow/templates/incident-template.md

## Task Summary

| # | Task | Type | Dependencies | Blocking |
|---|------|------|--------------|----------|
| 1 | Create SKILL.md with frontmatter and workflow skeleton | auto | - | - |
| 2 | Implement Step 1: Context detection and feature identification | auto | Task 1 | - |
| 3 | Implement Step 2: Parallel investigation agents | auto | Task 2 | - |
| 4 | Implement Step 3: Report generation from agent outputs | auto | Task 3 | - |
| 5 | Implement Step 4: Backlog integration (prevention items) | auto | Task 4 | - |
| 6 | Implement Step 5: Confirmation and output | auto | Task 5 | - |
| 7 | Update incident-template.md to match new standard | auto | Task 4 | - |
| 8 | Create symlink for skill discovery | auto | Task 6 | - |
| 9 | End-to-end verification | checkpoint:human-verify | Tasks 6-8 | yes |

## Tasks

### Task 1: Create SKILL.md with frontmatter and workflow skeleton

**Type**: auto
**Files**: `skills/Documentation/incident-report/SKILL.md` (create)
**Dependencies**: None

**Context**: The skill needs proper YAML frontmatter for slash command discovery and a complete step-based workflow structure. Following the /compound pattern as the closest analog.

**Action**:
Create `skills/Documentation/incident-report/SKILL.md` with:
- Frontmatter: `name: incident-report`, `description: Investigate incidents with root cause analysis and generate standardized reports`, `arguments: [{name: context, description: Brief description of the incident (or leave blank for auto-detect), required: false}]`
- Place in `Documentation` group (new group directory, alongside existing skills that generate docs)
- Skeleton with Steps 1-5 as section headers
- Relationship note linking to /fix and /compound (incident-report documents what went wrong, /compound documents solutions, /fix fixes issues)

**Verify**: File exists at correct path with valid YAML frontmatter
**Done**: SKILL.md created with frontmatter and skeleton structure

---

### Task 2: Implement Step 1: Context detection and feature identification

**Type**: auto
**Files**: `skills/Documentation/incident-report/SKILL.md` (modify)
**Dependencies**: Task 1

**Context**: The skill needs to identify what incident to report. It must work with explicit context (argument) or auto-detect from conversation. It also needs to determine which feature the incident belongs to and derive the output path.

**Action**:
Implement Step 1 in SKILL.md:

1. **If `{{context}}` provided**: Use as starting description
2. **If no context**: Scan conversation for incident indicators:
   - Error messages or failures
   - Process violations or workflow deviations
   - "Something went wrong" / "broke" / "failed" indicators
   - Ask user if unclear (multiple choice like /compound)
3. **Feature detection**:
   - If in worktree: derive feature name from branch (`git branch --show-current`)
   - If on main: ask which feature the incident relates to, or use "general"
4. **Severity classification**: Ask user to confirm severity (critical/major/minor) with descriptions:
   - Critical: data loss, security breach, production impact
   - Major: workflow broken, significant rework needed
   - Minor: inconvenience, cosmetic, workaround available

**Verify**: Step 1 logic handles both explicit and auto-detect paths
**Done**: Context detection produces incident description, feature name, and severity

---

### Task 3: Implement Step 2: Parallel investigation agents

**Type**: auto
**Files**: `skills/Documentation/incident-report/SKILL.md` (modify)
**Dependencies**: Task 2

**Context**: This is the core analysis step. Three parallel agents investigate different aspects of the incident. Following the /compound pattern of parallel agent invocation. Each agent should receive the incident description and relevant file context.

**Action**:
Implement Step 2 with 3 parallel agents:

**Agent 1 - Timeline Reconstructor:**
- Read conversation history for sequence of events
- Check git log for recent commits related to the incident
- Check git diff for relevant changes
- Produce chronological timeline with timestamps where available
- Output: Timeline table (Time | Event) and factual "What Happened" narrative

**Agent 2 - Root Cause Analyzer:**
- Receive incident description and timeline context
- Read relevant files mentioned in the incident
- Perform Five Whys analysis (mandatory, go 5 levels deep)
- Identify contributing factors
- Output: Five Whys chain, root cause statement, contributing factors list

**Agent 3 - Impact Assessor:**
- Check which files/artifacts were affected (git diff, file references)
- Assess scope of impact (single file, multiple files, workflow, architecture)
- Identify downstream effects
- Produce affected artifacts table
- Output: Impact summary, affected artifacts table (File | Status | Issue), severity validation

All 3 agents should use haiku model (per model-selection.md: lightweight workers).

**Verify**: All 3 agents produce structured output when invoked
**Done**: Investigation produces timeline, root cause analysis, and impact assessment

---

### Task 4: Implement Step 3: Report generation from agent outputs

**Type**: auto
**Files**: `skills/Documentation/incident-report/SKILL.md` (modify)
**Dependencies**: Task 3

**Context**: Synthesize agent outputs into a standardized incident report document. The report format must be consistent across all incidents.

**Action**:
Implement Step 3 - report generation:

1. **Derive filename**: `INCIDENT-{YYYY-MM-DD}-{slug}.md` where slug is kebab-case from incident description (max 40 chars)
2. **Derive storage path**: `planning/specs/{feature}/INCIDENT-{date}-{slug}.md`
3. **Ensure directory exists**: `mkdir -p planning/specs/{feature}/`
4. **Generate report** from template:

```markdown
# Incident Report: {Brief Description}

**Date**: {YYYY-MM-DD}
**Feature**: {feature name}
**Severity**: {critical|major|minor}
**Status**: Open

## Summary

{2-3 sentence summary synthesized from all agent outputs}

## What Happened

{Timeline Reconstructor output - factual narrative}

## Timeline

| Time | Event |
|------|-------|
{Timeline Reconstructor output - table}

## Root Cause

{Root Cause Analyzer output - Five Whys}

### Five Whys

1. **Why?** {first why}
2. **Why?** {second why}
3. **Why?** {third why}
4. **Why?** {fourth why}
5. **Why?** {fifth why}

**Root Cause**: {statement}

### Contributing Factors

- {factor 1}
- {factor 2}

## Impact

{Impact Assessor output - summary}

### Affected Artifacts

| File | Status | Issue |
|------|--------|-------|
{Impact Assessor output - table}

## Resolution

{What was done or needs to be done to address the immediate issue}

## Prevention

- [ ] {Actionable prevention item 1}
- [ ] {Actionable prevention item 2}

## Lessons Learned

- {Systemic insight 1}
- {Systemic insight 2}
```

5. **Write file** to derived path

**Verify**: Generated report contains all required sections with content from agents
**Done**: Report file written with complete, formatted content

---

### Task 5: Implement Step 4: Backlog integration

**Type**: auto
**Files**: `skills/Documentation/incident-report/SKILL.md` (modify)
**Dependencies**: Task 4

**Context**: Prevention items from the report must be appended to BACKLOG.md with a cross-reference to the incident report. This ensures systemic fixes are tracked.

**Action**:
Implement Step 4 - backlog integration:

1. **Read current BACKLOG.md** to determine correct insertion point
2. **Format prevention entries** with incident cross-reference:
   ```markdown
   - [ ] {Prevention item description}
     - **Incident**: [{report filename}](specs/{feature}/{report filename})
   ```
3. **Determine section**: Place under the most relevant existing category (Workflow Guardrails, Skill & Agent Architecture, Docs & Knowledge Capture, etc.). If no category fits, place under "Quick Wins" or ask user
4. **Append entries** to BACKLOG.md at the identified section
5. **Show user** what was added before writing (confirmation step)

**Verify**: Prevention items appear in BACKLOG.md with correct cross-reference links
**Done**: BACKLOG.md updated with prevention items linked to incident report

---

### Task 6: Implement Step 5: Confirmation and output

**Type**: auto
**Files**: `skills/Documentation/incident-report/SKILL.md` (modify)
**Dependencies**: Task 5

**Context**: Final step displays summary and file paths. Following existing skill patterns for completion output.

**Action**:
Implement Step 5 - confirmation output:

```text
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Incident Report Created
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Report: planning/specs/{feature}/INCIDENT-{date}-{slug}.md
Severity: {severity}
Root Cause: {one-line root cause}

Prevention items added to BACKLOG.md:
- {item 1}
- {item 2}
```

**Verify**: Output displays correct paths and summary
**Done**: Completion banner shown with all relevant information

---

### Task 7: Update incident-template.md to match new standard

**Type**: auto
**Files**: `skills/Planning/my-workflow/templates/incident-template.md` (modify)
**Dependencies**: Task 4

**Context**: The existing template is simpler than the new standard. Update it to match the report format defined in Task 4, so manual report creation (without the command) still produces consistent reports.

**Action**:
Replace contents of `incident-template.md` with the full report template from Task 4, using `{placeholder}` syntax for all variable fields. Preserve the template's role as a manual-use reference.

**Verify**: Template matches the report structure from Task 4
**Done**: Template updated with all required sections

---

### Task 8: Create symlink for skill discovery

**Type**: auto
**Files**: `skills/incident-report` (create symlink)
**Dependencies**: Task 6

**Context**: Claude Code discovers skills at depth 2. Skills in group directories need symlinks for discovery (per INCIDENT-2026-02-06-skill-discovery.md). The `Documentation` group is new and needs a symlink.

**Action**:
1. Create group directory if needed: `mkdir -p skills/Documentation/incident-report/`
2. Create symlink: `ln -s skills/Documentation/incident-report skills/incident-report`
3. Verify symlink works: `ls -la skills/incident-report/SKILL.md`

**Verify**: `ls skills/incident-report/SKILL.md` resolves correctly
**Done**: Skill discoverable as `/incident-report` slash command

---

### Task 9: End-to-end verification

**Type**: checkpoint:human-verify
**Blocking**: yes
**Dependencies**: Tasks 6, 7, 8

**Context**: Verify the complete skill works by reviewing the generated artifacts.

**Action**:
1. Verify SKILL.md has valid frontmatter (name, description, arguments)
2. Verify all 5 steps are implemented with clear instructions
3. Verify agent prompts are specific enough to produce useful output
4. Verify report template contains all required sections
5. Verify symlink resolves correctly
6. Review the skill against coding standards (under 400 lines, no hardcoded paths)

**Verify**: Human reviews skill file and confirms it's ready for use
**Done**: Skill approved for merge

## Verification

- [ ] SKILL.md exists at `skills/Documentation/incident-report/SKILL.md`
- [ ] Symlink exists at `skills/incident-report` pointing to group directory
- [ ] SKILL.md under 400 lines
- [ ] Frontmatter valid (name, description, arguments)
- [ ] All 5 steps implemented
- [ ] 3 parallel agents defined with clear prompts
- [ ] Report template has all required sections
- [ ] Backlog integration appends with cross-reference
- [ ] `incident-template.md` updated to match new standard
- [ ] No hardcoded paths

## Success Criteria

- `/incident-report` generates a complete incident report from conversation context
- Root cause analysis uses Five Whys method and produces actionable findings
- Prevention items appear in BACKLOG.md after command completes
- Report format matches standardized template across different incident types
- Existing incident template updated to match new standard
