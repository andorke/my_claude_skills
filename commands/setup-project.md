---
description: Install base skill set into the current project from ~/.claude/project-kit.json
---

Install the standard skill set into the current project's `.claude/skills/` directory.

Read the manifest at `~/.claude/project-kit.json` to get the list of skills to install.

## Steps

### 1. Check prerequisites
- Verify the current directory has a `.claude/` folder (create if missing)
- Verify `.claude/skills/` exists (create if missing)
- Read `~/.claude/project-kit.json` for the skill list

### 2. Install tessl-managed skills
For each entry in `"tessl"` array:
- Run `tessl install <name>` via the tessl MCP tool
- If already installed, check if an update is available via `tessl outdated` and offer to update
- Report success/failure for each

### 3. Copy local skills
For each entry in `"copy"` array:
- Check if `~/.claude/skills/<name>/` exists as source
- Check if `.claude/skills/<name>/` already exists in the project
- If it exists, ask the user whether to overwrite
- If not, copy the entire skill directory: `cp -r ~/.claude/skills/<name>/ .claude/skills/<name>/`
- Report success/failure for each

### 4. Summary
Print a table showing:
- Skill name
- Type (tessl / copy)
- Status (installed / updated / skipped / failed)

If `$1` is `--dry-run`, only show what would be installed without making changes.
If `$1` is `--tessl-only`, only install tessl-managed skills.
If `$1` is `--copy-only`, only copy local skills.
