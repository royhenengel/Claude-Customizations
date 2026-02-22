---
date: 2026-02-22
feature: git-worktrees, my-workflow
severity: major
status: resolved
---

# Incident: Claude Code Nested Session Error in Worktrees

## Summary

Opening a new VS Code window from within a Claude Code session (for worktrees or new projects) triggers a nested session guard error, preventing Claude Code from starting in the new window. Root cause: inherited `CLAUDECODE` environment variable from the parent process.

## What Happened

When opening worktrees (e.g., `rule-distilation-agent`) in new VS Code windows, two errors occur:

1. "Error: Claude Code process exited with code 1"
2. "Error: Claude Code cannot be launched inside another Claude Code session. Nested sessions share runtime resources and will crash all active sessions."

This affected both the git-worktrees skill and the /start workflow, which launch VS Code via shell commands that inherit the parent environment.

## Root Cause

Five Whys analysis:

- Why 1: Claude Code refuses to start in the new window -> Because it detects `CLAUDECODE=1` in the environment
- Why 2: `CLAUDECODE=1` is present in the new window -> Because the new VS Code process inherits it from the parent
- Why 3: The `code --new-window` command runs as a child of the current session -> Because the skills launch VS Code directly without clearing Claude-specific env vars

**Root Cause:** The git-worktrees skill and /start workflow launch VS Code as a child process via the Bash tool. Child processes inherit environment variables, including `CLAUDECODE=1` set by the parent Claude Code session. The Claude Code extension in the new window sees this variable and blocks startup.

## Impact

- Worktree-based development workflow broken when launched from within Claude Code
- Users must manually restart VS Code or unset the env var to recover
- Affects any skill or command that opens a new VS Code window from within a session

## Affected Artifacts

| File/Component | Impact |
|---|---|
| `skills/Git/git-worktrees/SKILL.md` (line 93) | VS Code launch command inherits `CLAUDECODE` env var |
| `skills/Planning/my-workflow/workflows/start.md` (line 172) | VS Code launch command inherits `CLAUDECODE` env var |

## Resolution

Fixed in both files by prefixing the VS Code launch command with `env -u CLAUDECODE` to strip the environment variable from the spawned process only.

Before:
```bash
"/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" --new-window "$worktree_path" ...
```

After:
```bash
env -u CLAUDECODE "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" --new-window "$worktree_path" ...
```

## Prevention

- When launching external processes from within Claude Code sessions, always consider inherited environment variables
- Any future skill that opens VS Code windows should include `env -u CLAUDECODE` in the launch command

## Lessons Learned

- Claude Code sets `CLAUDECODE=1` as a session guard, which is reasonable for preventing actual nested sessions
- The guard doesn't distinguish between "nested session in same window" and "independent session in new window launched from a parent"
- Skills that spawn independent processes need to sanitize the environment to avoid inheriting session-specific state
