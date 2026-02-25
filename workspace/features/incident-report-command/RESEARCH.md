# Incident Report Command Research

## Problem Analysis

### Problem Domain

Incident reports in this project are created ad-hoc. No automation, no enforced format, no standard sections. When something goes wrong (process violations, technical bugs, configuration errors), the developer writes a report from scratch, decides what sections to include, performs analysis manually, and may or may not add prevention items to the backlog.

### Current State

5 existing incident reports across 3 features. An incident template exists but is unused or underused.

## Information Gathered

### Existing Incident Reports

| Report | Feature | Severity | Date |
|--------|---------|----------|------|
| INCIDENT-001-cek-bias.md | audit-agents | High | 2026-02-05 |
| INCIDENT-2026-02-05.md | auto-trigger-fix | Medium | 2026-02-05 |
| INCIDENT-2026-02-06-skill-discovery.md | commands-skills-migration | High | 2026-02-06 |
| INCIDENT-2026-02-06.md | commands-skills-migration | Medium | 2026-02-06 |
| INCIDENT-subagent-bypass.md | multi-feature-state | Process Violation | 2026-02-11 |

### Section Frequency Analysis

| Section | Present In | In Template? |
|---------|-----------|-------------|
| Date/Severity/Status frontmatter | 5/5 | Yes |
| Summary/What Happened | 5/5 | Yes |
| Root Cause (some use Five Whys) | 5/5 | Yes |
| Impact assessment | 4/5 | Yes |
| Timeline | 3/5 | Yes |
| Affected files/artifacts table | 4/5 | No |
| Remediation options (A/B/C) | 2/5 | No |
| Lessons learned | 5/5 | Yes |
| Prevention items | 3/5 | Yes |
| Backlog cross-reference | 3/5 | No |

### Format Inconsistencies

- **Severity levels**: "High", "Medium", "Process Violation" (no standard scale)
- **Section ordering**: Varies across reports
- **Root cause depth**: Some use Five Whys (INCIDENT-001, subagent-bypass), others use direct analysis
- **Naming**: Mix of date-based, ID-based, and descriptive names
- **Prevention tracking**: Some reference backlog, some don't

### Root Cause Method Comparison

| Method | Used In | Quality of Output |
|--------|---------|-------------------|
| Five Whys | INCIDENT-001-cek-bias, INCIDENT-subagent-bypass | Most actionable. Produced clear causal chains and specific fixes |
| Direct analysis | INCIDENT-2026-02-05, INCIDENT-2026-02-06 | Adequate but less structured. Root causes identified but chain less clear |
| Timeline + narrative | INCIDENT-2026-02-06-skill-discovery | Good for simple incidents. Less useful for complex process failures |

### Codebase Analysis

#### Closest Analog: /compound Skill

The `/compound` skill (`skills/Learning/compound/SKILL.md`) is the closest pattern match:

- Uses 3 parallel agents (Problem Extractor, Solution Extractor, Category Classifier)
- Auto-detects context from conversation when no argument provided
- Generates structured document from template
- Stores in `planning/solutions/{category}/`
- Updates INDEX.md

#### Skill Structure Patterns

From analysis of /compound, /commit, /fix, /handoff:

- SKILL.md with YAML frontmatter (name, description, arguments, allowed-tools)
- Step-based workflow (Step 1, Step 2, etc.)
- Parallel agent invocation for analysis
- Template-based document generation
- Storage in planning directory structure

#### Existing Template

`skills/Planning/my-workflow/templates/incident-template.md` has 7 sections:
- Frontmatter (Date, Feature, Severity)
- What Happened
- Root Cause
- Impact
- Resolution
- Timeline
- Prevention
- Lessons Learned

Missing compared to actual reports: Affected Artifacts table, Remediation Options, Evidence, Backlog cross-reference.

#### Internal-Comms Skill

`skills/Communications/internal-comms/SKILL.md` covers workplace incident reports. Different purpose (professional communications for company audiences), not relevant to this feature.

### Existing Infrastructure

| Component | Location | Status |
|-----------|----------|--------|
| Feature spec directories | `planning/specs/{feature}/` | Established pattern |
| Backlog | `planning/BACKLOG.md` | Exists, actively maintained |
| Incident template | `skills/Planning/my-workflow/templates/incident-template.md` | Exists, needs updating |
| Git history | Repository | Available for timeline reconstruction |
| Symlink discovery pattern | `skills/{name}` -> `skills/{Group}/{name}` | Required for slash command visibility |

## Architectural Implications

### System Boundaries

The skill reads from:
- Conversation context (automatic)
- Git history (`git log`, `git diff`)
- Feature files (`planning/specs/{feature}/`)

It writes to:
- `planning/specs/{feature}/INCIDENT-{date}-{slug}.md` (new report)
- `planning/BACKLOG.md` (append prevention items)
- `skills/Planning/my-workflow/templates/incident-template.md` (update existing template)

### Dependencies

- Existing `planning/specs/{feature}/` directory structure
- `planning/BACKLOG.md` must exist
- Git repository with history

### Integration Points

- **Backlog**: Prevention items cross-reference the incident report
- **Template**: Updates the existing `incident-template.md` to match the new standard

### Risks

- **Agent quality**: Root cause analysis depends on agents having enough context. Mitigation: provide agents with conversation history, git diff, and relevant file contents

- **Over-analysis**: Simple incidents might not need Five Whys. Mitigation: allow agents to produce shorter analysis when root cause is obvious

- **Backlog clutter**: Auto-creating backlog entries for every incident. Mitigation: user reviews prevention items before they're added

## Sources

| Source | Type | Insight |
|--------|------|---------|
| INCIDENT-001-cek-bias.md | Existing report | Most structured report. Five Whys produced actionable findings |
| INCIDENT-subagent-bypass.md | Existing report | Five Whys with detailed timeline. Best example of process violation analysis |
| /compound SKILL.md | Existing skill | Parallel agent pattern for investigation + document generation |
| incident-template.md | Existing template | Baseline structure, needs expansion |
| documentation-types.md | Workflow docs | Defines incident report as optional feature artifact |
