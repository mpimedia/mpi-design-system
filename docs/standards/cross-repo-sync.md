# Cross-Repo Standards Synchronization

How this engine's agent configuration stays in sync with the MPI application suite. **Optimus is the canonical template** — standards originate there and propagate outward. "In sync" is an ongoing obligation, not a one-time port: when Optimus's agent configuration evolves (a new lifecycle stage, a renamed command, a newly shared plugin), this repo tracks the change deliberately instead of re-diverging.

This document is the backbone of that process; `/compare` is its drift-check command.

## The Two-Layer Model

The agent configuration splits into two layers that are treated **differently**. Machinery converges tightly on Optimus; domain content is tailored to engine scope. Knowing which layer a file belongs to tells you whether a difference from Optimus is drift (fix it) or tailoring (keep it).

### Layer 1: Machinery — sync tightly with the suite

Same names, same numbers, same structure as Optimus. Engine-scoped wording *inside* these files is expected; their shape is not allowed to drift.

| Machinery | Files | Sync Rule |
|-----------|-------|-----------|
| Lifecycle commands | `.claude/commands/*.md` | Same command names, stage numbers, and document structure as Optimus. This repo's flat set: `assess`, `compare`, `cplan`, `dep-review`, `explore`, `final`, `impl`, `memory-review`, `orch`, `rtr`, `verify`. Step content is engine-scoped (components, previews, tokens — not app systems). |
| `settings.json` structure | `.claude/settings.json` | The **attribution block** (commit trailer + PR footer strings), the **PreToolUse hook matcher** list (`Write\|Edit\|Bash(git commit:*)\|Bash(git push:*)\|Bash(git merge:*)\|Bash(git rebase:*)`), and the **enabledPlugins** scheme converge with Optimus. The plugin *list* is tailored to engine relevance: design/frontend-facing plugins kept, app/infra-only plugins dropped. |
| Agent-layer branch hook | `.claude/hooks/enforce-branch-creation.sh` | Optimus's fail-closed variant. Logic changes sync from Optimus, not local edits. |
| Git-layer branch guard | `.githooks/{pre-commit,pre-push,pre-merge-commit,pre-rebase}`, `bin/guard-protected-branch`, `bin/install-git-hooks` | Ported from Optimus; the AC-vs-HC detection logic must match the template. |
| Project registry | `.claude/projects.json` | Matches Optimus's current registry — Optimus's copy is the source of truth for the ecosystem entry list. |
| Standards doc structure | `docs/standards/*.md` | Stage definitions, gate structure, severity framework, and thresholds track Optimus's versions; the content inside is engine-scoped. |

### Layer 2: Domain Content — tailored to engine scope

Governed by what a Rails engine gem (ViewComponents, Stimulus controllers, design tokens, `spec/dummy`) actually needs — not by matching Optimus file-for-file.

| Domain Content | Files | Tailoring Rule |
|----------------|-------|----------------|
| Rules selection and content | `.claude/rules/{frontend,testing,self-review,dependencies}.md` | *Which* rules exist and *what they say* is decided by engine scope. Content is authored against the engine's actual code, never fork-and-pruned from an app repo. |
| Standards selection | `docs/standards/` (lean core: development-lifecycle, code-review, memory-management, cross-repo-sync) | The engine adopts only the standards that apply to a UI-component gem. Optimus carries many more; that's correct for an app. |
| `CLAUDE.md` / `AGENTS.md` specifics | Tech stack, component catalog, design tokens, consuming-app list, engine architecture | Suite-shared sections (permissions model, commit/PR format, attribution, pre-commit requirements) follow the template; everything else is engine-specific. |

## Deliberate Omissions Are NOT Drift

The engine intentionally omits app-only material. `/compare` must classify these as correct tailorings, not gaps to fix:

- **`.claude/rules/backend.md`, `.claude/rules/migrations.md`** — the engine has no app models, controllers, jobs, or database
- **`/db-health` command** — no database to health-check
- **App-credentials `deny` entries** in `settings.json` (`master.key`, `credentials.yml.enc`) — the engine has no app credentials; the engine analog protects `spec/dummy/config/**` instead
- **App-only required checks** — Optimus's app repos require additional checks beyond linting and tests (a static security scanner and a dependency-vulnerability audit). The engine's required-check set is exactly two: `bundle exec rubocop -a` and `bundle exec rspec`
- **App-framework standards docs** (query patterns, caching, app view patterns, deployment tooling) and **infra-only plugins**

When adding a new deliberate omission, record it here so future drift checks don't re-litigate it.

## Drift-Check Cadence

Run `/compare` (defaults to comparing this repo against Optimus):

- **Quarterly baseline** — even when nothing is known to have changed
- **Event-driven** — whenever Optimus's agent configuration changes materially: a new or renamed command, a new lifecycle stage, a change to the `settings.json` structure (hook matchers, attribution block, plugin scheme), a newly shared plugin, an updated branch-protection script, or a revision to the core standards docs

## What To Do When Drift Is Found

1. **Classify** each difference reported by `/compare`:
   - **Machinery drift** — must sync (converge on Optimus)
   - **Domain divergence** — evaluate on engine merits; adopt structure, adapt content
   - **Deliberate omission** — no action; confirm it's recorded above
2. **Assess** — for anything beyond trivial, open or annotate an issue and run the lifecycle (`/assess`). Trivial machinery syncs may use the compressed workflow per `docs/standards/development-lifecycle.md` (HC decides).
3. **Sync PR** — a `chore/` or `docs/` branch that converges the machinery and adapts wording to engine scope. Verify every command → doc reference still resolves after the change.
4. **Gates** — both required checks pass (`bundle exec rubocop -a`, `bundle exec rspec`); grep the changed docs/rules for imported app-isms and confirm none appear.
5. **Upstream first** — if the better pattern originated in *this* repo, change Optimus first, then propagate back here. The template stays canonical.

## Model Attribution Strings

Attribution strings are hardcoded and go stale as models change: the commit trailer (`Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>`) and comment/PR footer (`— Claude Code (Fable 5)`) appear in `CLAUDE.md`, `AGENTS.md`, the `attribution` block of `.claude/settings.json`, and the command templates. Keeping them current is part of this sync process:

- `/compare` checks this repo's attribution strings against Optimus's current attribution block
- A sync PR that updates the model string updates **all** occurrences in one pass — a half-updated repo is worse than a stale one

## File Structure Convention

The engine's agent-configuration layout (machinery vs. domain content annotated):

```
mpi-design-system/
├── CLAUDE.md                          # Shared sections = machinery; engine specifics = domain
├── AGENTS.md                          # Same split; source of truth for non-Claude agents
├── .claude/
│   ├── settings.json                  # Machinery (structure) — plugin list tailored
│   ├── hooks/
│   │   └── enforce-branch-creation.sh # Machinery — agent-layer branch protection
│   ├── commands/                      # Machinery — 11 lifecycle/support commands
│   ├── rules/                         # Domain content — engine-tailored rules
│   └── projects.json                  # Machinery — MPI ecosystem registry
├── .githooks/                         # Machinery — git-layer branch protection
├── bin/
│   ├── guard-protected-branch         # Machinery — AC-vs-HC aware guard
│   └── install-git-hooks              # Machinery — sets core.hooksPath
├── .github/
│   └── copilot-instructions.md        # Points Copilot at AGENTS.md
└── docs/
    └── standards/                     # Domain selection; structure tracks Optimus
        ├── development-lifecycle.md
        ├── code-review.md
        ├── memory-management.md
        └── cross-repo-sync.md         # This document
```
