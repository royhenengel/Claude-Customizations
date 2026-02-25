# Workflow: /plan

## Purpose

Plan work with spec-driven approach. Creates requirements and executable plans.

## When to Use

- After `/start` has initialized the project
- When you have a feature or task to plan
- When moving from "starting" to "planning" stage

## Entry Point

> **Timestamp Rule**: Whenever modifying STATE.md or PROGRESS.md in any step below, always update its `**Last Updated**` field to the current date.

User invokes `/plan` or asks to plan work.

## Steps

> **Timestamp Rule**: Whenever modifying STATE.md or PROGRESS.md in any step below, always update its `**Last Updated**` field to the current date.

### 1. Check Prerequisites and Active Features

```bash
ls workspace/STATE.md 2>/dev/null || echo "No STATE.md - run /start first"
ls workspace/CLAUDE.md 2>/dev/null || echo "No project context"
```

If no `workspace/` structure exists, suggest running `/start` first.

**Check context**:

```bash
# Detect if we're in a worktree or on main
if [ -f .git ]; then echo "WORKTREE"; else echo "MAIN"; fi
```

- If in a worktree: derive feature name from branch (`git branch --show-current`). Check if `workspace/features/{feature}/` already exists (if so, this feature is already planned - suggest `/build` instead).
- If on main: this is a worktree-first workflow. Planning should happen in a feature worktree for isolation.

  1. Verify `workspace/STATE.md` exists (if not, suggest `/start` first)
  2. Read the Feature Registry to show current project state
  3. Ask user what they want to plan (from backlog or new)
  4. Derive a kebab-case worktree name from their description
  5. Create worktree using `/git-worktrees`
  6. Instruct user to run `/plan` in the new VS Code window
  7. **STOP** - do not continue planning on main

  ```text
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  🔀 Creating feature workspace
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Planning requires an isolated workspace. Creating worktree...
  ```

  After worktree creation:

  ```text
  Worktree ready. Switch to the new VS Code window and run /plan there.
  ```

Continue to Step 2 (worktree context only).

### 2. Show Backlog and Understand What to Plan

First, check if there's an existing backlog:

```bash
cat workspace/BACKLOG.md 2>/dev/null || echo "No backlog yet"
```

**If BACKLOG.md has items**, show them first:

```text
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 Backlog
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Quick Wins:
- [ ] {item 1}
- [ ] {item 2}

Features:

  Ready to Plan:
  - [ ] {item 3}
  - [ ] {item 4} (depends: {other-feature})

  Drafted:
  - [ ] {item 5} - has SPEC.md, needs PLAN.md

  Ideas:
  - [ ] {item 6} - needs refinement

Technical Debt:
- [ ] {item 7}

What would you like to plan?

1. Pick from backlog (specify item)
2. Explore a new idea (let's clarify requirements first)
3. Add something specific (I know what I want)
4. Continue from existing spec

**Dependency notation**: Use `(depends: feature-name)` to indicate a feature that must complete first. Multiple dependencies: `(depends: feature-a, feature-b)`.

**Feature status in BACKLOG.md**:

- **Ready to Plan**: Has clear requirements, can create PLAN.md
- **Drafted**: Has SPEC.md but no PLAN.md yet
- **Ideas**: Needs refinement before planning

**If BACKLOG.md is empty or doesn't exist**:

```text
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 What to Plan
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Options:

1. Explore a new idea (let's clarify requirements first)
2. Add something specific (I know what I want)
3. Continue from existing spec

When picking from backlog, remove the item from BACKLOG.md after creating the spec.

### 3. Clarify Requirements (If Needed)

**If user chose "Explore a new idea"**: Run inline clarification process below.

**If user chose "Add something specific" or picked from backlog**: Skip to step 4.

#### Inline Clarification Process

Ask questions in THIS ORDER. One question per message. Prefer multiple choice.

**Question 1 - Purpose** (MUST ask first):
> "What problem does this solve? Who benefits from solving it?"

Wait for answer.

**Question 2 - Scope**:
> "What's explicitly in scope vs out of scope for this feature?"

Wait for answer.

**Question 3 - Constraints**:
> "Are there any constraints I should know about? (timeline, dependencies, technical limitations)"

Wait for answer.

**Question 4 - Success criteria**:
> "How will we know this is done? What does success look like?"

Wait for answer.

**Then propose 2-3 approaches** (conceptual, not technology choices):

```text
Based on what you've described, here are approaches:

**Option A: {Name}** (Recommended)
- How it works: ...
- Pros: ...
- Cons: ...
- Why I recommend it: ...

**Option B: {Name}**
- How it works: ...
- Pros: ...
- Cons: ...

Which approach resonates with you?
```

Once approach is chosen, continue to step 4 with clear requirements.

### 4. Create Feature Directory

```bash
mkdir -p workspace/features/{feature-name}
```

Use kebab-case for feature names (e.g., `user-authentication`, `api-integration`).

### 5. Create Feature CLAUDE.md (Cascading Context)

Create the feature-level context file that provides cascading context when working in this directory:

```markdown
# {Feature Name} Context

## Specification

@SPEC.md

## Discovery

@DISCOVERY.md

## Research

@RESEARCH.md

## Implementation Plan

@PLAN.md

## Status

Planning in progress.

## Feature Progress

@PROGRESS.md
```

Write to `workspace/features/{feature}/CLAUDE.md`.

This file will be automatically updated as the feature progresses (e.g., "Implementation in progress", "Complete - pending testing").

### 6. Create SPEC.md (If Not From Brainstorm)

If brainstorm was skipped, gather requirements directly:

```markdown
# {Feature Name} Specification

## Goal

{What this feature does and why}

## User Stories

- As a {user type}, I want {goal} so that {benefit}
- As a {user type}, I want {goal} so that {benefit}

## Requirements

### Functional

- [ ] {Requirement 1}
- [ ] {Requirement 2}
- [ ] [NEEDS CLARIFICATION: {unclear requirement - what specifically?}]

### Non-Functional

- [ ] {Performance, security, or other constraint}

## Constraints

- {Technical constraints}
- {Scope boundaries - what's NOT included}

## Success Criteria

- [ ] {Measurable outcome 1}
- [ ] {Measurable outcome 2}

## Open Questions

- [NEEDS CLARIFICATION: {Question that must be answered before implementation}]
```

Write to `workspace/features/{feature}/SPEC.md`.

**Validation before proceeding**: Ensure NO `[NEEDS CLARIFICATION]` markers remain. If any exist, resolve them with the user before creating PLAN.md.

### 7. Create DISCOVERY.md (Decision Record)

Record the collaborative discovery process that shaped the feature. This captures the back-and-forth between user and Claude: questions asked, answers given, choices made, and how scope evolved.

Use the template at `@skills/Planning/my-workflow/templates/discovery-template.md`

**Discovery guidance:**

- **Origin**: Where the feature came from (backlog, user request, incident)
- **Starting Point**: What was known at the start
- **Questions and Answers**: Chronological record of dialogue that shaped the feature. Each entry: question asked, answer given, effect on scope/direction
- **Scope Evolution**: How scope changed through the process
- **Decisions Made**: Table of choices with alternatives considered and rationale
- **Approach**: Synthesized summary of what we're building and why

Write to `workspace/features/{feature}/DISCOVERY.md`.

### 8. Create RESEARCH.md (Data & Analysis)

Document the raw research data, analysis, and findings that informed decisions. This is the evidence file, not the decision log (decisions live in DISCOVERY.md).

Use the template at `@skills/Planning/my-workflow/templates/research-template.md`

**Research guidance:**

- **Problem Analysis**: Deep-dive into the problem space and current state
- **Codebase Analysis**: Discover existing patterns, conventions, and constraints
- **External Research**: Survey the ecosystem, compare options, deep-dive selected approach
- **External Inspirations**: Review sources, extract patterns and insights to apply
- **Architectural Implications**: Map system boundaries, dependencies, integration points
- **Risks**: Technical and process risks with mitigation strategies

Write to `workspace/features/{feature}/RESEARCH.md`.

### 9. Create PLAN.md (Detailed Documentation)

Create a comprehensive implementation plan with as many tasks as needed for clarity.

```markdown
# {Feature Name} Implementation Plan

## Objective

{What and why - copied from spec}

## Context

@workspace/features/{feature}/SPEC.md
@workspace/features/{feature}/RESEARCH.md
{@other relevant files}

## Task Summary

**Task ordering**: Follow TDD (Red-Green pattern). For each behavior:
1. Write failing test first
2. Implement minimal code to pass test
3. Repeat for next behavior

| # | Task | Type | Dependencies | Blocking |
|---|------|------|--------------|----------|
| 1 | Set up module structure | auto | - | - |
| 2 | Write test for {behavior 1} | auto | Task 1 | - |
| 3 | Implement {behavior 1} | auto | Task 2 | - |
| 4 | Write test for {behavior 2} | auto | Task 3 | - |
| 5 | Implement {behavior 2} | auto | Task 4 | - |
| 6 | {checkpoint if needed} | checkpoint:decision | Task 5 | yes |

## Tasks

### Task 1: {Description}

**Type**: auto
**Files**: {exact paths to create/modify}
**Dependencies**: None

**Context**: {Why this task exists, what problem it solves}

**Action**:
{Detailed implementation steps:
- Technology choices and why
- Edge cases to handle
- Pitfalls to avoid
- Code patterns to follow from existing codebase}

**Verify**: {Executable command or test}
**Done**: {Measurable acceptance criteria}

---

### Task 2: {Description}

**Type**: checkpoint:human-verify
**Blocking**: yes
**Files**: {exact paths}
**Dependencies**: Task 1

**Context**: {Why human verification is needed}

**Action**: {What to do}
**Verify**: {Manual verification steps for human}
**Done**: {Human confirms completion}

---

### Task 3: {Description}

**Type**: checkpoint:decision
**Blocking**: yes
**Dependencies**: Tasks 1-2

**Question**: {Decision that needs to be made}
**Options**:
| Option | Pros | Cons |
|--------|------|------|
| A: {name} | {pros} | {cons} |
| B: {name} | {pros} | {cons} |
**Default**: {recommended option and why}
**Action**: {What to do after decision}
**Done**: {Decision recorded, action taken}

## Verification

- [ ] {Overall verification 1}
- [ ] {Overall verification 2}

## Success Criteria

{Measurable outcomes from spec}
```

**Task Types**:

| Type | Description | Blocking |
|------|-------------|----------|
| `auto` | Claude executes autonomously | No |
| `checkpoint:human-verify` | Requires human to verify before continuing | Configurable |
| `checkpoint:decision` | Requires human decision with options | Configurable |
| `checkpoint:human-action` | Requires human to perform action (e.g., deploy, test manually) | Yes |

Write to `workspace/features/{feature}/PLAN.md`.

### 8a. Create Feature PROGRESS.md

Create feature-level state file using the feature state template:

@skills/Planning/my-workflow/templates/feature-progress-template.md

Customize the template:

- Set `**Stage**` to `planning`
- Set `**Last Updated**` to today's date
- Copy the task list from PLAN.md Task Summary into `## Progress` section (all unchecked)
- Set Next Steps to "Begin /build execution"

Write to `workspace/features/{feature}/PROGRESS.md`.

### 10. Update STATE.md and Feature CLAUDE.md

Update `workspace/STATE.md` Feature Registry -- add row for new feature:

```markdown
| {feature-name} | feature | ready | {branch-name} | {worktree-path} |
```

Do NOT update project STATE.md with Stage, Active Feature, Current Focus, Progress, or Current State sections. Those live in the feature PROGRESS.md now.

**Feature Registry updates**:

- Add new feature row with status `ready`
- If feature has dependencies, note them in the row
- Remove from BACKLOG.md if it was picked from there

Record decisions made during planning in the feature PROGRESS.md (`workspace/features/{feature}/PROGRESS.md`):

```markdown
## Decisions

- {approach chosen and rationale}
```

Update `workspace/features/{feature}/CLAUDE.md` status:

```markdown
## Status

Planning complete. Ready for /build.
```

### 11. Transition to Building

After plan is created:

```text
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Plan Complete
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Created:

- [workspace/features/{feature}/SPEC.md](workspace/features/{feature}/SPEC.md) (requirements)
- [workspace/features/{feature}/DISCOVERY.md](workspace/features/{feature}/DISCOVERY.md) (decision record)
- [workspace/features/{feature}/RESEARCH.md](workspace/features/{feature}/RESEARCH.md) (data & analysis)
- [workspace/features/{feature}/PLAN.md](workspace/features/{feature}/PLAN.md) (executable plan with {N} tasks)
- [workspace/features/{feature}/PROGRESS.md](workspace/features/{feature}/PROGRESS.md) (feature state)

Ready to build? Run `/build` to execute the plan.

## Output Structure

```text
workspace/
├── OVERVIEW.md
├── CLAUDE.md
├── STATE.md              # Project state (Feature Registry only)
├── BACKLOG.md            # Persistent improvements backlog
└── features/
    └── {feature}/
        ├── CLAUDE.md     # Feature context (cascading)
        ├── SPEC.md       # Requirements
        ├── DISCOVERY.md  # Decision record (collaborative dialogue)
        ├── RESEARCH.md   # Data & analysis (evidence)
        ├── PLAN.md       # Executable plan
        └── PROGRESS.md   # Feature progress (progress, current state)
```

## Plan Principles

### TDD Task Ordering

Follow the Red-Green-Refactor cycle from the software-development-practices skill:

1. **RED** - Write failing test for one behavior
2. **Verify RED** - Run test, confirm it fails for the right reason
3. **GREEN** - Write minimal code to pass
4. **Verify GREEN** - Run test, confirm it passes
5. **REFACTOR** - Clean up while staying green
6. **Repeat** - Next behavior

Tasks should be structured per-behavior, not batched:

```text
Task 1: Set up module structure
Task 2: Write test for user creation (RED)
Task 3: Implement user creation to pass test (GREEN)
Task 4: Write test for user validation (RED)
Task 5: Implement user validation to pass test (GREEN)
Task 6: Refactor and verify all tests pass
```

Key: Each test must be seen failing before implementation. A test that passes immediately proves nothing.

### Comprehensive Documentation (GSD/CEK Style)

Document everything needed for implementation. PLAN.md should contain enough detail that any developer (or Claude session) can execute it without ambiguity.

Contains:

- Objective (what and why)
- Context (@file references)
- Task Summary (overview table with dependencies)
- Tasks with full context (why, how, edge cases, pitfalls)
- Verification (overall checks)
- Success criteria (measurable)

### Task Detail Level

Each task should include:

- **Context**: Why this task exists
- **Action**: Detailed steps including technology choices, edge cases, pitfalls
- **Files**: Exact paths to create/modify
- **Dependencies**: Which tasks must complete first
- **Verify**: Executable command or test
- **Done**: Measurable acceptance criteria

### Task Types

| Type | When to Use | Blocking |
|------|-------------|----------|
| `auto` | Claude can complete without human input | No |
| `checkpoint:human-verify` | Human needs to review/approve output | Configurable |
| `checkpoint:decision` | Human must choose between options | Configurable |
| `checkpoint:human-action` | Human must do something (deploy, test, etc.) | Always |

### Checkpoints

- **Blocking**: Execution stops until human responds
- **Non-blocking**: Logged for review, execution continues
- **Decision gates**: Present options with pros/cons, wait for choice

### Context Health Awareness

Quality degrades at ~40-50% context, not 80%.

For large features, use numbered plan files:

- `{feature}/01-PLAN.md` - First phase
- `{feature}/02-PLAN.md` - Second phase

Current State in feature PROGRESS.md is maintained continuously between phases.

### Optional Artifacts

For complex features, create additional documentation:

| Artifact | When to Create | Purpose |
|----------|----------------|---------|
| `data-model.md` | Features with entities/relationships | Document schema, validation rules |
| `contract.md` | Features with APIs | Document endpoints, request/response |
| `design-options.md` | Major architectural decisions | Compare 2-3 approaches with trade-offs |

### YAGNI Ruthlessly

Remove unnecessary features. If it's not in the spec, it's not in the plan.

## Integration Flow

```text
/plan invoked
    |
    v
Check prerequisites (workspace/ exists?)
    |
    v
"What to plan?"
    |
    +-- "Explore a new idea" --> Inline clarification (Purpose→Scope→Constraints→Success→Approaches)
    |                                   |
    +-- "Pick from backlog" -----------+
    |                                   |
    +-- "Add something specific" ------+
    |                                   |
    +-- "Continue from existing" ------+
    |
    v
Create feature directory + CLAUDE.md (cascading context)
    |
    v
Create SPEC.md (requirements)
    |
    v
Create DISCOVERY.md (decision record)
    |
    v
Create RESEARCH.md (data & analysis)
    |
    v
Create PLAN.md (detailed tasks)
    |
    v
Create feature PROGRESS.md (progress, current state)
    |
    v
Update project STATE.md registry + feature CLAUDE.md
    |
    v
"Ready to /build?"
```
