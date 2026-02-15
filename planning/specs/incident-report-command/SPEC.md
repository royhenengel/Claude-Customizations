# Incident Report Command Specification

## Goal

Create a `/incident-report` slash command that investigates incidents, performs root cause analysis, and generates standardized incident reports. The command replaces ad-hoc incident documentation with an automated, analysis-driven workflow that produces consistent reports and creates prevention-oriented backlog entries.

## User Stories

- As a developer, I want to run `/incident-report` after something goes wrong so that the incident is thoroughly documented with root cause analysis, not just a summary

- As a developer, I want the command to investigate the incident automatically (read files, trace timelines, analyze git history) so that the report contains evidence, not guesses

- As a developer, I want prevention items automatically added to BACKLOG.md so that systemic fixes are tracked and not forgotten

## Requirements

### Functional

- [ ] Skill invocable via `/incident-report` with optional context argument
- [ ] Auto-detects incident context from conversation history when no argument provided
- [ ] Investigates incident by reading relevant files, git history, and conversation context
- [ ] Performs structured root cause analysis (Five Whys method)
- [ ] Generates standardized incident report document
- [ ] Stores report in feature spec directory: `planning/specs/{feature}/INCIDENT-{name}.md`
- [ ] Appends prevention items to `planning/BACKLOG.md` with incident cross-reference
- [ ] Supports three severity levels: critical, major, minor
- [ ] Uses parallel analysis agents for investigation (following /compound pattern)

### Non-Functional

- [ ] Report format consistent across all incidents (standardized template)
- [ ] Skill file under 400 lines (per coding standards)
- [ ] No hardcoded paths
- [ ] Works in both worktree and main branch contexts

## Report Structure

The generated report must include these sections (derived from analysis of 5 existing reports):

| Section | Purpose | Source |
|---------|---------|--------|
| Frontmatter (Date, Feature, Severity, Status) | Metadata | Auto-detected + user input |
| Summary | What happened in 2-3 sentences | Auto-generated from investigation |
| What Happened | Factual timeline of events | Conversation + git history |
| Root Cause | Five Whys analysis | Automated analysis agents |
| Impact | What was affected and how | File analysis + git diff |
| Affected Artifacts | Table of files/components impacted | Git diff + file tracing |
| Resolution | What was done or should be done | Conversation context |
| Prevention | Actionable items to prevent recurrence | Root cause analysis output |
| Lessons Learned | Systemic insights | Synthesis of all analysis |

## Constraints

- Standalone command only (no /build integration in this iteration)
- Must follow existing skill patterns (frontmatter, step-based workflow)
- Report stored alongside feature specs, not in a separate directory
- Prevention items must cross-reference the incident report in BACKLOG.md

## Success Criteria

- [ ] `/incident-report` generates a complete incident report from conversation context
- [ ] Root cause analysis uses Five Whys method and produces actionable findings
- [ ] Prevention items appear in BACKLOG.md after command completes
- [ ] Report format matches standardized template across different incident types
- [ ] Existing incident template (`incident-template.md`) updated to match new standard

## Open Questions

None. All scope questions resolved during planning.
