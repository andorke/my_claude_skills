---
description: Install base skill set into the current project from ~/.claude/project-kit.json
---

Install the standard skill set into the current project's `.claude/skills/` directory, verify the Superpowers plugin is available, and write OpenSpec + Superpowers composition rules to the project's `CLAUDE.md`.

Read the manifest at `~/.claude/project-kit.json` to get the list of skills to install.

## Steps

### 1. Check prerequisites
- Verify the current directory has a `.claude/` folder (create if missing)
- Verify `.claude/skills/` exists (create if missing)
- Read `~/.claude/project-kit.json` for the skill list

### 2. Verify Superpowers plugin is installed globally
Superpowers is distributed as a Claude Code plugin and lives at user scope, not per-project. Check that it is present before continuing:

- Read `~/.claude/plugins/installed_plugins.json`
- Look for a key matching `superpowers@*` (e.g. `superpowers@claude-plugins-official`)
- If found — report version and continue
- If missing — stop and tell the user to run `/plugin install obra/superpowers` (or the marketplace equivalent) before re-running `/setup-project`

Do **not** vendor Superpowers files into the project. It is global by design.

### 3. Install tessl-managed skills
For each entry in `"tessl"` array:
- Run `tessl install <name>` via the tessl MCP tool
- If already installed, check if an update is available via `tessl outdated` and offer to update
- Report success/failure for each

### 4. Copy local skills
For each entry in `"copy"` array:
- Check if `~/.claude/skills/<name>/` exists as source
- Check if `.claude/skills/<name>/` already exists in the project
- If it exists, ask the user whether to overwrite
- If not, copy the entire skill directory: `cp -r ~/.claude/skills/<name>/ .claude/skills/<name>/`
- Report success/failure for each

### 5. Write OpenSpec + Superpowers composition rules to project CLAUDE.md

The goal: every project should have an explicit rule block that tells the agent how OpenSpec and Superpowers are expected to cooperate. Without this block, Superpowers TDD / code-review / verification skills do **not** auto-activate inside `/opsx:apply`, which is the single most common failure mode of the pair.

Target file: `<project>/CLAUDE.md` (create if missing).

Behavior:
- If `CLAUDE.md` does not exist — create it with the block below as its only content.
- If `CLAUDE.md` exists and already contains the managed marker `<!-- BEGIN openspec-superpowers-composition -->` — replace the block between `BEGIN` and `END` markers in place. Preserve all other content.
- If `CLAUDE.md` exists but has no marker — append the block at the end with a blank line separator. Do not touch existing content.

Block to write (verbatim, including markers):

```markdown
<!-- BEGIN openspec-superpowers-composition -->
## Project workflow: OpenSpec + Superpowers

This project uses OpenSpec for persistent planning and Superpowers for execution methodology. They are independent systems; these rules explicitly compose them.

### Roles
- **OpenSpec** owns persistent planning: `proposal.md`, `design.md`, `tasks.md`, and `archive/`. Source of truth for WHAT we build and WHY.
- **Superpowers** owns execution methodology: TDD, systematic debugging, code review, git worktrees, subagent dispatch. Source of truth for HOW we build.

### Per-feature flow
1. `brainstorming` (Superpowers) — clarify the idea in chat. No persistent file.
2. `/opsx:propose <name>` — OpenSpec generates `proposal.md`, `design.md`, `tasks.md`. Review and edit by hand before proceeding.
3. `/opsx:apply <name>` — implement tasks. During apply, the rules below are mandatory.
4. Final code review (Superpowers `requesting-code-review`) on the full change.
5. `/opsx:archive <name>` — only after all tests pass and the code review is resolved.

### Mandatory rules during /opsx:apply
1. Each task in `tasks.md` is implemented via **test-driven-development**: RED (failing test) → GREEN (minimal code) → REFACTOR. No code without a failing test first.
2. Before flipping `- [ ]` → `- [x]` on a task, run **verification-before-completion** as an internal sanity check.
3. Use **systematic-debugging** when a test fails for a non-obvious reason. Do not guess.
4. For independent sub-tasks that can run in parallel, use **dispatching-parallel-agents**.
5. Use **using-git-worktrees** for isolated branches when a change touches many files or risks conflicting edits.
6. Before `/opsx:archive`, mandatory **requesting-code-review** on the full change.

### Boundaries (what NOT to do)
- Do **not** use Superpowers `writing-plans` when an OpenSpec change is active. `tasks.md` is the authoritative plan.
- Do **not** run Superpowers `brainstorming` during `/opsx:apply`. Brainstorming is a pre-propose phase only.
- Do **not** create parallel planning docs inside `openspec/changes/<name>/`. OpenSpec artifacts are the single source of truth for the plan.
- Do **not** run `/opsx:archive` if any task in `tasks.md` is unchecked, tests are failing, or the code review is unresolved.
- Do **not** use OpenSpec for tasks under ~30 minutes of work. For trivial fixes, use Superpowers directly without a change.

### Version drift note
Superpowers ≥ v5 has started adding its own spec/plan generation skills. These overlap with OpenSpec. If you upgrade Superpowers and observe duplicated planning artifacts, re-read this block and disable the overlapping Superpowers skill for this project.
<!-- END openspec-superpowers-composition -->
```

### 6. Summary
Print a table showing:
- Skill name
- Type (tessl / copy / plugin-check / rules-block)
- Status (installed / updated / skipped / failed / written)

Also print the path to the project `CLAUDE.md` and whether the composition block was created, updated in place, or appended.

## Flags

- `--dry-run` — show what would be installed or written, without making changes
- `--tessl-only` — only install tessl-managed skills (skip copy + rules block)
- `--copy-only` — only copy local skills (skip tessl + rules block)
- `--rules-only` — only write the OpenSpec + Superpowers composition rules block to `CLAUDE.md`, skip all skill installation
