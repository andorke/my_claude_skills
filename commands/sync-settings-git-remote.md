---
description: "Sync Claude Code config (~/.claude/) to GitHub. Use proactively after any session where tracked files were modified — settings.json, CLAUDE.md, statusline.sh, or anything in commands/, skills/, agents/."
---
Sync the Claude Code configuration directory (`~/.claude/`) with its remote git repository.

## Steps

1. Run `git -C ~/.claude status --short` to check for changes in tracked files.

2. If there are no changes — tell the user everything is up to date and stop.

3. If there are changes:
   - Run `git -C ~/.claude diff` to understand what changed.
   - Stage all changes: `git -C ~/.claude add -A`
   - Generate a concise commit message in English summarizing what changed (e.g. "Update settings.json: add new statusline config" or "Add new skill: my-skill").
   - Commit and push:
     ```
     git -C ~/.claude commit -m "<message>"
     git -C ~/.claude push origin main
     ```
   - Confirm to the user what was synced.

## Rules

- The `.gitignore` controls what gets tracked. Do NOT manually exclude files — trust the `.gitignore`.
- Do NOT commit `settings.local.json` (it's already in `.gitignore`).
- Keep commit messages short and descriptive — focus on what changed, not why.
- If push fails (e.g. remote is ahead), run `git -C ~/.claude pull --rebase origin main` first, then push again.

$@
