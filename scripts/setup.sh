#!/usr/bin/env bash
# Setup script: symlinks repo customization directories into ~/.claude/
# and configures git smudge/clean filters for portable settings.json paths.
# Safe to re-run — skips already-correct symlinks, warns on conflicts.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CLAUDE_DIR="$HOME/.claude"

# Known accounts (used for cross-account additionalDirectories)
ACCOUNTS=(/Users/royengel /Users/lifeos)

# Directories to symlink from this repo into ~/.claude/
DIRS=(skills agents hooks mcp rules)

link_item() {
    local src="$1" dest="$2" label="$3"

    if [ -L "$dest" ]; then
        current="$(readlink "$dest")"
        if [ "$current" = "$src" ]; then
            echo "  OK    $label (already linked)"
        else
            echo "  WARN  $label symlink exists but points to: $current"
            echo "        Expected: $src"
            echo "        Remove it manually and re-run to fix."
        fi
    elif [ -e "$dest" ]; then
        echo "  WARN  $label exists as a regular file/directory — skipping"
        echo "        Remove or move it manually, then re-run."
    else
        ln -s "$src" "$dest"
        echo "  DONE  $label → $src"
    fi
}

configure_settings_filter() {
    # Determine the other account's home directory
    local other_home=""
    for acct in "${ACCOUNTS[@]}"; do
        if [ "$acct" != "$HOME" ]; then
            other_home="$acct"
            break
        fi
    done

    if [ -z "$other_home" ]; then
        echo "  WARN  Could not determine other account home. Check ACCOUNTS list."
        echo "        Current HOME=$HOME not found in: ${ACCOUNTS[*]}"
        return 1
    fi

    # Configure git smudge/clean filters for settings.json
    # Smudge (checkout): __HOME__ → real paths
    # Clean (stage): real paths → __HOME__
    git -C "$REPO_DIR" config filter.settings.smudge \
        "sed 's|__HOME__|$HOME|g; s|__OTHER_HOME__|$other_home|g'"
    git -C "$REPO_DIR" config filter.settings.clean \
        "sed 's|$HOME|__HOME__|g; s|$other_home|__OTHER_HOME__|g'"

    echo "  DONE  git filters configured (smudge/clean)"
    echo "        HOME=$HOME  OTHER_HOME=$other_home"

    # Force re-checkout to apply smudge filter (expand placeholders on disk)
    (cd "$REPO_DIR" && rm -f settings.json && git checkout -- settings.json)
    echo "  DONE  settings.json expanded with local paths"
}

echo "Linking customizations from: $REPO_DIR"
echo "Into: $CLAUDE_DIR"
echo

mkdir -p "$CLAUDE_DIR"

# Configure smudge/clean filters and expand settings.json
configure_settings_filter

# Symlink settings.json into ~/.claude/
link_item "$REPO_DIR/settings.json" "$CLAUDE_DIR/settings.json" "settings.json"

# Symlink directories
for dir in "${DIRS[@]}"; do
    src="$REPO_DIR/$dir"
    if [ ! -d "$src" ]; then
        echo "  SKIP  $dir/ (not found in repo)"
        continue
    fi
    link_item "$src" "$CLAUDE_DIR/$dir" "$dir/"
done

echo
echo "Setup complete."
