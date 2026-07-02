# Memory Management Standards

Standards for managing Claude Code auto-memory (`~/.claude/projects/*/memory/`) for this project. The structure and thresholds are shared MPI machinery (canonical source: Optimus — see `docs/standards/cross-repo-sync.md`); the research basis (findings F5.1–F5.5) is documented in Optimus's `docs/research/ai-best-practices.md`.

## Auto-Memory vs Repo-Tracked Docs

Auto-memory and repo-tracked docs serve different purposes. The boundary is durability and scope.

**Rule: If it should survive across machines and agents, it belongs in the repo. If it's context from the current engagement that may change, it belongs in auto-memory.**

| Belongs in auto-memory | Belongs in repo (CLAUDE.md / .claude/rules/ / docs/) |
|---|---|
| User preferences learned in conversation | Coding standards, anti-patterns |
| Active project status (what's in progress now) | Workflow process definitions |
| Feedback corrections from HC | Standing instructions (e.g., HC working style) |
| References to external systems discovered in conversation | Architecture, patterns |
| Temporary debugging insights for active work | Conventions derivable from code |
| Issue/PR tracking for in-flight work | Permanent reference material |

**Common mistakes:**
- Saving coding conventions to memory instead of `.claude/rules/` — these should be version-controlled and available on every machine
- Saving standing instructions to memory — these get lost when switching machines or pruning
- Saving architecture knowledge to memory instead of `docs/` — memory is per-machine, docs are shared via git

## Three-Tier Architecture

Memory operates in three tiers with different loading behavior and token costs.

| Tier | Location | Loading | Token Budget | Purpose |
|------|----------|---------|-------------|---------|
| **Hot** | `MEMORY.md` | Always loaded on every conversation | < 200 lines (~800 tokens) | Index/pointers to topic files, active project status |
| **Warm** | Topic files (`*.md` in memory dir) | Loaded when referenced or relevant | ~2,000 tokens per file | Domain knowledge, project details, feedback |
| **Cold** | `docs/`, `.claude/rules/` | Loaded via exploration or path-scoping | No per-file limit | Full reference material, standards, architecture |

**Total auto-memory budget:** Keep under 10,000 tokens across all memory files (~40KB). Beyond this, context rot degrades agent performance.

## Health Thresholds

`/memory-review` audits against these thresholds (estimate tokens at ~4 characters per token):

| Metric | Warn | Error |
|--------|------|-------|
| `MEMORY.md` line count | > 150 lines | > 200 lines (truncation boundary — content beyond line 200 is silently dropped) |
| Total memory token estimate | > 8,000 tokens | > 10,000 tokens |

## MEMORY.md Standards

`MEMORY.md` is always loaded into context. Every token counts.

- **Max 200 lines** — content beyond line 200 is silently truncated; keep well under (warn at 150)
- **Index-only** — MEMORY.md contains pointers to topic files, not content itself
- **No frontmatter** — MEMORY.md is a plain Markdown index file
- **Required structure:**
  ```markdown
  # Memory

  ## [Section Name]
  - [Brief description] — see [topic-file.md](topic-file.md) for details

  ## [Section Name]
  - [Pointer to another topic file]
  ```
- **Keep concise** — one line per topic file pointer, brief descriptions only
- **No standing instructions** — these belong in CLAUDE.md or `.claude/rules/`

## Topic File Standards

Topic files are individual memory entries stored alongside MEMORY.md.

### Required Frontmatter

Every topic file must include frontmatter with three fields:

```markdown
---
name: Component Catalog Status
description: Tracking catalog coverage and open component proposals for issue #96
type: project
---

[Content here]
```

| Field | Purpose | Values |
|-------|---------|--------|
| `name` | Human-readable name | Free text |
| `description` | Used by Claude Code to decide retrieval relevance | One line, specific enough to match future queries |
| `type` | Memory category | `user`, `feedback`, `project`, `reference` |

### Memory Types

| Type | When to Use | Examples |
|------|------------|---------|
| `user` | User role, preferences, knowledge level | "HC is senior Rails dev, new to ViewComponent" |
| `feedback` | Corrections to agent behavior | "Don't summarize at end of responses" |
| `project` | Active work, decisions, status | "Issue #105 status and PR merge order" |
| `reference` | Pointers to external systems | "Design proposals tracked on the org project board" |

### Content Guidelines

- Lead with the most important information
- Use bullet points, not prose paragraphs
- Include absolute dates, not relative ("2026-07-01", not "last Thursday")
- For `feedback` and `project` types, include **Why:** and **How to apply:** lines
- Keep individual topic files under 50 lines (~200 tokens) when possible
- One topic per file — don't combine unrelated subjects

## What NOT to Store in Memory

These belong elsewhere or are derivable from existing sources:

- **Code patterns and conventions** — derivable from the codebase; put in `.claude/rules/`
- **Git history, recent changes** — use `git log` / `git blame`
- **Debugging solutions** — the fix is in the code; the commit message has context
- **Anything in CLAUDE.md or docs/** — don't duplicate repo-tracked content
- **Ephemeral task details** — use conversation context or tasks, not memory
- **Component/token documentation** — belongs in `catalog/` and `tokens/`

## Maintenance Cadence

Memory requires active curation. Indiscriminate accumulation degrades agent performance.

### When to Review

| Trigger | Action |
|---------|--------|
| **Quarterly** (baseline) | Run `/memory-review`, prune stale entries |
| **After closing an issue/PR** | Remove or archive project-type entries that tracked it |
| **After major features** | Update related topic files, remove debugging notes |
| **Before starting large new work** | Review MEMORY.md for relevance, clean up before adding |

### What to Check

1. **Staleness** — References to closed issues, merged PRs, or completed projects; entries dated more than 90 days ago are candidates for review
2. **Contradictions** — Entries that conflict with each other, with CLAUDE.md, or with `.claude/rules/`
3. **Duplicates** — Content that repeats what's in CLAUDE.md, `.claude/rules/`, or `docs/`
4. **Misplaced content** — Standing instructions or conventions that belong in repo files
5. **Token budget** — Total memory size against the thresholds above
6. **Missing frontmatter** — Topic files without `name`, `description`, `type`
7. **Orphaned worktree memory** — Leftover worktree memory directories (see below)

### How to Review

Run `/memory-review` — this command audits the current project's memory against every threshold in this document and recommends specific actions. Do not modify memory files without HC approval.

## Worktree Memory

Worktree agent sessions get their own memory directories under `~/.claude/projects/` (paths containing `--claude-worktrees-`). This memory is ephemeral:

- Don't rely on worktree memory persisting — anything durable belongs in the main project memory or the repo
- Once a worktree is removed, its memory directory is orphaned; `/memory-review` flags these for deletion

## Cross-Project Standards

- **Per-project memory** — Each MPI project has its own memory directory. No sharing between projects.
- **Consistent structure** — All MPI projects follow these same standards
- **Per-machine** — Memory is local to each development machine. Content that must be portable belongs in the repo, not memory.

## File Naming

- Use kebab-case: `component-catalog.md`, not `component_catalog.md`
- Name files by topic, not by date: `component-catalog.md`, not `2026-07-01-notes.md`
- Keep names short and descriptive: 2-4 words
