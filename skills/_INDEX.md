# Skills Index

Master catalog of all installed skills in `~/.claude/skills/`.

---

## Design & UI (6 skills)

| Skill | Description | Use when |
|-------|-------------|----------|
| `ui-ux-pro-max` | UI/UX design intelligence: 50+ styles, 161 color palettes, 57 font pairings, 99 UX guidelines across 10 stacks (React, Next.js, Vue, Svelte, SwiftUI, React Native, Flutter, Tailwind, shadcn/ui, HTML/CSS) | Planning, building, reviewing, or improving any UI/UX code |
| `ui-styling` | Accessible UI with shadcn/ui (Radix UI + Tailwind), responsive layouts, dark mode, canvas-based visual designs | Building interfaces, implementing design systems, adding accessible components |
| `design` | Comprehensive: brand identity, design tokens, logo generation (55 styles), CIP (50 deliverables), HTML presentations, banner design (22 styles), icon design (15 styles), social photos | Creating logos, CIP, mockups, banners, icons, social media images |
| `design-system` | Three-layer token architecture (primitive/semantic/component), CSS variables, spacing/typography scales, component specs | Setting up design tokens, systematic design, brand-compliant presentations |
| `brand` | Brand voice, visual identity, messaging frameworks, asset management, brand consistency | Branded content, tone of voice, marketing assets, style guides |
| `banner-design` | Banners for social media, ads, website heroes, print. 22+ styles (minimalist, gradient, glassmorphism, neon, etc.) | Creating banners for Facebook, Twitter/X, LinkedIn, YouTube, Instagram, Google Ads, print |

## Workflow & Spec (4 skills)

| Skill | Description | Use when |
|-------|-------------|----------|
| `openspec-propose` | Propose a new change with design, specs, and tasks in one step | Quickly describing what to build and getting a complete proposal |
| `openspec-apply-change` | Implement tasks from an OpenSpec change | Starting or continuing implementation of a spec change |
| `openspec-explore` | Thinking partner for exploring ideas, investigating problems, clarifying requirements | Brainstorming before or during a change |
| `openspec-archive-change` | Archive a completed change | Finalizing and archiving after implementation is complete |

## Presentations (2 skills)

| Skill | Description | Use when |
|-------|-------------|----------|
| `slides` | Strategic HTML presentations with Chart.js, design tokens, responsive layouts, copywriting formulas | Creating HTML slide decks with data visualizations |
| `pptx` | Full .pptx support: create, read, parse, edit, combine, split slide decks | Any task involving .pptx files — decks, pitch presentations, speaker notes |

## Project Setup (2 skills)

| Skill | Description | Use when |
|-------|-------------|----------|
| `sdx-project-kickoff` | Initialize spec-driven project from concept doc: repo structure, OpenSpec config, tech stack scaffolding, testing | Starting a new project, bootstrapping a codebase from design docs |
| `sdx-commit` | Analyze git diff, group by logical change, create conventional commits for each group | Organizing staged changes into atomic, structured commits |

## Architecture & Workflow (2 skills)

| Skill | Description | Use when |
|-------|-------------|----------|
| `claude-architect-guidelines` | Claude Certified Architect best practices: agent architecture, tool design, MCP integration, prompt engineering, context management | Designing agents, configuring Claude Code, writing prompts, making architectural decisions |
| `repo-task-proof-loop` | Repo-local workflow for large tasks: spec-freeze, build, evidence, verify, fix loop with fresh-session verification | Large coding tasks requiring structured multi-step workflow with subagents |

## Visualization (1 skill)

| Skill | Description | Use when |
|-------|-------------|----------|
| `visual-explainer` | Self-contained HTML pages: diagrams, architecture overviews, diff reviews, plan reviews, comparison tables | Explaining systems visually, rendering complex tables, architecture diagrams |

## People & Interviews (2 skills)

| Skill | Description | Use when |
|-------|-------------|----------|
| `compile-human` | Deep behavioral interview → installable AI agent plugin that embodies the person | Compiling a human into an AI agent plugin |
| `HumanCompiler` | HumanCompiler project (TypeScript/Bun) — tooling and scripts for the compile-human workflow | Working with the HumanCompiler codebase directly |

---

**Total: 21 skills across 7 categories**

Commands:
- `/skills` — recommendations for current project
- `/skills [category]` — browse category (e.g., `/skills design`)
- `/skills [term]` — search (e.g., `/skills openspec`)
- `/skills list` — show all categories
