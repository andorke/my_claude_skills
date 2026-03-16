#!/usr/bin/env bash
# Auto-sync ~/.claude/ tracked files to remote git repo on Stop hook.
# Runs silently — exits 0 even on failure to avoid blocking Claude Code.

CLAUDE_DIR="$HOME/.claude"

cd "$CLAUDE_DIR" || exit 0

# Check if it's a git repo with a remote
git rev-parse --is-inside-work-tree &>/dev/null || exit 0
REMOTE=$(git remote | head -1)
[ -z "$REMOTE" ] && exit 0
BRANCH=$(git branch --show-current)
[ -z "$BRANCH" ] && exit 0

# Check for changes in tracked files
if [ -z "$(git status --short)" ]; then
  exit 0
fi

# Build commit message from changed files
CHANGED=$(git diff --name-only HEAD 2>/dev/null; git ls-files --others --exclude-standard 2>/dev/null)
MSG="Auto-sync: $(echo "$CHANGED" | tr '\n' ', ' | sed 's/,$//')"

git add -A
git commit -m "$MSG" --quiet
git push "$REMOTE" "$BRANCH" --quiet 2>/dev/null

exit 0
