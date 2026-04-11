---
description: Install base skill set into the current project from ~/.claude/project-kit.json
---

Install the standard skill set into the current project's `.claude/skills/` directory, verify the Superpowers plugin is available, write OpenSpec + Superpowers composition rules to `AGENTS.md`, and scaffold the core project docs (`AGENTS.md`, `CONTEXT.md`, `DEVELOPMENT.md`, `ROADMAP.md`, `ARCHITECTURE.md`).

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

### 5. Write OpenSpec + Superpowers composition rules to project AGENTS.md

The goal: every project should have an explicit rule block that tells the agent how OpenSpec and Superpowers are expected to cooperate, and how the core project docs are maintained. Without this block, Superpowers TDD / code-review / verification skills do **not** auto-activate inside `/opsx:apply`, which is the single most common failure mode of the pair.

**Target file:** `<project>/AGENTS.md` (create if missing).

**Why AGENTS.md and not CLAUDE.md:** `AGENTS.md` is the cross-agent convention used by OpenSpec and Superpowers. Claude Code still auto-loads `CLAUDE.md`, so we also write a thin proxy `CLAUDE.md` that points to `AGENTS.md` (see Step 6).

**Behavior for AGENTS.md:**
- If `AGENTS.md` does not exist — create it using the full template below (header + managed block).
- If `AGENTS.md` exists and contains the managed marker `<!-- BEGIN openspec-superpowers-composition -->` — replace the block between `BEGIN` and `END` markers in place. Preserve all other content.
- If `AGENTS.md` exists but has no marker — append the managed block at the end with a blank line separator. Do not touch existing content.

**Managed block to write (verbatim, including markers):**

```markdown
<!-- BEGIN openspec-superpowers-composition -->
## Project workflow: OpenSpec + Superpowers

This project uses OpenSpec for persistent planning and Superpowers for execution methodology. They are independent systems; these rules explicitly compose them.

### Reading order for new agents
Read these files in order before doing anything else:
1. `AGENTS.md` — this file. Entry point, rules, glossary.
2. `DEVELOPMENT.md` — tech stack, repo structure, coding patterns, local run.
3. `CONTEXT.md` — current status, recent decisions, "what's done" log.
4. `ROADMAP.md` — phases and milestones.
5. `ARCHITECTURE.md` — C4 diagrams, API contracts, key architectural decisions.

### Roles
- **OpenSpec** owns persistent planning for individual changes: `proposal.md`, `design.md`, `tasks.md`, and `archive/`. Source of truth for WHAT we build and WHY at the change level.
- **Superpowers** owns execution methodology: TDD, systematic debugging, code review, git worktrees, subagent dispatch. Source of truth for HOW we build.
- **Project docs** (`AGENTS.md`, `CONTEXT.md`, `DEVELOPMENT.md`, `ROADMAP.md`, `ARCHITECTURE.md`) own global, long-lived project context. OpenSpec operates at change scope, these files operate at project scope.

### Per-feature flow
1. `brainstorming` (Superpowers) — clarify the idea in chat. No persistent file.
2. `/opsx:propose <name>` — OpenSpec generates `proposal.md`, `design.md`, `tasks.md`. Review and edit by hand before proceeding.
3. `/opsx:apply <name>` — implement tasks. During apply, the rules below are mandatory.
4. Final code review (Superpowers `requesting-code-review`) on the full change.
5. `/opsx:archive <name>` — only after all tests pass and the code review is resolved.
6. After archive — update `CONTEXT.md` ("what's done" log) and flip the matching checkbox in `ROADMAP.md` if the change closed a planned item.

### Mandatory rules during /opsx:apply
1. Each task in `tasks.md` is implemented via **test-driven-development**: RED (failing test) → GREEN (minimal code) → REFACTOR. No code without a failing test first.
2. Before flipping `- [ ]` → `- [x]` on a task, run **verification-before-completion** as an internal sanity check.
3. Use **systematic-debugging** when a test fails for a non-obvious reason. Do not guess.
4. For independent sub-tasks that can run in parallel, use **dispatching-parallel-agents**.
5. Use **using-git-worktrees** for isolated branches when a change touches many files or risks conflicting edits.
6. Before `/opsx:archive`, mandatory **requesting-code-review** on the full change.

### Filling project docs with Superpowers
The five project docs are scaffolds with TODO sections when the project starts. Fill them iteratively — do not try to write 1000 lines on day one.

- Use Superpowers **`brainstorming`** to interrogate the user and extract the information needed for any section marked `TODO`. Ask one focused question at a time. Do not invent content.
- Use Superpowers **`writing-plans`** to turn a decided scope into `ROADMAP.md` phases. Keep phases coarse — sub-tasks live in OpenSpec changes, not in `ROADMAP.md`.
- Update `CONTEXT.md` after each significant decision or completed change. This file is a log, not a spec — append, do not rewrite.
- Update `ARCHITECTURE.md` only when a decision is made. Keep it factual, not aspirational. C4 diagrams optional early; start with a prose description of components and boundaries.
- `DEVELOPMENT.md` is locked in once per tech-stack choice. Update it when the stack, structure, or coding patterns change, not per-feature.

### Boundaries (what NOT to do)
- Do **not** use Superpowers `writing-plans` for feature-level planning when an OpenSpec change is active. `tasks.md` is the authoritative per-feature plan. `writing-plans` is only for `ROADMAP.md` high-level phases.
- Do **not** run Superpowers `brainstorming` during `/opsx:apply`. Brainstorming is a pre-propose phase only.
- Do **not** create parallel planning docs inside `openspec/changes/<name>/`. OpenSpec artifacts are the single source of truth for the plan.
- Do **not** run `/opsx:archive` if any task in `tasks.md` is unchecked, tests are failing, or the code review is unresolved.
- Do **not** use OpenSpec for tasks under ~30 minutes of work. For trivial fixes, use Superpowers directly without a change.
- Do **not** duplicate content across `AGENTS.md` / `CONTEXT.md` / `ARCHITECTURE.md`. Each file owns its scope; cross-link instead of copying.

### Version drift note
Superpowers ≥ v5 has started adding its own spec/plan generation skills. These overlap with OpenSpec. If you upgrade Superpowers and observe duplicated planning artifacts, re-read this block and disable the overlapping Superpowers skill for this project.
<!-- END openspec-superpowers-composition -->
```

**AGENTS.md header (written only when the file is being newly created — do not overwrite an existing header):**

```markdown
# {{PROJECT_NAME}}

> Entry point for coding agents. Read this file first.

## What this project is
TODO — one paragraph: what the project does, who it is for, what stage it is in.

## Reading order
1. `AGENTS.md` (this file)
2. `DEVELOPMENT.md`
3. `CONTEXT.md`
4. `ROADMAP.md`
5. `ARCHITECTURE.md`

## Glossary
TODO — domain terms that a new agent would not know.

```

Replace `{{PROJECT_NAME}}` with the current directory's basename.

### 6. Scaffold core project docs

Create the remaining four files **only if they do not already exist**. Never overwrite existing content — if a file is already present, skip it and report "skipped (exists)".

Each file is a short scaffold with clearly-labelled `TODO` sections. It is **not** supposed to be comprehensive at creation time. Superpowers `brainstorming` and `writing-plans` fill these in iteratively as the project evolves.

**Also write a thin proxy `CLAUDE.md`** at the project root so Claude Code's auto-load still finds the rules. If `CLAUDE.md` already exists, leave it untouched and only report.

#### CLAUDE.md (proxy, only if missing)

```markdown
# Project rules live in AGENTS.md

See `./AGENTS.md` for the full agent entry point, reading order, and the OpenSpec + Superpowers composition rules.
```

#### DEVELOPMENT.md (only if missing)

```markdown
# Development rules

> Read this before writing code.

## Tech stack
TODO — language versions, frameworks, databases, key libraries.

## Repository structure
TODO — directory tree with 1-line descriptions per top-level folder.

## Local run
TODO — commands to install, build, test, run. Include ports, env vars, docker-compose if any.

## Coding patterns
TODO — architectural style (e.g. Clean Architecture, hexagonal, MVC), dependency rules, naming conventions, error handling.

## Testing strategy
TODO — unit / integration / e2e split, tools, coverage target, where tests live.

## Style and tooling
TODO — linter, formatter, pre-commit hooks, commit message convention.
```

#### CONTEXT.md (only if missing)

```markdown
# Project context

## Current status
- **Phase:** TODO
- **Last updated:** {{TODAY}}

## What is done
| Date | What was done |
|------|---------------|
| {{TODAY}} | Project scaffolded via /setup-project |

> Append new rows at the top. Do not rewrite history.

## Current task
TODO — one sentence.

## Key decisions
| Decision | Choice | Reasoning |
|----------|--------|-----------|
| TODO     | TODO   | TODO      |

## Risks
| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| TODO | TODO        | TODO   | TODO       |

## Next steps
- [ ] TODO
```

Replace `{{TODAY}}` with the current date in `YYYY-MM-DD` format.

#### ROADMAP.md (only if missing)

```markdown
# Roadmap

> High-level phases. Sub-tasks live in OpenSpec changes, not here.

## Phases overview
| Phase | Name | Status |
|-------|------|--------|
| 0 | Project setup | ⏳ In progress |
| 1 | TODO | ⏸️ Pending |
| 2 | TODO | ⏸️ Pending |

## Phase 0: Project setup
- [x] Repository initialized
- [x] Docs scaffolded
- [ ] Tech stack chosen and DEVELOPMENT.md filled in
- [ ] First feature scoped via /opsx:propose

## Phase 1: TODO
- [ ] TODO
```

#### ARCHITECTURE.md (only if missing)

```markdown
# Architecture

> Global, long-lived architectural decisions. Per-change design lives in `openspec/changes/<name>/design.md`.

## System overview
TODO — one paragraph describing the system, its main components, and their boundaries.

## Components
TODO — list each component with a one-line description of its responsibility.

## Key interfaces
TODO — public APIs, message contracts, integration points with external systems.

## Data model
TODO — main entities and their relationships. Link to a detailed data model doc if it grows large.

## Key decisions
| Decision | Choice | Reasoning |
|----------|--------|-----------|
| TODO     | TODO   | TODO      |

## C4 diagrams
TODO — Level 1 (System Context), Level 2 (Containers), Level 3 (Components). Mermaid or image. Optional until the system has at least two components.
```

### 7. Summary
Print a table showing:

| Item | Type | Status |
|------|------|--------|
| superpowers plugin | plugin-check | installed / missing |
| `<skill-name>` | tessl / copy | installed / updated / skipped / failed |
| AGENTS.md composition block | rules-block | created / updated / appended |
| CLAUDE.md proxy | proxy-file | created / skipped (exists) |
| DEVELOPMENT.md | scaffold | created / skipped (exists) |
| CONTEXT.md | scaffold | created / skipped (exists) |
| ROADMAP.md | scaffold | created / skipped (exists) |
| ARCHITECTURE.md | scaffold | created / skipped (exists) |

Close with a one-line next step: `Run /opsx:explore or start a brainstorming session to fill in the TODO sections.`

## Flags

- `--dry-run` — show what would be installed or written, without making changes
- `--tessl-only` — only install tessl-managed skills (skip copy + rules block + scaffolds)
- `--copy-only` — only copy local skills (skip tessl + rules block + scaffolds)
- `--rules-only` — only write the OpenSpec + Superpowers composition rules block to `AGENTS.md`, skip skill installation and doc scaffolds
- `--docs-only` — only scaffold the five project docs (`AGENTS.md`, `CLAUDE.md` proxy, `DEVELOPMENT.md`, `CONTEXT.md`, `ROADMAP.md`, `ARCHITECTURE.md`), skip everything else
