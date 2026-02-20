#!/usr/bin/env bash
# Setup script: symlinks repo customization directories into ~/.claude/
# and generates settings.json from template with correct paths.
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

generate_settings() {
    local template="$REPO_DIR/settings.json.template"
    local output="$REPO_DIR/settings.json"

    if [ ! -f "$template" ]; then
        echo "  SKIP  settings.json (template not found)"
        return
    fi

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

    sed -e "s|__HOME__|$HOME|g" -e "s|__OTHER_HOME__|$other_home|g" "$template" > "$output"
    echo "  DONE  settings.json (generated from template)"
    echo "        HOME=$HOME  OTHER_HOME=$other_home"
}

echo "Linking customizations from: $REPO_DIR"
echo "Into: $CLAUDE_DIR"
echo

mkdir -p "$CLAUDE_DIR"

# Generate settings.json from template
generate_settings

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
