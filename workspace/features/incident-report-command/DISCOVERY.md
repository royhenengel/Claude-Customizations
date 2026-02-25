# Incident Report Command Discovery

## Origin

**Source**: Backlog item "Incident Report command" (planning/BACKLOG.md, Docs & Knowledge Capture section)
**Date**: 2026-02-13

Four-word backlog item with no detail. The feature was shaped entirely through the discovery process below.

## Discovery Process

### Starting Point

The backlog contained only: "Incident Report command". No requirements, no scope, no constraints. The project already had 5 incident reports created ad-hoc across 3 features, plus an existing incident template (`incident-template.md`) that was simpler than the actual reports.

### Questions and Answers

#### Approach

**Question**: How should we approach planning the Incident Report command? Options: pick from backlog, explore the idea, or specify directly.
**Answer**: Pick from backlog.
**Effect**: Skipped open-ended clarification. Used existing incident reports as the primary input for understanding the pattern and gaps.

#### Automation Level

**Question**: Should the command only generate the document, perform guided Q&A, or do automated investigation with smart pre-fill?
**Answer**: Document + Analysis. The command should investigate the incident (read files, trace timeline, perform Five Whys) then generate the report.
**Effect**: Shifted from a template-filling command to an investigation-driven command. Required parallel analysis agents (following /compound pattern). Significantly increased the scope of the skill.

#### Backlog Integration

**Question**: Should the command automatically create backlog entries for prevention items?
**Answer**: Yes, auto-create.
**Effect**: Added a backlog-writing step to the skill. Prevention items must cross-reference the incident report in BACKLOG.md.

#### Build Integration

**Question**: Should this integrate with the /build workflow (auto-trigger on deviations)?
**Answer**: Standalone only.
**Effect**: Scoped the feature to manual invocation via `/incident-report`. No hooks, no /build integration. Keeps the first iteration simple.

#### Document Type Redefinition (Scope Expansion)

**Question**: (User-initiated) Why wasn't a DISCOVERY.md created? User then redefined the roles of DISCOVERY.md and RESEARCH.md.
**Answer**: DISCOVERY.md should capture the collaborative dialogue that shaped the feature. RESEARCH.md should contain raw data, analysis, and findings only.
**Effect**: Expanded scope beyond the incident-report command itself. Required updating documentation-types.md, both templates, the /plan workflow, and all feature documents. This redefinition applies to all future features, not just this one.

### Scope Evolution

| Stage | Scope | Change Reason |
| ----- | ----- | ------------- |
| Initial | "Incident Report command" (4 words) | Backlog item |
| After approach question | Standardized report generation from existing patterns | Chose "pick from backlog", analyzed 5 existing reports |
| After automation question | Investigation-driven command with 3 parallel agents | User chose "Document + Analysis" over template or guided Q&A |
| After backlog question | Auto-append prevention items to BACKLOG.md | User chose "Yes, auto-create" |
| After build question | Standalone command only (no /build hooks) | User chose "Standalone only" |
| After document type redefinition | Incident-report command + workflow-level DISCOVERY/RESEARCH redefinition | User redefined document type roles mid-planning |

## Decisions Made

| Decision | Choice | Alternatives Considered | Why This Choice |
| -------- | ------ | ----------------------- | --------------- |
| Command type | Investigation + generation | Template fill, guided Q&A, smart hybrid | User wanted automated analysis, not just formatting |
| Analysis pattern | 3 parallel agents (Timeline, Root Cause, Impact) | Single-pass, sequential analysis | Follows /compound pattern; domains are independent |
| Root cause method | Five Whys (mandatory) | Optional, free-form | Best results in existing reports (INCIDENT-001, subagent-bypass) |
| Severity levels | critical / major / minor | Free-text, 4+ levels | Covers the range without over-categorization |
| Storage location | `planning/specs/{feature}/` | Separate `planning/incidents/` | Keep with feature context |
| Naming | `INCIDENT-{YYYY-MM-DD}-{slug}.md` | Date-only, ID-based | Sortable by date, discoverable by topic |
| Backlog integration | Auto-append with cross-reference | Manual only, suggest only | User requested. Reduces friction |
| Build integration | None (standalone) | /build hook on deviations | User chose simplicity for first iteration |
| DISCOVERY vs RESEARCH | Split: process vs evidence | Combined in RESEARCH.md (previous) | User redefined document types |

## Approach (Original)

Create a `/incident-report` skill that follows the `/compound` pattern: detect context, run 3 parallel investigation agents (Timeline Reconstructor, Root Cause Analyzer, Impact Assessor), synthesize outputs into a standardized report, and auto-append prevention items to BACKLOG.md. The command is standalone (manual invocation only, no /build integration).

Additionally, redefine the DISCOVERY.md and RESEARCH.md document types across the entire workflow to separate collaborative decision-making (DISCOVERY) from raw research data (RESEARCH).

### Redefinition: Triage + Document, Not Duplicate /fix

**Question**: (User-initiated) How is this different from /fix? Both investigate, analyze root cause, search git history, and map affected areas.
**Answer**: Redefine /incident-report as a triage entry point. It specifies the problem (no code changes), investigates, generates a report, then decides: defer to backlog (with report as context) or continue to fix (handing off to /fix).
**Effect**: Complete spec rewrite. /incident-report is no longer an investigation-and-documentation command that overlaps with /fix. It becomes a triage workflow with two exit paths: defer (backlog + report) or fix now (delegates to /fix). The investigation steps intentionally reuse what /fix already does rather than duplicating them.

### No New Skill - Enhance /fix Instead

**Question**: (User-initiated) We're not creating another new skill. We're making adjustments to the existing fix skill.
**Answer**: Modify `/fix` SKILL.md directly. Insert report generation after Step 5 (Root Cause) and a defer/fix decision fork before Step 6 (Propose Fix). The defer path adds to backlog and exits. The fix path continues the existing flow unchanged.
**Effect**: Complete plan rewrite. Removed all tasks related to new skill creation (SKILL.md, symlink, Documentation group). Tasks now focus on understanding the existing /fix flow, designing the insertion point, and implementing the enhancement. Task 1 becomes a research step: walk through /fix step by step before modifying anything.

### Scope Evolution (Updated)

| Stage | Scope | Change Reason |
| ----- | ----- | ------------- |
| Initial | "Incident Report command" (4 words) | Backlog item |
| After approach question | Standardized report generation from existing patterns | Chose "pick from backlog", analyzed 5 existing reports |
| After automation question | Investigation-driven command with 3 parallel agents | User chose "Document + Analysis" over template or guided Q&A |
| After backlog question | Auto-append prevention items to BACKLOG.md | User chose "Yes, auto-create" |
| After build question | Standalone command only (no /build hooks) | User chose "Standalone only" |
| After document type redefinition | Incident-report command + workflow-level DISCOVERY/RESEARCH redefinition | User redefined document type roles mid-planning |
| After /fix comparison | Triage entry point with defer/fix decision fork | Spec overlapped heavily with /fix; redefined as triage + document + decide |

## Decisions Made (Updated)

| Decision | Choice | Alternatives Considered | Why This Choice |
| -------- | ------ | ----------------------- | --------------- |
| Command identity | Triage + document + decide | Investigation + generation (previous) | Original spec duplicated /fix investigation; new identity is triage |
| Decision fork | Defer (backlog + report) or fix now (hand off to /fix) | Always generate report only | Enables actionable outcomes, not just documentation |
| Fix delegation | Hand off to /fix when user chooses to fix | Built-in fix workflow | /fix already handles implementation, verification, PR; no duplication |
| Analysis pattern | 3 parallel agents (Timeline, Root Cause, Impact) | Single-pass, sequential analysis | Follows /compound pattern; domains are independent |
| Root cause method | Five Whys (mandatory) | Optional, free-form | Best results in existing reports (INCIDENT-001, subagent-bypass) |
| Severity levels | critical / major / minor | Free-text, 4+ levels | Covers the range without over-categorization |
| Storage location | `planning/specs/{feature}/` | Separate `planning/incidents/` | Keep with feature context |
| Naming | `INCIDENT-{YYYY-MM-DD}-{slug}.md` | Date-only, ID-based | Sortable by date, discoverable by topic |
| Backlog integration | Auto-append with cross-reference | Manual only, suggest only | User requested. Reduces friction |
| Build integration | None (standalone) | /build hook on deviations | User chose simplicity for first iteration |
| DISCOVERY vs RESEARCH | Split: process vs evidence | Combined in RESEARCH.md (previous) | User redefined document types |

## Approach (Updated)

Create a `/incident-report` skill that serves as a triage entry point for problems. The workflow: specify the problem (general statement, no code changes), investigate using parallel agents (following /compound pattern), generate a standardized incident report, then decide: defer the issue to BACKLOG.md with the report attached as context, or continue to fix it by handing off to /fix.

This replaces the previous approach of duplicating /fix's investigation and analysis capabilities.

## Open Items Deferred

- /build integration (auto-trigger on deviations): deferred to future iteration, tracked implicitly by the "Standalone only" decision
