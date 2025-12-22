# Claude Code Preferences & Decisions

This document tracks preferences, rules, and decisions for Claude Code customization.

---

## Skills & Agents Management

### When to Use Which

| Use Case | Best Tool | Why |
|----------|-----------|-----|
| Reusable prompts/templates | **Skill** | Simple, shares conversation context |
| Domain knowledge/standards | **Skill** | Instructions loaded when relevant |
| Multi-step autonomous tasks | **Agent** | Runs independently, returns results |
| Parallel execution | **Agent** | Multiple agents can run simultaneously |
| Complex exploration/research | **Agent** | Isolated context, thorough investigation |
| Quick enhancements | **Skill** | No subprocess overhead |

### Overlap Analysis (Last checked: 2024-12-22)

**Skills — No conflicts found.**

Checked pairs:
- `skill-assistant` vs `skill-creator` — **Complementary**, not conflicting. One finds/installs skills, the other guides creation.

**Agents — None installed yet.**

### Bundled Items

Some skills/agents contain sub-items in nested folders:

| Bundle | Contains |
|--------|----------|
| `skills/document-skills/` | `docx/`, `pdf/`, `pptx/`, `xlsx/` |

Each sub-folder has its own `SKILL.md` with type-specific instructions.

### Installation Rules

Applies to both skills and agents:

1. **Avoid duplicates** — Before installing, check if a similar one exists
2. **Clean install preferred** — When updating, delete the old directory first:
   ```bash
   rm -rf skills/my-skill && cp -R /source/my-skill skills/
   rm -rf agents/my-agent && cp -R /source/my-agent agents/
   ```
3. **Naming convention** — Use kebab-case for directories (e.g., `my-skill-name`, `my-agent-name`)
4. **Check for overlap** — If two items do similar things, keep only one or ensure they handle distinct use cases

### Priority & Conflicts

When multiple skills/agents could handle a request:
- Skills: Both loaded into context (may cause unpredictable behavior if conflicting)
- Agents: User/Claude chooses which to invoke

**Resolution**: Remove duplicates or ensure clear separation of concerns

---

## Directory Structure

```
~/.claude/
├── skills/     → symlink to this project's skills/
├── agents/     → symlink to this project's agents/
└── ...

/Users/royengel/Projects/Claude Code/claude-customizations/
├── skills/           # All installed skills
├── agents/           # Custom agents
├── PREFERENCES.md    # This file
└── README.md         # Project overview
```

---

## Session Management

### Resuming Conversations

| Command | Purpose |
|---------|---------|
| `claude --continue` | Resume most recent conversation in current directory |
| `claude --resume` | Interactive picker for all sessions |
| `claude --resume <name>` | Resume specific named session |

### Best Practice

Always name important sessions with `/rename <name>` for easy retrieval later.

---

## Skills vs Agents

| Aspect | Skills | Agents |
|--------|--------|--------|
| What they are | Markdown prompts/instructions | Subprocesses via Task tool |
| Location | `skills/` directory | Built-in or `agents/` directory |
| Invocation | `/skill-name` or auto-matched | Task tool with `subagent_type` |
| Context | Shares main conversation | Isolated subprocess |
| Use case | Reusable prompts, domain knowledge | Multi-step autonomous tasks |

---

## Installed Skills

Source: [ComposioHQ/awesome-claude-skills](https://github.com/ComposioHQ/awesome-claude-skills)

### By Category

**Development**
- artifacts-builder
- changelog-generator
- mcp-builder
- skill-creator
- webapp-testing

**Documents**
- document-skills (docx, pdf, pptx, xlsx)

**Business**
- brand-guidelines
- competitive-ads-extractor
- domain-name-brainstormer
- internal-comms
- lead-research-assistant

**Writing**
- content-research-writer
- meeting-insights-analyzer

**Creative**
- canvas-design
- image-enhancer
- slack-gif-creator
- theme-factory
- video-downloader

**Productivity**
- file-organizer
- invoice-organizer
- raffle-winner-picker

**Meta**
- skill-assistant
- skill-share
- template-skill

---

## Changelog

| Date | Change |
|------|--------|
| 2024-12-22 | Initial document created |
| 2024-12-22 | Installed 23 skills from awesome-claude-skills |
| 2024-12-22 | Set up symlinks for ~/.claude/skills and ~/.claude/agents |
| 2024-12-22 | Unified skills & agents management with decision criteria |
