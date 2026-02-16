# Documentation Types Reference

Governing reference for document types in repos using my-workflow. Defines every document type, where it belongs, and how types relate to each other. The enforcement agent and documentation tooling read this file as the source of truth.

This reference covers the **portable my-workflow structure** (planning, docs, project management). For repo-specific structure (skills/, agents/, hooks/, etc.), see that repo's CLAUDE.md and README.md.

## Canonical Directory Structure

```
repo-root/
├── CLAUDE.md                          # Project Context (auto-loaded, operational)
├── README.md                          # Project Intro (human-facing)
│
├── docs/                              # Standalone guides and references
│   └── {guide-name}.md                # Guide (no better home)
│
├── planning/                          # Project management
│   ├── CLAUDE.md                      # Planning Context (auto-loaded, navigation)
│   ├── OVERVIEW.md                    # Project Vision (authoritative governance)
│   ├── STATE.md                       # Project State (living tracker)
│   ├── BACKLOG.md                     # Project Backlog (persistent)
│   ├── solutions/                     # Solved problems (/compound)
│   │   ├── INDEX.md                   # Solutions index
│   │   └── {category}/               # Problem categories
│   │       └── {solution}.md          # Individual solution
│   └── specs/                         # Feature specifications
│       └── {feature}/                 # One directory per feature
│           ├── CLAUDE.md              # Feature Context (auto-loaded)
│           ├── SPEC.md                # Feature Spec (requirements)
│           ├── DISCOVERY.md           # Feature Discovery (collaborative decision record)
│           ├── RESEARCH.md            # Feature Research (data, analysis, findings)
│           ├── PLAN.md                # Feature Plan (executable tasks)
│           ├── PROGRESS.md            # Feature Progress (live tracking during work)
│           ├── SUMMARY.md             # Feature Summary (outcomes, post-completion)
│           ├── INCIDENT-{date}.md     # Incident Report (optional, post-incident)
│           └── archive/               # Archived artifacts (post-completion)
│
└── archive/                           # Archived content
```

## Document Type Registry

| Type | Filename | Location | Purpose | Template? |
|------|----------|----------|---------|-----------|
| Project Context | CLAUDE.md | repo root | Operational instructions for Claude (auto-loaded) | Yes |
| Directory Context | CLAUDE.md | any directory | Cascading context for that directory (auto-loaded) | Yes |
| Project Intro | README.md | repo root | Human-facing project overview | Yes |
| Project Vision | OVERVIEW.md | planning/ | Vision, scope, principles, governance | Yes |
| Project State | STATE.md | planning/ | Current stage, active features, decisions | Yes |
| Project Backlog | BACKLOG.md | planning/ | Improvements, ideas, technical debt | Yes |
| Feature Spec | SPEC.md | planning/specs/{feature}/ | Requirements for a feature | Yes |
| Feature Discovery | DISCOVERY.md | planning/specs/{feature}/ | Collaborative decision record from user-Claude dialogue | Yes |
| Feature Research | RESEARCH.md | planning/specs/{feature}/ | Data, analysis, and findings that inform decisions | Yes |
| Feature Plan | PLAN.md | planning/specs/{feature}/ | Executable implementation tasks | Yes |
| Feature Progress | PROGRESS.md | planning/specs/{feature}/ | Live tracking of progress, current state, gap stack | Yes |
| Feature Summary | SUMMARY.md | planning/specs/{feature}/ | Outcomes after feature completion | Yes |
| Feature Context | CLAUDE.md | planning/specs/{feature}/ | Cascading context for feature (auto-loaded) | Yes |
| Incident Report | INCIDENT-{YYYY-MM-DD}-{slug}.md | planning/incidents/ | Post-incident documentation | Yes |
| Guide | {name}.md | docs/ | Standalone guides with no better home | No |
| Solution | {category}/{name}.md | planning/solutions/ | Solved problem documentation | Yes |

## Placement Rules

Decision tree for where a new document goes:

1. Is it auto-loaded context for a directory? -> **CLAUDE.md** in that directory
2. Is it a feature artifact (spec, plan, research, progress, summary, discovery)? -> **planning/specs/{feature}/**
3. Is it project management (state, backlog, governance)? -> **planning/**
4. Is it a solved problem to reference later? -> **planning/solutions/**
5. Is it a standalone guide that doesn't fit elsewhere? -> **docs/**
6. Is it human-facing documentation for a directory? -> **README.md** in that directory

## Role Separation for Root Files

- **CLAUDE.md**: Operational instructions (structure, behavioral rules, doc architecture summary). Auto-loaded, token-sensitive. Keep concise.
- **README.md**: Human introduction (what this repo is, how to use it, getting started). Not auto-loaded. Can be longer.
- **OVERVIEW.md**: Authoritative governance (vision, principles, scope, versioning). Referenced, not duplicated.

## Content Rules

- No content should exist in two places. Link, don't duplicate.
- CLAUDE.md files must contain useful context (not just placeholder or auto-generated content).
- Completed feature specs archive to CLAUDE.md + SUMMARY.md (PLAN/RESEARCH/SPEC go to archive/).
- Stale content (counts, dates, references) must be verifiable against the source of truth.
- Every directory with a CLAUDE.md should have content describing that directory's purpose and key files.

## DISCOVERY.md vs RESEARCH.md

These are complementary documents, both created during /plan.

- **DISCOVERY.md**: Records the collaborative discovery process between user and Claude. Contains the back-and-forth that shaped the feature: questions asked, answers given, choices made, how scope evolved, and why decisions landed where they did. Think of it as the decision log from the planning conversation.

- **RESEARCH.md**: Contains the raw data, analysis, and findings that informed those decisions. Codebase patterns discovered, existing code analyzed, external research gathered, option comparisons, technical constraints identified. Think of it as the evidence file.

**DISCOVERY captures the process** (how we got here). **RESEARCH captures the evidence** (what we found).

A feature always has both. DISCOVERY.md is created first (or alongside) RESEARCH.md during /plan, not deferred to execution.
