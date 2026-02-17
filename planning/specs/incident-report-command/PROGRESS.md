# Incident Report - /fix Enhancement State

**Stage**: complete
**Last Updated**: 2026-02-16

## Progress

- [x] Task 1: Walk through existing /fix flow step by step
- [x] Task 2: Design insertion point and report generation step
- [x] Task 3: Design decision fork (defer or fix now)
- [x] Task 4: Implement report generation step in /fix SKILL.md
- [x] Task 5: Implement decision fork in /fix SKILL.md
- [x] Task 6: Implement defer path (backlog + cross-reference)
- [x] Task 7: Update incident-template.md to match report format
- [x] Task 8: End-to-end verification

## Current State

**Last Updated**: 2026-02-16

### What's Working

- All 8 tasks complete. PR #12 merged (squash merge) to main.
- /fix SKILL.md enhanced with incident report generation (Step 5a), triage decision fork (Step 5b), defer path
- incident-template.md updated to match report format
- SKILL.md at 358 lines (under 400-line limit)
- Review agents and doc-enforcer passed

### What's Not Working

(No issues)

### Next Steps

(Feature complete)

### Open Questions

1. ~~Where does the incident report file go when the fix is unrelated to the current worktree's feature?~~ → Resolved: always `planning/incidents/`
2. ~~Step 1a needs "Is this related to what you're working on now?" as first option in any worktree context~~ → Resolved: restructured Step 1a to ask "related?" first in all worktree contexts
3. ~~Step 9: backlog append should require user approval, not auto-append~~ → Resolved: Step 9 now proposes entry for approval. Defer path (Step 5b) doesn't need approval (user intent is clear).
4. ~~Step 9 vs incident report Prevention overlap~~ → Resolved: added note in Step 9 distinguishing convention/process gaps from technical prevention items
5. ~~Step 9b ordering wrong~~ → Resolved: Step 10 updated (review agents first, doc-enforcer last)
6. ~~Step 10 main branch handling~~ → Resolved: main redirects to worktree creation in Step 1a. Step 10 simplified (all fixes run in worktrees).
7. ~~Line 410 typo: "Step 9a" should be "Step 9b"~~ → Resolved: fixed

## Gap Stack

### Active Gap

(None)

### Gap History

(None this session)

## Decisions

- No new skill. Enhance existing /fix skill.
- Insert report generation after Step 5 (Root Cause), before Step 6 (Propose Fix)
- Decision fork: defer (backlog + report, exit) or fix now (continue to Step 6)
- Report uses data already gathered in /fix Steps 2-5 (no duplication)
- Five Whys mandatory for root cause analysis
- Defer path: auto-appends to BACKLOG.md with cross-reference
- Report stored in `planning/incidents/INCIDENT-{YYYY-MM-DD}-{slug}.md` (always, regardless of worktree context)
- /fix uses feature-progress-template as base, adds `**Type**: fix` + fix-specific sections (Issue, Root Cause, Proposed Fix)
- Simplify /fix Scenario A/B detection: if `**Type**: fix` → Scenario A, else → Scenario B
- Defer/fix decision is universal across all worktree types (not just feature worktrees)
- Modify Step 5 to use Five Whys format directly (replaces causal chain format for all /fix invocations)
- Fix now path: update incident report Resolution section after implementation (actual fix, PR link, verification results)
- Direct synthesis for report generation (no parallel agents). Data already in conversation context from Steps 1-5.
- Only Step 5 needs format modification (Five Whys). Steps 1-4 produce usable data as-is.
- Severity prompted after Step 5 (root cause known), before report generation
- SPEC line 22 needs update: storage path changed from `planning/specs/{feature}/` to `planning/incidents/`
- Decision fork (Step 5b): two options presented after report generation. Fix now → Step 6. Defer → backlog + exit.
- Defer path does NOT require approval (user choosing "defer" is the intent). Fix now path Step 9 requires approval for backlog appends.
- Defer path updates report status to "deferred" and Resolution to backlog reference
- Fix now path: two sequential STOP points preserved (5b triage + Step 6 implementation approval)
- Scenario B-unrelated never reaches decision fork (redirected in Step 1a)
- Step 1a restructured: "Is this related?" asked first in ALL worktree contexts (fix and feature), not just feature worktrees
- Main branch redirects to worktree creation (worktree-first pattern). No branch creation on main.
- Step 9 convention items noted as distinct from incident report Prevention (convention/process gaps vs technical prevention)
- Step 10 simplified: removed "create branch on main" path, all fixes assumed to be in worktrees

## Notes

- 2026-02-15: Spec redefined twice. First from standalone command to triage entry point (after /fix comparison). Then from new skill to /fix enhancement (user decision to modify existing skill instead of creating new one).
