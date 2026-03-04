# Claude Code Clean Slate Rebuild

## Context

The current Claude Code setup (Claude-Customizations repo symlinked to `~/.claude/`) has grown to 95 skills, 133 agents, 4 plugins, and 8 rules, all loaded every session. This causes context overload where Claude misses rules, fails to trigger skills, and ignores instructions. Additional problems include duplicate hooks firing from two config surfaces (`settings.json` and `hooks.json`), broken notification hooks (`ntfy` not installed), and an ecosystem-awareness hook that injects references to 132 agents and 91 skills on capability questions.

## Root Causes Identified

1. **Context overload**: 95 skills + 133 agents listed in every system prompt

2. **Duplicate hooks**: `auto-commit-claude-mem` defined in both `settings.json` and `hooks.json` (fires twice per prompt)

3. **Ecosystem-awareness hook** adds noise by referencing agents/skills that shouldn't dominate context

4. **4 plugins** (code-simplifier, hookify, plannotator, claude-mem) each injecting context; only claude-mem is used

5. **82 accumulated permissions** in allow list (many auto-added by "always allow" clicks)

6. **Broken ntfy notification hooks** (command not installed)

## Approach

**Fresh start with evaluation-first strategy.** Do not modify the existing Claude-Customizations repo. Install PAI + Mission Control as the primary configuration to evaluate. Build a custom LifeOS setup separately in a worktree, migrating elements from the current repo one at a time after review.

### Two-track setup

| Track | Purpose | Location |
|-------|---------|----------|
| **Main** | PAI + Mission Control (evaluate as daily driver) | `~/.claude/` |
| **Worktree** | Custom LifeOS build (constructed from scratch) | TBD worktree branch |
| **Archive** | Current Claude-Customizations (reference only) | `~/Projects/Claude-Customizations` |

## What to Preserve

| Item | Location | Action |
|------|----------|--------|
| claude-mem DB | `~/.claude-mem/` | Safe (outside `~/.claude/`) |
| Project memories | `~/.claude/projects/*/memory/` | Copy out before cleanup |
| Claude-Customizations repo | `~/Projects/Claude-Customizations` | Keep as-is, future reference |
| `~/.claude.json` | Home directory | Back up (global MCP server configs) |

## Implementation Steps

### Phase 1: Backup and Disconnect

The Claude-Customizations repo at `~/Projects/Claude-Customizations` is not affected by any step below. Only symlinks inside `~/.claude/` are removed, the repo itself stays intact as the reference archive. Runtime data (debug logs, telemetry, cache) exists only inside `~/.claude/` and is not part of the repo.

#### Step 1: Back up project memories and global config

```bash
mkdir -p /tmp/claude-rebuild-backup
cp -r ~/.claude/projects/ /tmp/claude-rebuild-backup/projects/ 2>/dev/null
cp ~/.claude.json /tmp/claude-rebuild-backup/claude.json 2>/dev/null
```

#### Step 2: Remove all symlinks from `~/.claude/`

Disconnect Claude-Customizations without modifying the repo.

```bash
# Remove symlinks only (leaves real directories intact)
find ~/.claude -maxdepth 1 -type l -delete
```

#### Step 3: Clean `~/.claude/` runtime cruft

Remove accumulated data (~1.7 GB). Keep `projects/` and `plugins/`.

```bash
rm -rf ~/.claude/debug ~/.claude/todos ~/.claude/session-env \
       ~/.claude/shell-snapshots ~/.claude/file-history ~/.claude/plans \
       ~/.claude/backups ~/.claude/telemetry ~/.claude/cache \
       ~/.claude/ide ~/.claude/history.jsonl ~/.claude/stats-cache.json \
       ~/.claude/.git
```

### Phase 2: Install PAI + Mission Control

#### Step 4: Install PAI

Follow PAI installation. This becomes the main `~/.claude/` configuration.

```bash
# Clone PAI
git clone https://github.com/danielmiessler/Personal_AI_Infrastructure.git /tmp/pai-install
cd /tmp/pai-install

# Install into ~/.claude/
cp -r .claude/* ~/.claude/
cd ~/.claude
bash install.sh
```

Post-install tasks:

- Restore project memories: `cp -r /tmp/claude-rebuild-backup/projects/ ~/.claude/projects/`

- Merge MCP server configs from backed-up `~/.claude.json` (Playwright, claude-mem, etc.)

- Re-install claude-mem plugin if not present: `claude plugin add claude-mem@thedotmack`

- Configure TELOS identity files in `~/.claude/PAI/USER/TELOS/`

#### Step 5: Install MeisnerDan Mission Control

```bash
# Clone and set up Mission Control
git clone https://github.com/MeisnerDan/mission-control.git ~/Tools/mission-control
cd ~/Tools/mission-control
npm install
```

Post-install tasks:

- Configure MC's MCP server connection to Claude Code

- Set up task files location

- Launch dashboard and verify connectivity

#### Step 6: Verify PAI + MC baseline

- [ ] Claude Code launches with PAI configuration
- [ ] TELOS identity loads at session start
- [ ] PAI hooks fire correctly (no errors)
- [ ] claude-mem search works
- [ ] Mission Control dashboard connects
- [ ] MC can spawn Claude Code sessions
- [ ] Project memories accessible

### Phase 3: Build Custom LifeOS Setup

#### Step 7: Create worktree for custom build

Create a worktree from the Claude-Customizations repo for building the custom LifeOS configuration.

```bash
cd ~/Projects/Claude-Customizations
git worktree add ~/.claude/worktrees/lifeos-build lifeos-build
```

#### Step 8: Audit and migrate (item by item)

Review every component in Claude-Customizations and decide what migrates to the custom build. Nothing is pre-decided.

**Skills audit** (~95 skills across 16 categories):

For each skill, decide: migrate, skip, or merge with PAI equivalent.

Categories to review: Planning, Git, Code-Quality, Learning, Notion, Design, Deployment, Hooks, Agents, Brainstorming, Debugging, Research, Content, Canvas, Documentation, Misc.

**Agents audit** (133 agents):

Review whether any agents are needed given PAI's 14 built-in agents.

**Rules audit** (8 rule files):

Review each rule file. Decide what integrates with PAI's AISTEERINGRULES.md vs stays separate.

- ai-chat-prefs.md
- behavioral-rules.md
- coding-standards.md
- formatting-rules.md
- memory-boundaries.md
- model-selection.md
- security-checklist.md
- technical-consistency.md

**Hooks audit**:

Compare existing hooks with PAI's 20 TypeScript hooks. Decide what's redundant vs additive.

**Plugins audit** (4 plugins):

- claude-mem (keep)
- hookify (review)
- code-simplifier (review)
- plannotator (review)

**Settings audit**:

- Permissions (82 entries): review each, decide what carries over
- Additional directories (8 entries): review each
- Environment variables: review each
- Hook configurations: review each

**MCP servers audit**:

Review `~/.claude.json` MCP server configs. Decide what's still needed alongside PAI + MC.

#### Step 9: Swap when ready

Once the custom build is validated, swap it in as the main configuration. Keep PAI available as a reference or fallback.

Timing: No deadline. Evaluate PAI for as long as needed before deciding.

## Reference: Current Setup Inventory

Located at `~/Projects/Claude-Customizations` (do not modify).

| Component | Count | Notes |
|-----------|-------|-------|
| Skills | 95 | 16 functional categories |
| Agents | 133 | Subagent definitions |
| Plugins | 4 | claude-mem, hookify, code-simplifier, plannotator |
| Rules | 8 | Behavioral, coding, formatting, security, etc. |
| Hook configs | 7 | 2 broken (ntfy), 2 duplicate (claude-mem) |
| Permissions | 82 | Many auto-added |
| Additional dirs | 8 | Several unnecessary |
| Runtime cruft | ~1.7 GB | debug, todos, telemetry, cache |

## Reference: Research Document

Full research on PAI, Mission Control options, compatibility analysis, and comparisons:

`workspace/docs/references/cc-reinstall-research.md`
