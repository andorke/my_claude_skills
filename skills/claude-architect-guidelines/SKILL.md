---
name: claude-architect-guidelines
description: "Claude Certified Architect best practices. Covers 5 domains: agent architecture & orchestration, tool design & MCP integration, Claude Code configuration & workflows, prompt engineering & structured output, context management & reliability. Activates when designing agents, configuring Claude Code, writing prompts, integrating MCP tools, or making architectural decisions for Claude-based systems."
---

# Claude Architect Guidelines

Practical guidelines extracted from Claude Certified Architect — Foundations. Apply these rules when designing, building, or reviewing Claude-based systems.

## When to Apply

- Designing or reviewing agent architectures
- Configuring Claude Code (CLAUDE.md, commands, skills, rules, MCP)
- Writing or reviewing prompts and structured output schemas
- Building multi-agent systems or tool integrations
- Making decisions about context management, error handling, escalation
- Integrating Claude Code into CI/CD pipelines
- Working with MCP servers and tools

---

## Domain 1: Agent Architecture & Orchestration

### Agent Loop

- Agent loop lifecycle: send request to Claude -> check `stop_reason` ("tool_use" or "end_turn") -> execute requested tools -> return results for next iteration.
- Always add tool results to conversation history so the model can reason about next action.
- **Anti-patterns to avoid:**
  - Parsing natural language to determine loop termination
  - Arbitrary iteration limits as primary stop mechanism
  - Checking assistant text as completion indicator

### Multi-Agent Orchestration

- Use "hub and spokes" architecture: coordinator agent manages all inter-agent communication, error handling, and information routing.
- Sub-agents operate with isolated context — they do NOT inherit coordinator's history automatically.
- Coordinator role: task decomposition, delegation, result aggregation, sub-agent selection based on query complexity.
- **Watch out:** overly narrow task decomposition by coordinator leads to incomplete coverage of broad topics.

### Sub-Agent Configuration

- Tool `Task` is the mechanism for spawning sub-agents; `allowedTools` must include "Task" for coordinator to call sub-agents.
- Sub-agent context is passed explicitly in the prompt — sub-agents don't inherit parent context or share memory between invocations.
- Include full results from previous agents directly in the sub-agent prompt.
- Use structured data formats to separate content and metadata when passing context between agents.
- Spawn parallel sub-agents: multiple Task calls in a single coordinator response.
- Design coordinator prompts that set research goals and quality criteria, NOT step-by-step procedural instructions.

### Workflow Control Patterns

- **Programmatic control** (hooks, preconditions) vs **prompt guidance** for sequencing workflows.
- When deterministic control is needed (identity verification before financial operations) — prompt instructions give non-zero error probability. Use programmatic preconditions.
- Structured handoff protocols for escalation: customer data, root cause analysis, recommended actions.
- Block downstream tool calls until prerequisite steps complete (e.g., block `process_refund` until `get_customer` confirms customer ID).

### Agent SDK Hooks

- `PostToolUse` hooks: intercept tool results for transformation before model processing.
- Hooks for intercepting outgoing tool calls for policy compliance (block refunds above threshold).
- **Rule:** Use hooks for deterministic guarantees, prompt instructions for probabilistic compliance.
- Use hooks to normalize heterogeneous data formats (Unix timestamps, ISO 8601, numeric status codes) from different MCP tools.

### Task Decomposition

- **Prompt chaining** (fixed sequential pipeline) vs **dynamic adaptive decomposition**.
- Prompt chaining for predictable multi-aspect reviews; dynamic decomposition for open-ended research.
- Split large code reviews into per-file passes + separate cross-file integration pass.
- Open-ended tasks: first map structure, identify priority areas, then create adaptive plan.

### Session Management

- `--resume <session-name>` to continue a specific conversation.
- `fork_session` for creating independent branches from shared analysis base.
- When resuming a session, inform the agent about changes in previously analyzed files.
- When to start a new session with structured summary instead of resuming with stale results.

---

## Domain 2: Tool Design & MCP Integration

### Tool Interface Design

- Tool descriptions are the PRIMARY mechanism by which LLM selects tools; minimal descriptions lead to unreliable selection among similar tools.
- Include in descriptions: input formats, example queries, edge cases, boundary clarifications.
- Ambiguous or overlapping descriptions cause routing errors.
- System prompt wording affects tool selection: keyword-sensitive instructions can create unintended associations.
- Rename tools and update descriptions to eliminate functional overlap.
- Split universal tools into specialized ones with defined I/O contracts.

### Structured Error Responses

- Use `isError` flag pattern to communicate failures to the agent.
- Distinguish: transient errors (timeouts), validation errors (bad input), business errors (policy violations), permission errors.
- Return structured error metadata: `errorCategory` (transient/validation/permission), `isRetryable`, human-readable description.
- Include `retriable: false` and explanations for business rule violations.
- Local recovery in sub-agents for transient errors; propagate only unresolvable errors to coordinator.
- Distinguish access failures (need retry decision) from valid empty results (successful query, no matches).

### Tool Distribution

- **Rule:** Too many tools (18 instead of 4-5) reduces selection reliability.
- Agents with tools outside their specialization tend to misuse them.
- Restrict each agent's toolset to only tools relevant to its role.
- `tool_choice`: "auto" (model may return text), "any" (model must call a tool), forced specific tool (`{"type": "tool", "name": "..."}`).

### MCP Server Configuration

- Project-level `.mcp.json` for shared team tools vs user-level `~/.claude.json` for personal/experimental servers.
- Environment variable substitution in `.mcp.json` (e.g., `${GITHUB_TOKEN}`) — never commit secrets.
- MCP resources as content catalogs (task summaries, doc hierarchies, DB schemas) to reduce exploratory tool calls.
- Prefer existing community MCP servers over custom implementations for standard integrations.

### Built-in Tool Selection

- **Grep** — search file contents (function names, error messages, imports).
- **Glob** — find files by path patterns (names, extensions).
- **Read/Write** — full file operations; **Edit** — targeted changes by unique text match.
- When Edit fails due to non-unique matches — use Read + Write as fallback.
- Incremental codebase exploration: start with Grep for entry points, then Read to trace imports and flows.

---

## Domain 3: Claude Code Configuration & Workflows

### CLAUDE.md Hierarchy

- User level: `~/.claude/CLAUDE.md` (personal, not version-controlled)
- Project level: `.claude/CLAUDE.md` or root `CLAUDE.md` (shared via VCS)
- Directory level: `CLAUDE.md` in subdirectories
- `@import` syntax for referencing external files and modularizing CLAUDE.md.
- `.claude/rules/` directory for organizing thematic rule files.
- Use `/memory` command to check loaded memory files and diagnose inconsistent behavior.

### Custom Commands & Skills

- Project commands in `.claude/commands/` (version-controlled, shared with team).
- User commands in `~/.claude/commands/` (personal).
- Skills in `.claude/skills/` with SKILL.md supporting frontmatter: `context: fork`, `allowed-tools`, `argument-hint`.
- Use `context: fork` to isolate skills with heavy output from main session.
- Use `allowed-tools` in skill frontmatter to restrict tool access.
- **Choose between:** skills (on-demand for specific tasks) vs CLAUDE.md (always-loaded universal standards).

### Path-Scoped Rules

- Files in `.claude/rules/` with YAML frontmatter `paths` for conditional activation by glob patterns.
- Path-scoped rules load only when editing matching files — reduces irrelevant context.
- Prefer glob patterns over subdirectory CLAUDE.md for conventions spanning files across directories.
- Example: `paths: ["**/*.test.tsx"]` for all test files regardless of location.

### Plan Mode vs Direct Execution

- **Plan mode** for complex tasks: large-scale changes, multiple valid approaches, multi-file modifications, architectural decisions.
- **Direct execution** for simple, well-defined tasks (single bug fix, adding one validation).
- Plan mode allows safe codebase exploration and solution design before committing changes.
- Use Explore sub-agent to isolate heavy research output with summaries returned to main context.
- **Combine:** plan mode for research, direct execution for implementation.

### Iterative Refinement

- Concrete input/output examples are the most effective way to convey expected transformations when text descriptions are ambiguous.
- Test-driven iteration: write tests first, then iterate by feeding failing tests.
- "Interview" pattern: Claude asks questions to uncover aspects the developer might not have considered.
- Related issues — send all in one message; independent issues — fix sequentially.

### CI/CD Integration

- `-p` (or `--print`) flag for non-interactive mode in automated pipelines.
- `--output-format json` and `--json-schema` for structured output in CI contexts.
- CLAUDE.md as mechanism for passing project context (testing standards, review criteria) to Claude Code in CI.
- **Context isolation:** the same Claude session that generated code is less effective at reviewing it. Use independent instances.
- Include previous review results in context when re-running after new commits.
- Document testing standards, criteria, and available fixtures in CLAUDE.md.

---

## Domain 4: Prompt Engineering & Structured Output

### Explicit Criteria

- Use explicit criteria instead of vague instructions (e.g., "flag comments only when stated behavior contradicts actual code" instead of "check that comments are accurate").
- Generic instructions like "be conservative" or "report only high-confidence findings" do NOT improve precision compared to specific categorical criteria.
- Frequent false positives in one category undermine trust in ALL categories.
- Temporarily disable high-false-positive categories to restore trust.

### Few-Shot Prompting

- Few-shot examples are the most effective technique for achieving consistently formatted, actionable output when detailed instructions give unstable results.
- Create 2-4 targeted examples for ambiguous scenarios with justification for choices.
- Include examples demonstrating specific output format (location, issue, severity, suggested fix).
- Examples for correct handling of different document structures (inline references, bibliographies, tables).
- Few-shot examples reduce hallucinations in extraction tasks.

### Structured Output via tool_use

- `tool_use` with JSON schemas is the most reliable approach for guaranteed structured output — eliminates JSON syntax errors.
- `tool_choice: "auto"` — model may return text; `"any"` — model must call a tool; forced specific tool — ensures execution order.
- Strict JSON schemas eliminate syntactic errors but NOT semantic errors (sums don't add up, values in wrong fields).
- Design schemas: required vs optional fields, enum fields with "other" + additional description for extensible categories.
- Add format normalization rules to prompts alongside strict output schemas.

### Validation & Retry Loops

- "Retry with error" pattern: add specific validation errors to prompt on retry.
- Retries are ineffective when information is absent from the document.
- Track which constructs trigger detections (`detected_pattern`) for false positive analysis.
- Design self-correction flows: extract `calculated_total` alongside `stated_total` for discrepancy detection.

### Batch Processing

- Message Batches API: 50% savings, up to 24h processing window, no latency SLA.
- Batch for non-blocking, latency-tolerant workloads (nightly reports, weekly audits).
- NOT for blocking processes (pre-merge checks).
- `custom_id` for request-response correlation in batches.
- Refine prompts on sample before mass batch processing.

### Multi-Pass Review

- Self-review limitation: model retains reasoning context from generation, reducing likelihood of challenging own decisions.
- Independent review instances (without prior reasoning context) catch subtle errors more effectively.
- Split large reviews: per-file local passes + cross-file integration passes to avoid attention dilution.
- Run verification passes where model indicates confidence level for each finding.

---

## Domain 5: Context Management & Reliability

### Preserving Critical Information

- Risks of progressive summarization: condensing numbers, percentages, dates into vague summaries.
- "Lost in the middle" effect: models reliably process information at beginning and end of long inputs, may miss data in the middle.
- Tool results accumulate in context and consume tokens disproportionate to their relevance.
- Extract transactional facts (amounts, dates, order numbers, statuses) into persistent "case facts" block outside summarizable history.
- Trim verbose tool outputs to only relevant fields before accumulating in context.
- Place key finding summaries at the BEGINNING of aggregated inputs with explicit section headers to mitigate positional effects.

### Escalation Design

- Triggers: customer requests human, policy exceptions/gaps, inability to make progress.
- Distinguish immediate escalation (customer explicitly requests) from attempting self-resolution (issue within agent competence).
- Sentiment-based assessments and confidence self-evaluations are UNRELIABLE indicators of actual case complexity.
- Multiple customer matches require requesting additional identifiers, NOT heuristic selection.
- Add explicit escalation criteria with few-shot examples to system prompt.

### Error Propagation in Multi-Agent Systems

- Structured error context (failure type, query, partial results, alternative approaches) is the foundation for intelligent coordinator recovery.
- Distinguish access failures (need retry decisions) from valid empty results (successful queries with no matches).
- Uniform error statuses ("search unavailable") hide valuable context from coordinator — anti-pattern.
- Silent error suppression (returning empty results as success) and full process termination on single failure — both anti-patterns.
- Return: failure type, what was attempted, partial results, potential alternatives.
- Coverage annotations in synthesized output: which conclusions are well-supported, where gaps exist due to unavailable sources.

### Large Codebase Exploration

- Context degradation in long sessions: model starts giving inconsistent answers, referencing "typical patterns" instead of specific classes.
- Scratchpad files for preserving key findings across context boundaries.
- Delegate to sub-agents for isolating heavy research output; main agent coordinates at high level.
- Structured state persistence for crash recovery: each agent exports state, coordinator loads manifest on resume.
- Use `/compact` to reduce context usage in long research sessions.
- Summarize key findings from research phase before spawning next-phase sub-agents with summary injection into initial context.

### Human-in-the-Loop Review

- Aggregated accuracy metrics (97%) can mask poor performance on specific document types or fields.
- Stratified random sampling to measure error rates in high-confidence extractions.
- Field-level confidence scores calibrated on labeled validation sets for review routing.
- Verify accuracy by document type and field before reducing human review.

### Information Provenance

- Attribution is lost during summarization without preserving "claim-source" mappings.
- Require sub-agents to output structured "claim-source" mappings (URLs, document names, relevant excerpts).
- Structure reports with explicit separation of well-supported and contested findings.
- Include publication/collection dates in structured outputs to prevent false contradictions.
- Annotate conflicts with source attribution instead of arbitrarily choosing one value.
