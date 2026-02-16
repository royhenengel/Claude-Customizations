# Incident Report - /fix Enhancement Specification

## Goal

Enhance the existing `/fix` skill with incident report capabilities. When a problem is reported, /fix investigates, generates a standardized incident report, then presents a decision: defer the issue to the backlog (with the report as context) or continue through the existing fix workflow. No new skill is created.

## User Stories

- As a developer, I want to run `/fix` when something goes wrong so that the problem is investigated and documented before deciding what to do about it

- As a developer, I want the investigation to produce a standardized incident report so that problems are consistently documented regardless of whether I fix them now or defer

- As a developer, I want to choose between deferring the issue (backlog + report) or fixing it now so that I make informed triage decisions

## Requirements

### Functional

- [ ] /fix enhanced with incident report generation during investigation phase
- [ ] After investigation (Steps 2-5), generates standardized incident report document
- [ ] Stores report in `planning/incidents/INCIDENT-{YYYY-MM-DD}-{slug}.md` (always, regardless of worktree context)
- [ ] Presents decision fork after report: defer or fix now
- [ ] Defer path: appends issue to `planning/BACKLOG.md` with incident report cross-reference. Done.
- [ ] Fix path: continues through existing /fix Steps 6-10
- [ ] Supports three severity levels: critical, major, minor
- [ ] Uses parallel analysis agents for investigation (following /compound pattern)

### Non-Functional

- [ ] Report format consistent across all incidents (standardized template)
- [ ] /fix skill file stays under 400 lines (per coding standards)
- [ ] No hardcoded paths
- [ ] Works in both worktree and main branch contexts

## Approach

Modify the existing `/fix` skill (`skills/Code-Quality/fix/SKILL.md`) to integrate incident reporting into its investigation flow. The current Steps 1-5 (understand, git history, conventions, affected areas, root cause) already gather the data needed for an incident report. After Step 5, generate the report and present the defer/fix decision fork. The existing Steps 6-10 remain unchanged for the "fix now" path.

## Workflow Change

Current /fix flow:

```text
Step 1: Understand → Step 1a: Worktree → Step 2: Git History → Step 3: Conventions →
Step 4: Map Areas → Step 5: Root Cause → Step 6: Propose Fix (STOP) →
Step 7: Implement → Step 8: Regression → Step 9: Convention/Compound →
Step 9b: Quality Review → Step 10: Finalize
```

Enhanced flow:

```text
Step 1: Understand → Step 1a: Worktree → Step 2: Git History → Step 3: Conventions →
Step 4: Map Areas → Step 5: Root Cause → [NEW: Generate Report + Decide] →
  → Defer: Backlog + report. Done.
  → Fix now: Step 6: Propose Fix (STOP) → Step 7-10: (unchanged)
```

## Report Structure

| Section | Purpose | Source |
| ------- | ------- | ------ |
| Frontmatter (Date, Feature, Severity, Status) | Metadata | Auto-detected + user input |
| Summary | What happened in 2-3 sentences | Synthesized from Steps 2-5 |
| What Happened | Factual timeline of events | Step 2 git history + conversation |
| Root Cause | Five Whys analysis | Step 5 root cause analysis |
| Impact | What was affected and how | Step 4 affected areas |
| Affected Artifacts | Table of files/components impacted | Step 4 mapping |
| Resolution | What was done or should be done | Depends on defer/fix decision |
| Prevention | Actionable items to prevent recurrence | Step 5 root cause output |
| Lessons Learned | Systemic insights | Synthesis of all steps |

## Constraints

- Modifies existing /fix skill only. No new skill created.
- Existing /fix behavior preserved. The defer path is additive.
- Report stored in `planning/incidents/`, independent of feature spec directories
- Defer path: items must cross-reference the incident report in BACKLOG.md

## Success Criteria

- [ ] /fix generates an incident report after investigation phase
- [ ] Root cause analysis uses Five Whys method and produces actionable findings
- [ ] Defer path: issue appears in BACKLOG.md with report cross-reference
- [ ] Fix path: continues through existing /fix Steps 6-10 unchanged
- [ ] Report format matches standardized template across different incident types

## Open Questions

None. All scope questions resolved during planning.
