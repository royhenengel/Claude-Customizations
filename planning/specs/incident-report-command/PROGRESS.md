# Incident Report Command State

**Stage**: planning
**Last Updated**: 2026-02-13

## Progress

- [ ] Task 1: Create SKILL.md with frontmatter and workflow skeleton
- [ ] Task 2: Implement Step 1: Context detection and feature identification
- [ ] Task 3: Implement Step 2: Parallel investigation agents
- [ ] Task 4: Implement Step 3: Report generation from agent outputs
- [ ] Task 5: Implement Step 4: Backlog integration (prevention items)
- [ ] Task 6: Implement Step 5: Confirmation and output
- [ ] Task 7: Update incident-template.md to match new standard
- [ ] Task 8: Create symlink for skill discovery
- [ ] Task 9: End-to-end verification

## Current State

**Last Updated**: 2026-02-13

### What's Working

(Nothing verified yet)

### What's Not Working

(No issues identified)

### Next Steps

1. Begin /build execution

### Open Questions

(None)

## Gap Stack

### Active Gap

(None)

### Gap History

(None this session)

## Decisions

- Parallel analysis agents (3): Timeline Reconstructor, Root Cause Analyzer, Impact Assessor
- Five Whys mandatory for all incidents
- Prevention items auto-appended to BACKLOG.md with cross-reference
- Standalone command only (no /build integration this iteration)
- Report stored in feature spec directory (not separate incidents directory)
- Naming: INCIDENT-{YYYY-MM-DD}-{slug}.md

## Notes

(None yet)
