# Claude Code Reinstall Research

Research conducted March 3, 2026. Covers mission control dashboards, PAI (Personal AI Infrastructure), and compatibility analysis for a clean-slate Claude Code rebuild.

## Table of Contents

1. [User Context and Goals](#1-user-context-and-goals)
2. [Mission Control Dashboards: Full Survey](#2-mission-control-dashboards-full-survey)
3. [Usage and Cost Monitoring Tools](#3-usage-and-cost-monitoring-tools)
4. [Deep Dive: builderz-labs/mission-control](#4-deep-dive-builderz-labsmission-control)
5. [Deep Dive: MeisnerDan/mission-control](#5-deep-dive-meisdanmission-control)
6. [Deep Dive: winfunc/opcode](#6-deep-dive-winfuncopcode)
7. [Three-Way Comparison](#7-three-way-comparison)
8. [PAI (Personal AI Infrastructure) Overview](#8-pai-personal-ai-infrastructure-overview)
9. [PAI vs Current Setup Comparison](#9-pai-vs-current-setup-comparison)
10. [PAI + Mission Control Complementarity](#10-pai--mission-control-complementarity)
11. [PAI Directory Structure Investigation](#11-pai-directory-structure-investigation)
12. [Compatibility and Conflict Analysis](#12-compatibility-and-conflict-analysis)
13. [Decisions Made](#13-decisions-made)
14. [Open Questions](#14-open-questions)

---

## 1. User Context and Goals

### Current Setup

- Claude Code Max subscription (no separate API key needed)
- Claude-Customizations repo symlinked to `~/.claude/`
- 95 skills (targeting ~25 after rebuild), 133 agents (targeting 0), 8 rule files
- 4-system memory architecture: MEMORY.md, STATE.md, claude-mem, /compound
- Existing CLEAN-SLATE-REBUILD.md plan in progress

### Stated Goals

- **LifeOS system** is the top priority (not just developer tooling)
- Clean-slate reinstall of Claude Code setup
- Wants a mission control center for Claude Code
- Interested in deeper identity/personalization layer (beyond developer preferences)
- Wants to evaluate PAI side-by-side (Option C approach)

### Preferences Expressed

- MeisnerDan/mission-control selected as the mission control tool
- Expected Mission Control to cover notifications, voice, and monitoring (partially correct: covers monitoring and cost tracking, not notifications or voice)
- Interested in PAI's TELOS identity system for the LifeOS use case

---

## 2. Mission Control Dashboards: Full Survey

### Projects Identified

| Project | GitHub | Focus | Stars |
|---------|--------|-------|-------|
| builderz-labs/mission-control | [Link](https://github.com/builderz-labs/mission-control) | Agent orchestration dashboard | ~1.2k |
| MeisnerDan/mission-control | [Link](https://github.com/MeisnerDan/mission-control) | Task management for solo entrepreneurs | Newer |
| androsovm/clorch | [Link](https://github.com/androsovm/clorch) | Session monitoring TUI | - |
| winfunc/opcode | [Link](https://github.com/winfunc/opcode) | Desktop GUI app | ~20.8k |
| Tpain166/claude-dashboard | [Link](https://github.com/Tpain166/claude-dashboard) | Session TUI | - |
| abhi1693/openclaw-mission-control | [Link](https://github.com/abhi1693/openclaw-mission-control) | OpenClaw agent orchestration | - |
| crshdn/mission-control | [Link](https://github.com/crshdn/mission-control) | OpenClaw agent orchestration (fork) | - |
| BEKO2210/Control-Center | [Link](https://github.com/BEKO2210/Control-Center) | AI agent orchestration | - |

### Quick Assessment

- **builderz-labs**: Most complete infrastructure (26 panels, SQLite, WebSocket)
- **MeisnerDan**: Best project management philosophy (Eisenhower Matrix, autonomous backlog execution)
- **clorch**: Lightweight TUI hooking into Claude Code's hook system
- **opcode**: Most polished desktop GUI but no project management features
- **claude-dashboard**: Lightweight TUI with auto session detection

---

## 3. Usage and Cost Monitoring Tools

| Tool | Type | Focus | Link |
|------|------|-------|------|
| Claude Code Usage Monitor (claude-monitor) | Terminal TUI | Token tracking, burn rate, ML-based predictions | [GitHub](https://github.com/Maciek-roboblog/Claude-Code-Usage-Monitor) |
| SigNoz Claude Code Dashboard | OpenTelemetry | OTel-based metrics export for teams | [Docs](https://signoz.io/docs/dashboards/dashboard-templates/claude-code-dashboard/) |
| Datadog AI Agents Console | SaaS | Enterprise adoption tracking, org-wide spend/ROI | [Blog](https://www.datadoghq.com/blog/claude-code-monitoring/) |

---

## 4. Deep Dive: builderz-labs/mission-control

**Source**: [github.com/builderz-labs/mission-control](https://github.com/builderz-labs/mission-control)

### Claude Code Integration

- REST API + auto-discovery (scans `~/.claude/projects/` every 60 seconds)
- Parses JSONL transcripts for token usage, model info, message counts, cost estimates, active status
- Endpoints: `POST /api/spawn`, `POST /api/agents/message`, `POST /api/tasks/[id]/broadcast`
- Agents send heartbeats with inline token reporting
- No MCP server required
- No API key needed (uses Claude Code CLI auth)

### Configuration

- `MC_CLAUDE_HOME`: Path to `~/.claude` (defaults to `~/.claude`)
- `OPENCLAW_MEMORY_DIR`: Points agents root directory
- `AUTH_USER/AUTH_PASS`: Dashboard credentials

### Project Management Features

- Kanban board: 6 columns (inbox, backlog, todo, in-progress, review, done)
- Drag-and-drop, priority levels, assignments, threaded comments
- Task filtering by status, assignee, priority
- Pipeline orchestration with workflow templates
- Quality review gates (block completion without sign-off)
- Background scheduler and cron jobs
- Role-based access: viewer, operator, admin

### Tech Stack

- Next.js 16, React 19, TypeScript 5.7
- SQLite via better-sqlite3 (WAL mode)
- WebSocket + Server-Sent Events for real-time updates
- Zero external dependencies (no Redis/Postgres/Docker)

### Installation

```bash
git clone https://github.com/builderz-labs/mission-control
pnpm install
cp .env.example .env
pnpm dev
```

### Limitations

- Alpha software (APIs, database schemas may change between releases)

---

## 5. Deep Dive: MeisnerDan/mission-control

**Source**: [github.com/MeisnerDan/mission-control](https://github.com/MeisnerDan/mission-control)

### Claude Code Integration

- Spawns Claude Code via `claude -p` (preserves CLI authentication)
- File-based IPC using JSON data files as shared source of truth
- Token-optimized API endpoints (~50 tokens vs ~5,400 for full payloads)
- Slash commands accessible inside Claude Code sessions: `/standup`, `/daily-plan`, `/weekly-review`, `/orchestrate`, `/brainstorm`, `/research`, `/plan-feature`, `/ship-feature`, `/pick-up-work`, `/report`
- Role-specific commands: `/researcher`, `/marketer`
- Session resilience: agents that timeout auto-respawn continuation sessions
- No API key needed (uses Claude Code CLI auth)
- No MCP required

### Project Management Features

- **Eisenhower Matrix**: Drag-and-drop between Do, Schedule, Delegate, Eliminate quadrants
- **Kanban board**: Not Started, In Progress, Done
- Subtasks, acceptance criteria, priority levels
- Dependency chains respected during continuous mission execution
- Goal hierarchy with milestone tracking and progress visualization
- "Brain dump" for quick idea capture with later triage

### Agent System

- 5 built-in roles: Me (decisions), Researcher, Developer, Marketer, Business Analyst
- Custom agent creation with user-defined instructions
- Multi-agent tasks with lead agent plus collaborators
- Role-based skill injection from reusable knowledge library

### Automation

- Daemon: background Node.js process polling tasks, spawning Claude Code sessions
- Cron-scheduled commands (standup, daily-plan, weekly-review)
- Concurrency enforcement
- One-click task execution spawning Claude Code sessions
- Continuous missions: run entire projects with auto-dispatch as tasks complete
- Loop detection: escalates to user after 3 failures
- Inbox system for agent-human communication, reports, approvals
- "Inbox stop button" for mid-response agent interruption

### Cost and Usage Tracking

- Captures cost and full token usage (input, output, cache read, cache creation) from every Claude Code session
- Per-task cost breakdown and running totals
- Failure logging with error details, session count, agent information

### What It Does NOT Have

- Push notifications (no ntfy, Discord, email)
- Voice output (no TTS)
- These are not on the published roadmap

### Tech Stack

- Next.js 15 (App Router), TypeScript (strict mode)
- Tailwind CSS v4, shadcn/ui + Radix UI
- @dnd-kit for drag/drop, Zod for validation, cmdk for search
- Vitest (193 tests)
- Local JSON files for storage (no database)

### Installation

```bash
git clone https://github.com/MeisnerDan/mission-control.git
cd mission-control/mission-control
pnpm install
pnpm dev
# Opens on http://localhost:3000 with demo data available
```

**Requirements**: Node.js v20+, pnpm v9+, Claude Code CLI

### Limitations

- Local-only (cloud sync on roadmap)
- JSON file I/O (no database, not ideal for large teams)
- Pre-v1.0 (version 0.9.1)
- No GitHub Issues sync (planned)
- No mobile PWA

---

## 6. Deep Dive: winfunc/opcode

**Source**: [github.com/winfunc/opcode](https://github.com/winfunc/opcode)

### Claude Code Integration

- Auto-detects `~/.claude` directory
- Reads Claude Code's native project structure and session files
- Background agent execution in separate processes
- MCP server management UI (import from Claude Desktop)
- Read-heavy integration: limited bidirectional command injection back to Claude Code CLI
- No API key needed

### Features

1. **Project & Session Management**: Visual browser for `~/.claude/projects/`, session history with metadata, smart search and resumption

2. **CC Agents**: Custom AI agents with system prompts, background execution, execution history and performance logs

3. **Usage Analytics Dashboard**: Cost tracking, token analytics, usage trend charts, data export

4. **MCP Server Management**: Server registry and configuration UI, connection testing, import from Claude Desktop

5. **Timeline & Checkpoints**: Session versioning with branching timelines, instant restore to any checkpoint, diff viewer between checkpoints

6. **CLAUDE.md Management**: Built-in markdown editor, live preview, project-wide file scanning

### What It Does NOT Have

- No task management, kanban boards, workflow automation, or assignment features
- No notifications or voice
- No release binaries yet (must build from source)

### Tech Stack

- Tauri 2 (Rust backend), React 18, TypeScript, Vite 6
- Tailwind CSS v4 + shadcn/ui
- SQLite (via rusqlite)
- Bun package manager
- AGPL license

### Installation

Requires Rust 1.70.0+, Bun, Git, and platform-specific dependencies (libwebkit2gtk on Linux, Xcode CLI tools on macOS).

```bash
git clone https://github.com/getAsterisk/opcode.git
cd opcode
bun install
bun run tauri dev    # Development
bun run tauri build  # Production
```

### Limitations

- No project management features at all
- No release binaries (build from source only)
- Complex installation (Rust + Bun + platform libs)
- Limited Claude Code bidirectionality
- 259 open issues on GitHub

---

## 7. Three-Way Comparison

### Claude Code Integration

| Aspect | builderz-labs | MeisnerDan | opcode |
|--------|---------------|------------|--------|
| Connection method | REST API + auto-discovery | CLI via `claude -p` + file-based IPC | Reads `~/.claude/` directory |
| Session discovery | Scans `~/.claude/projects/` every 60s, parses JSONL | Daemon spawns and manages sessions | Auto-detects from `~/.claude/projects/` |
| Task dispatch | REST endpoints (`/api/spawn`, `/api/agents/message`) | Daemon auto-polls task queue, spawns sessions | Background agent execution |
| Bidirectional? | Yes (send tasks, receive heartbeats + token reports) | Yes (slash commands inside sessions) | Read-heavy, limited command injection |
| MCP required? | No | No | No (but has MCP management UI) |
| Auth model | Session + API key auth, role-based | Stays within Claude Code's auth layer | Local-only, no auth needed |

### Project Management

| Feature | builderz-labs | MeisnerDan | opcode |
|---------|---------------|------------|--------|
| Task board | Kanban (6 columns) | Eisenhower Matrix + Kanban | None |
| Task assignment | To humans or agents | 5 roles + custom agents | None |
| Priority levels | Yes | Yes | None |
| Comments/threads | Threaded comments | Inbox system | None |
| Review gates | Quality gates block completion | Loop detection escalates after 3 failures | None |
| Workflows/pipelines | Pipeline orchestration with templates | Continuous missions with auto-dispatch | None |
| Scheduling | Cron jobs + background scheduler | Cron-scheduled commands | None |
| Goal tracking | Not mentioned | Goal hierarchy with milestones | None |

### Technical

| Aspect | builderz-labs | MeisnerDan | opcode |
|--------|---------------|------------|--------|
| Tech stack | Next.js 16, React 19, TS | Next.js 15, TS, Tailwind v4 | Tauri 2 (Rust), React 18, Vite 6 |
| Storage | SQLite (WAL mode) | Local JSON files | SQLite (rusqlite) |
| Real-time | WebSocket + SSE | Daemon polling | None |
| GitHub stars | ~1.2k | Newer/smaller | ~20.8k |
| Maturity | Alpha | Pre-v1.0 (0.9.1) | Active (201 commits), no binaries |
| Install complexity | `pnpm install && pnpm dev` | `pnpm install && pnpm dev` | Rust + Bun + platform libs |
| Tests | Not mentioned | 193 tests (Vitest) | Not mentioned |

### API Key Requirements

All three work with Claude Code Max subscription. None require a separate Anthropic API key. All three are wrappers around the Claude Code CLI that inherit the existing authentication.

| Tool | Auth mechanism | API key needed? |
|------|---------------|-----------------|
| builderz-labs | Scans `~/.claude/projects/` locally | No (own API key for dashboard, not Claude) |
| MeisnerDan | Spawns `claude -p`, inherits CLI auth | No ("no API keys, no vendor lock-in") |
| opcode | Reads `~/.claude/`, requires `claude` in PATH | No (inherits CLI auth) |

### Unique Strengths

- **builderz-labs**: Most complete infrastructure. 26 panels, zero external deps, WebSocket real-time, agent fleet management at scale.

- **MeisnerDan**: Best PM philosophy. Eisenhower Matrix, token-optimized API (~50 tokens/call), slash commands inside Claude Code sessions, continuous mission execution, goal hierarchy.

- **opcode**: Best desktop experience. Timeline/checkpoints with instant restore, diff viewer, CLAUDE.md editor, usage analytics charts. Zero PM features.

---

## 8. PAI (Personal AI Infrastructure) Overview

**Source**: [github.com/danielmiessler/Personal_AI_Infrastructure](https://github.com/danielmiessler/Personal_AI_Infrastructure)

### What PAI Is

PAI is a philosophical framework + runtime for personal AI infrastructure. Described as "Agentic AI Infrastructure for magnifying HUMAN capabilities." Not a dashboard or monitoring tool.

Core mission: Help people identify and pursue their goals through AI-augmented self-discovery while democratizing access to enterprise-grade AI infrastructure.

### 9 Core Primitives

1. **Assistant vs. Agent-Based Interaction**: Persistent assistant/friend/coach/mentor, not a stateless agent

2. **TELOS (Deep Goal Understanding)**: 10 markdown files capturing identity:
   - `MISSION.md` - Life mission
   - `GOALS.md` - Goals
   - `PROJECTS.md` - Active projects
   - `BELIEFS.md` - Core beliefs
   - `MODELS.md` - Mental models
   - `STRATEGIES.md` - Strategies
   - `NARRATIVES.md` - Personal narratives
   - `LEARNED.md` - Lessons learned
   - `CHALLENGES.md` - Current challenges
   - `IDEAS.md` - Ideas

3. **User/System Separation**: USER/ directory for customizations, SYSTEM/ for infrastructure; upgrades preserve user data

4. **Granular Customization**: Six layers:
   - Identity (name, voice, personality)
   - Preferences (tech stack)
   - Workflows
   - Skills
   - Hooks
   - Memory

5. **Skill System**: Deterministic hierarchy: CODE → CLI-BASED-TOOL → PROMPT → SKILL (prefer code/bash over AI when possible)

6. **Memory System**: Three-tier architecture:
   - Hot: active session context
   - Warm: recent sessions, accessible on demand
   - Cold: archived learnings, signals
   - Phase-based learning directories capture ratings, sentiment, successes

7. **Hook System**: Eight lifecycle event types (session start, tool use, task completion) enabling notifications, context loading, security validation

8. **Security System**: Default policies at system and user levels; hooks validate commands pre-execution without blocking workflows

9. **Notification & Voice**:
   - ntfy push notifications
   - Discord integration
   - Twilio (mentioned in settings.json)
   - ElevenLabs TTS with prosody enhancement
   - Fire-and-forget notification design

### Key Principles

- "System architecture matters more than which model you use" (Scaffolding > Model)
- "If you can solve it with a bash script, don't use AI" (Code Before Prompts)
- "Command-line interfaces are faster, more scriptable, and more reliable than GUIs" (CLI as Interface)

### Tech Stack

- Built on Claude (Anthropic's model)
- TypeScript
- Runtime: Bun
- Interface: Terminal-based CLI (no GUI dashboard)
- Version: 4.0.3

### Relationship to Mission Control

PAI and Mission Control are unrelated projects. They are complementary, not competing:
- PAI shapes how Claude thinks about you (identity, goals, behavior)
- Mission Control manages what Claude is working on (tasks, sessions, costs)
- Neither attempts to do what the other does
- No feature overlap identified

---

## 9. PAI vs Current Setup Comparison

### Layer 1: Identity and Personalization

| Aspect | PAI | Current Setup |
|--------|-----|---------------|
| System | TELOS: 10 dedicated files | `rules/ai-chat-prefs.md` (user profile, tone, reasoning) |
| Depth | Deep identity modeling: life mission, mental models, personal narratives | Behavioral preferences: communication style, reasoning approach |
| Gap? | **Yes.** No equivalent to GOALS, BELIEFS, MODELS, STRATEGIES, NARRATIVES. PAI treats user as a whole person; current setup treats user as a developer with preferences. |

### Layer 2: Customization

| PAI Layer | PAI Implementation | Current Equivalent | Parity? |
|-----------|-------------------|-------------------|---------|
| Identity | Name, voice, personality files | `ai-chat-prefs.md` (partial) | Partial |
| Preferences | Tech stack, formatting | `coding-standards.md`, `formatting-rules.md`, `technical-consistency.md` | **Current is stronger** (more granular) |
| Workflows | Workflow definitions | `skills/Planning/my-workflow/` + `/start`, `/plan`, `/build`, `/status` | **Current is stronger** (full lifecycle) |
| Skills | CODE → CLI → PROMPT → SKILL hierarchy | `skills/` (80+ skills in 16 groups) | **Current is much stronger** (PAI has philosophy, current has inventory) |
| Hooks | 8 lifecycle event types, 20 TypeScript hooks | `hooks/` (auto-commit, CLAUDE.md) | **PAI has more hook types**; current has fewer but functional |
| Memory | 3-tier (hot/warm/cold) | 4-system (MEMORY.md / STATE.md / claude-mem / /compound) | **Different design, comparable capability** |

### Layer 3: Memory Architecture

| Aspect | PAI (3-tier) | Current (4-system) |
|--------|-------------|-------------------|
| Hot | Active session context | MEMORY.md (auto-loaded every session) |
| Warm | Recent sessions, on demand | claude-mem (MCP searchable) + STATE.md (living handoff) |
| Cold | Archived learnings, signals | /compound (curated problem-solution pairs) |
| Learning signals | Ratings, sentiment, success/failure capture | claude-mem auto-captures; /compound for verified solutions |
| Decision tree | Not documented | Explicit decision tree for routing |
| Assessment | PAI captures signals (passive). Current captures knowledge (intentional). PAI is more automatic. Current produces higher quality artifacts. |

### Layer 4: Skills

| Aspect | PAI | Current |
|--------|-----|---------|
| Philosophy | CODE → CLI → PROMPT → SKILL (prefer code over AI) | Skill-first design, self-contained units |
| Count | 11 categories shipped publicly (338 workflows claimed) | 80+ skills across 16 functional groups |
| Organization | Flat categories: Agents, ContentAnalysis, Thinking, etc. | Grouped: Planning, Code-Quality, Git, Notion, Design, etc. |
| Agents | Not separated from skills | 133 dedicated agent definitions (targeting 0 after rebuild) |
| Notable gap | PAI's "code before prompts" hierarchy is a useful design constraint not explicitly codified in current setup |

### Layer 5: Security

| Aspect | PAI | Current |
|--------|-----|---------|
| Model | Default policies + pre-execution hook validation | `security-checklist.md` (pre-commit checks), `behavioral-rules.md` |
| Hook-based | Yes, SecurityValidator.hook.ts validates before execution | Hook infrastructure exists but no security hooks |
| Assessment | PAI's pre-execution validation is more proactive. Current security is checklist-based (reactive). |

### Layer 6: Notifications and Voice

| Aspect | PAI | Current |
|--------|-----|---------|
| Notifications | ntfy push, Discord, Twilio | None (ntfy hooks existed but broken, being removed in rebuild) |
| Voice | ElevenLabs TTS with prosody | None |
| Assessment | **Clear gap.** Current setup has no notification or voice system. |

### Layer 7: Architecture and Governance

| Aspect | PAI | Current |
|--------|-----|---------|
| User/System separation | USER/ vs SYSTEM/ dirs, upgrades preserve user data | Symlink to `~/.claude/`, git-managed, no formal split |
| Upgrade path | Dedicated installer, backup + migrate + merge | Git pull (changes immediately live) |
| Governance | Implicit in architecture | Explicit: OVERVIEW.md with principles, amendment process |
| Assessment | PAI's user/system separation is resilient. Current governance is more formalized. |

### Summary: What PAI Has That Current Setup Doesn't

1. Deep identity modeling (TELOS: goals, beliefs, mental models, narratives, life mission)
2. Notification system (ntfy push, Discord, Twilio)
3. Voice output (ElevenLabs TTS)
4. Pre-execution security hooks (validate before running)
5. "Code before prompts" hierarchy (explicit escalation principle)
6. User/System directory separation (upgrade resilience)
7. Learning signals (passive capture of ratings, sentiment, success/failure)

### Summary: What Current Setup Has That PAI Doesn't

1. 133 specialized agents (PAI doesn't separate agents from skills)
2. 80+ skills in 16 groups (larger, more organized skill library)
3. 4-system memory with explicit routing (decision tree, overlap handling)
4. Full project lifecycle (/start, /plan, /build, /status, /handoff)
5. MCP server ecosystem (Notion, Playwright, Supabase, etc.)
6. Formal governance (OVERVIEW.md, amendment process, compliance)
7. Documentation type system (typed subdirs, docs-enforcer agent)
8. claude-mem plugin (automatic cross-session observation capture)

---

## 10. PAI + Mission Control Complementarity

PAI and Mission Control have zero feature overlap:

| Concern | PAI | Mission Control |
|---------|-----|-----------------|
| Who you are | TELOS (goals, beliefs, mission, strategies) | - |
| How Claude behaves | Identity, preferences, voice, notifications | - |
| What Claude is working on | - | Task board, agent dispatch, session management |
| Cost awareness | - | Token tracking, per-task cost breakdown |
| Memory/learning | 3-tier memory, learning signals | Activity logs, failure logging |
| Notifications | ntfy push, Discord, Twilio | - |
| Voice | ElevenLabs TTS | - |

PAI shapes Claude's understanding of you. Mission Control manages the work Claude does.

### Feature Coverage Across All Three Systems

| Feature | PAI | MeisnerDan MC | Current Setup |
|---------|-----|---------------|---------------|
| Identity/goals | Yes | No | Partial (ai-chat-prefs.md) |
| Task management | No | Yes (Eisenhower + Kanban) | No |
| Session monitoring | No | Yes (live status, auto-respawn) | No |
| Cost tracking | No | Yes (per-task breakdown) | No |
| Skills | 11 categories | Slash commands in sessions | 80+ skills |
| Agents | 14 agents | 5 roles + custom | 133 agents (targeting 0) |
| Memory | 3-tier | Activity logs | 4-system |
| Notifications | ntfy, Discord, Twilio | No | None (broken) |
| Voice | ElevenLabs TTS | No | None |
| Rules/behavior | AISTEERINGRULES.md | No | 8 rule files |
| Governance | Implicit | No | Explicit (OVERVIEW.md) |
| Workflow lifecycle | No | Continuous missions | /start, /plan, /build, /status |

---

## 11. PAI Directory Structure Investigation

Full investigation of PAI's actual file layout on disk.

### Installation Mechanism

PAI installs via a destructive directory copy:

```bash
cp -r .claude ~/    # Copies entire .claude/ into home directory
cd ~/.claude
bash install.sh     # Runs Bun-based installer (GUI or CLI)
```

The `cp -r` command merges directories but **overwrites individual files** with matching names. Symlinks are replaced with regular files.

### Complete Directory Tree

```
~/.claude/
├── CLAUDE.md                    # Generated from template at EVERY session start
├── CLAUDE.md.template           # Template with placeholders ({DAIDENTITY.NAME}, etc.)
├── install.sh                   # Bootstrap installer (bash)
├── settings.json                # Central config (hooks, permissions, identity, env)
├── statusline-command.sh        # Terminal status line script
├── PAI/                         # Core system ("SYSTEM" tier)
│   ├── SKILL.md                 # Main PAI skill definition
│   ├── AISTEERINGRULES.md       # AI behavior rules (loaded at startup)
│   ├── MEMORYSYSTEM.md
│   ├── PAISYSTEMARCHITECTURE.md
│   ├── SKILLSYSTEM.md
│   ├── THEHOOKSYSTEM.md
│   ├── PRDFORMAT.md
│   ├── ... (22 docs + 6 subdirs)
│   ├── Algorithm/               # Algorithm version files
│   ├── Tools/                   # 39+ TypeScript tools (BuildCLAUDE.ts, pai.ts, etc.)
│   └── USER/                    # User customization tier ("USER always wins")
│       ├── TELOS/               # Goal/identity files
│       │   └── README.md        # Placeholder at install (user creates the 10 files)
│       ├── PROJECTS/            # User's project definitions
│       ├── AISTEERINGRULES.md   # User's AI behavior overrides
│       ├── SKILLCUSTOMIZATIONS/ # Per-skill preference overrides
│       ├── BUSINESS/
│       ├── ACTIONS/
│       ├── FLOWS/
│       ├── PIPELINES/
│       ├── STATUSLINE/
│       ├── TERMINAL/
│       ├── WORK/
│       └── Workflows/
├── PAI-Install/                 # Installer engine
│   ├── main.ts                  # Entry point (runs via bun)
│   ├── install.sh
│   ├── engine/                  # actions.ts, config-gen.ts, detect.ts, steps.ts, etc.
│   ├── cli/
│   ├── electron/                # GUI installer (Electron app)
│   └── web/
├── MEMORY/                      # Persistent memory system
│   ├── WORK/                    # PRDs, session artifacts
│   ├── LEARNING/                # Insights, failures, signals, synthesis
│   │   ├── SYSTEM/
│   │   ├── ALGORITHM/
│   │   ├── FAILURES/
│   │   ├── SYNTHESIS/
│   │   └── SIGNALS/
│   ├── RELATIONSHIP/            # Interaction preferences/history
│   ├── STATE/                   # Runtime state, session names, algorithm state
│   └── VOICE/                   # Voice interaction logs
├── agents/                      # 14 agent definitions (.md files)
│   ├── Algorithm.md
│   ├── Architect.md
│   ├── Engineer.md
│   ├── BrowserAgent.md
│   └── ... (14 total)
├── hooks/                       # 20 TypeScript hook files
│   ├── SecurityValidator.hook.ts
│   ├── LoadContext.hook.ts
│   ├── RatingCapture.hook.ts
│   ├── SessionAutoName.hook.ts
│   ├── ... (20 total)
│   ├── handlers/                # 6 handler scripts
│   └── lib/                     # 13 shared hook utilities
├── skills/                      # 11 skill category directories
│   ├── Agents/
│   ├── ContentAnalysis/
│   ├── Investigation/
│   ├── Media/
│   ├── Research/
│   ├── Scraping/
│   ├── Security/
│   ├── Telos/
│   ├── Thinking/
│   ├── USMetrics/
│   └── Utilities/
├── lib/                         # Shared libraries
│   └── migration/               # 5 migration TypeScript files
├── VoiceServer/                 # ElevenLabs voice server
│   ├── server.ts
│   ├── install.sh, start.sh, stop.sh
│   └── menubar/                 # macOS menu bar app
└── Plans/                       # Created by installer (empty)
```

Additional paths created:

```
~/.config/PAI/.env               # API keys (mode 0600)
~/.claude/.env  →  ~/.config/PAI/.env   # Symlink
~/.env          →  ~/.config/PAI/.env   # Symlink
```

Shell modifications:
- Adds `alias pai='bun ~/.claude/PAI/Tools/pai.ts'` to `.zshrc`
- Sets `chmod -R 755 ~/.claude/`

### TELOS File Details

Location: `~/.claude/PAI/USER/TELOS/`

At install time: only `README.md` placeholder exists. User creates the 10 files manually.

**Loading behavior**: TELOS files are NOT automatically loaded at session start. They are NOT listed in `settings.json`'s `loadAtStartup.files`. The `/telos` skill reads and updates them on demand.

Exception: `PROJECTS.md` IS loaded at startup (listed in `loadAtStartup.files` as `PAI/USER/PROJECTS/PROJECTS.md`).

### CLAUDE.md Generation

PAI generates CLAUDE.md dynamically on every session start:

1. SessionStart hook runs `bun ${PAI_DIR}/hooks/handlers/BuildCLAUDE.ts`
2. Reads `~/.claude/CLAUDE.md.template`
3. Reads `settings.json` for identity values
4. Reads `PAI/Algorithm/LATEST` for algorithm version
5. Replaces placeholders (`{DAIDENTITY.NAME}`, `{PRINCIPAL.NAME}`, `{{PAI_VERSION}}`)
6. Writes result to `~/.claude/CLAUDE.md` (only if content changed)

This means CLAUDE.md is overwritten every session start, even if manually edited.

### settings.json Structure

PAI's settings.json is the "single source of truth for all PAI configuration." Contains fields that do not exist in standard Claude Code settings:

- `daidentity` (AI identity config)
- `principal` (user identity config)
- `pai` (PAI version, algorithm version)
- `notifications` (ntfy, Discord, Twilio config)
- `counts` (session counters)
- `loadAtStartup` (files and directories to load)
- `dynamicContext` (conditional context loading)
- `techStack` (preferred technologies)
- `contextDisplay` (display preferences)

Also overrides permissions to allow almost everything by default.

### Hook Lifecycle Coverage

PAI registers hooks across all Claude Code lifecycle events:

- `PreToolUse` (7 matchers: Bash, Edit, Write, Read, AskUserQuestion, Task, Skill)
- `PostToolUse` (2 matchers: AskUserQuestion, Write/Edit)
- `SessionStart` (3 hooks: KittyEnvPersist, LoadContext, BuildCLAUDE)
- `SessionEnd` (5 hooks: WorkCompletionLearning, SessionCleanup, RelationshipMemory, UpdateCounts, IntegrityCheck)
- `UserPromptSubmit` (3 hooks: RatingCapture, UpdateTabTitle, SessionAutoName)
- `Stop` (4 hooks: LastResponseCache, ResponseTabReset, VoiceCompletion, DocIntegrity)

### Rules System

PAI does NOT use `~/.claude/rules/`. Instead:
- `PAI/AISTEERINGRULES.md` (system-level rules, loaded at startup)
- `PAI/USER/AISTEERINGRULES.md` (user overrides, loaded at startup)
- Injected via `LoadContext.hook.ts` as `<system-reminder>` blocks

### Upgrade Mechanism

1. User backs up: `cp -r ~/.claude ~/.claude-backup-$(date +%Y%m%d)`
2. Copies new release: `cp -r .claude ~/` (overwrites system files)
3. Runs `bash install.sh` (detects existing installation)
4. `settings.json` is **merged** (preserves `principal`, `daidentity`, `apiKeys`)
5. User content (`PAI/USER/`) preserved (cp -r merges, doesn't delete)
6. `BuildCLAUDE.ts` regenerates CLAUDE.md from new template

The initial `cp -r` BEFORE the installer overwrites system files. Only settings.json gets merge treatment during the installer phase.

---

## 12. Compatibility and Conflict Analysis

### Conflict Matrix

| Path | What exists now | What PAI does | Conflict level |
|------|----------------|---------------|----------------|
| `~/.claude/settings.json` | Symlink to repo | Overwrites with incompatible structure | **DESTRUCTIVE** |
| `~/.claude/skills/` | Symlink to repo | Replaces symlink with dir (11 categories) | **DESTRUCTIVE** |
| `~/.claude/hooks/` | Symlink to repo | Replaces symlink with 20+ TS files | **DESTRUCTIVE** |
| `~/.claude/agents/` | Symlink to repo | Replaces symlink with 14 agent files | **DESTRUCTIVE** |
| `~/.claude/CLAUDE.md` | Symlink to repo | Regenerated from template every session | **DESTRUCTIVE** |
| `~/.claude/rules/` | Symlink to repo | PAI doesn't create rules/ | **SAFE** |
| `~/.claude/plugins/` | claude-mem plugin | PAI doesn't touch plugins/ | **SAFE** |
| `~/.claude/projects/` | Project memories | PAI doesn't touch projects/ | **SAFE** |

### Root Cause of Conflicts

PAI is designed as a **complete takeover** of `~/.claude/`. It is not designed to coexist with existing customizations. The `cp -r .claude ~/` installation is a blunt copy that overwrites matching files and replaces symlinks with regular files.

### What Survives Without Intervention

- `rules/` directory (PAI doesn't use it)
- `plugins/` directory (PAI doesn't touch it)
- `projects/` directory (PAI doesn't touch it)
- `claude-mem` database at `~/.claude-mem/` (outside `~/.claude/`)

### What Gets Destroyed

- `settings.json` (overwritten, incompatible structure)
- `skills/` symlink (replaced with PAI's skill categories)
- `hooks/` symlink (replaced with PAI's 20 TypeScript hooks)
- `agents/` symlink (replaced with PAI's 14 agents)
- `CLAUDE.md` (overwritten initially, then regenerated every session)

### Coexistence Requirements

Running both PAI and the current setup would require:
- Custom installation that maps PAI components to non-conflicting paths
- Manual settings.json merge
- Resolution of competing CLAUDE.md generation
- None of this is supported by PAI's installer

---

## 13. Decisions Made

| Decision | Rationale |
|----------|-----------|
| **MeisnerDan/mission-control** selected | Best PM philosophy (Eisenhower Matrix, goal hierarchy), solo entrepreneur focus, autonomous backlog execution, slash commands inside Claude Code |
| **Evaluate PAI side-by-side** (Option C) | LifeOS is top priority; need to assess TELOS value before committing |
| **All tools work with Max subscription** | No API keys needed; all wrap Claude Code CLI |

---

## 14. Open Questions

1. **PAI coexistence strategy**: Given the destructive conflict analysis, what is the actual path forward? Options identified:
   - Option 1: Go full PAI, abandon current structure
   - Option 2: Cherry-pick TELOS only (add identity files to rules/)
   - Option 3: Fork PAI and adapt components into current architecture

2. **MeisnerDan MC + PAI integration**: If both are adopted, do they interact with each other or operate independently?

3. **Notifications and voice**: If PAI is not adopted wholesale, how to get notifications (ntfy/Discord) and voice (ElevenLabs TTS) independently?

4. **The "missing something" feeling**: User expressed feeling something was being missed in the analysis. This document captures all research for continued discussion.
