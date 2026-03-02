# Claude Customizations

Personal Claude Code customizations. This repo is symlinked to `~/.claude/` for automatic availability.

## Structure

- `skills/` - Skill definitions organized in functional groups (auto-activate based on context, invoke via `/skill-name`)
- `agents/` - 133 subagent definitions (specialized workers via Task tool)
- `hooks/` - Event-driven behaviors
- `mcp/` - MCP server configurations
- `rules/` - Behavioral rules, standards, and preferences (auto-loaded every session via `~/.claude/rules/`)
- `workspace/` - Project planning, state, features, docs (typed subdirs), and archive
- `scripts/` - Utility scripts

## Development Workflow

**Adding Skills**: Create `skills/{Group}/{name}/SKILL.md` with frontmatter (name + description). Place in the appropriate functional group directory.

**Adding Agents**: Create `agents/{name}.md` with frontmatter including model/description.

**Adding Rules**: Create `rules/{name}.md`. Auto-loaded globally via Anthropic's native `~/.claude/rules/` mechanism.

## Claude Flow

Claude Flow is an independent MCP server for multi-agent swarm orchestration. It is separate from the my-workflow system. Use ToolSearch for "claude-flow" to access its tools. Do not mix Claude Flow agents with the `agents/` directory.

## Workspace

- [workspace/OVERVIEW.md](workspace/OVERVIEW.md) - Project vision, scope, and governance
- [workspace/STATE.md](workspace/STATE.md) - Current project state and progress
- [workspace/BACKLOG.md](workspace/BACKLOG.md) - Improvements and technical debt

## Key References

- Core principles and quality standards: `rules/core-principles.md`
- Behavioral rules (uncertainty protocol, verification, validation): `rules/behavioral-rules.md`
- Technical consistency and tool selection: `rules/technical-consistency.md`
- Documentation type system: `skills/Planning/my-workflow/docs/documentation-types.md`
