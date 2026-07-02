# MPI Development Lifecycle

## Purpose

Defines how an AI Contributor (AC) works from problem definition through delivery in this repository. The stage names, numbers, and quality gates are shared machinery across the MPI suite (canonical source: Optimus — see `docs/standards/cross-repo-sync.md`); the stage content below is scoped to what a Rails engine gem needs. The lifecycle is model-agnostic — the stages and quality gates stay the same as AC capabilities improve. What changes over time is which gates require external review vs. self-review.

## Roles

- **HC** — Human Contributor. Makes decisions, approves gates, owns the product.
- **AC** — AI Contributor. Does the work, self-reviews, responds to feedback.
- **Reviewer** — External AI reviewer (currently Codex). Provides unbiased critique.

## The Lifecycle

### Stage 1: Assess (`/assess`)

**Trigger:** HC assigns an issue or asks AC to review one.

**AC produces:**
- Summary of the problem and its impact
- Research into the engine: components (`app/components/mpi_design_system/admin/`), Stimulus controllers (`app/javascript/mpi_design_system/controllers/`), SCSS tokens, specs, Lookbook previews, and the catalog (`catalog/`) and token docs (`tokens/`)
- Catalog check — does an existing component or variant already cover the need?
- Consuming-app impact — component API changes affect Markaz, SFA, Garden, and Harvest; gem packaging changes are checked against the gemspec `files` glob
- 2-3 options with trade-offs, not just one recommendation
- Risk assessment for each option
- Complexity call (Small / Medium / Large — Large recommends `/orch` for parallel agents)
- Questions for HC if requirements are ambiguous (ask, don't guess)

**Quality gate:** HC sends assessment to Reviewer. Reviewer checks for:
- Missing options or trade-offs not considered
- Incorrect assumptions about the codebase
- Requirements gaps or misunderstandings
- Architectural or accessibility concerns

**Exit:** HC picks an option (or asks for revisions). AC does not proceed without a chosen option.

---

### Stage 2: Plan (`/cplan`)

**Trigger:** HC picks an option from the assessment.

**AC produces:**
- Step-by-step implementation plan with specific file paths
- Testing strategy — decided now, not during implementation:
  - Component specs: every variant, size, and state, with assertions on rendered output
  - Lookbook previews: every new component gets one
  - Interactive behavior: Stimulus controllers exercised through the dummy app (`spec/dummy/`)
  - Edge cases: invalid/missing params, empty content, accessibility assertions
- Development environment: simple branch vs. git worktree; branch naming (`feature/`, `fix/`, `chore/`, `docs/`)
- Agent strategy: single agent, or parallel agents via `/orch` (15+ files or independent subsystems)
- Risks: breaking component API changes, consuming-app impact, gem packaging, accessibility regressions

**Quality gate:** HC sends plan to Reviewer. Reviewer checks for:
- Steps too vague to implement without guessing
- Missing edge cases in the testing strategy
- Patterns that don't match the engine's conventions
- Requirements from the issue not addressed in the plan

**Exit:** HC approves plan (or asks for revisions). AC does not write code without an approved plan.

---

### Stage 3: Implement (`/impl`)

**Trigger:** HC approves the plan.

**AC does:**
- Creates the feature branch specified in the plan
- Implements according to the plan, step by step, following `CLAUDE.md` conventions and `.claude/rules/frontend.md`
- Writes tests per the Stage 2 testing strategy, following `.claude/rules/testing.md`
- Adds or updates a Lookbook preview for every new or changed component
- Runs both required checks: `bundle exec rubocop -a`, `bundle exec rspec`

**Quality gate:** AC self-review before requesting any review, per `.claude/rules/self-review.md`:
- [ ] Every item in the plan is implemented
- [ ] Every test scenario from the plan is covered
- [ ] Component specs assert rendered output (Capybara matchers) for every variant, size, and state
- [ ] Interactive behavior exercised through the dummy app (`spec/dummy/`)
- [ ] Accessibility: ARIA attributes, keyboard access, contrast (WCAG 2.1 AA)
- [ ] Edge cases: invalid params, empty content, boundary values
- [ ] "What would the Reviewer flag here?" — identify and fix before moving on
- [ ] Both checks pass (`bundle exec rubocop -a`, `bundle exec rspec`)

**Exit:** Both checks pass and the self-review checklist is complete. AC creates PR.

---

### Stage 4: Verify (`/verify`)

**Trigger:** PR is created.

**AC does:**
- Reviews its own PR diff against the approved plan
- Checks for drift: anything implemented that wasn't in the plan? Anything in the plan that's missing?
- Reviews test quality: are assertions meaningful, or does a spec merely confirm the component renders without error?
- Reads every test and asks: "If this test passed but the feature was broken, would I know?"
- Writes a thorough PR description per the commit/PR standards in `CLAUDE.md`

**Quality gate:** AC self-review of the complete PR. Checklist:
- [ ] PR description includes Summary, Changes Made, Technical Approach, Testing, Checklist
- [ ] No files changed that aren't in the plan (no scope creep)
- [ ] Every plan item has a corresponding test
- [ ] No "TODO" or "needs manual testing" comments remain
- [ ] Diff is clean: no debug code, no commented-out code, no unrelated changes

**Exit:** Self-review passes. HC is notified the PR is ready for Reviewer.

---

### Stage 5: Deliver (`/final`, supported by `/rtr`)

**Trigger:** HC sends PR to Reviewer.

**Reviewer checks for:**
- Testing gaps (the most common finding)
- Code quality, naming, structure
- Template escaping and other security concerns
- Accessibility gaps
- Edge cases not covered
- Requirements from the issue not addressed

**AC responds to Reviewer feedback** (via `/rtr`, severities per the "Severity Priority" section of `docs/standards/code-review.md`):
- Fix every P0 and P1 finding
- For P2 findings: fix or explain why not (HC decides)
- Do not argue with Reviewer findings unless factually incorrect — if the Reviewer flags it, it's a real gap

**SOW (Statement of Work) — AC generates and posts on the PR before merge:**
1. **Issue** — link and one-line summary
2. **Option chosen** — which approach from the assessment and why
3. **Technical decisions** — non-obvious choices and reasoning
4. **What changed** — files created/modified/deleted with purpose
5. **Testing coverage** — spec types, scenarios, notable edge cases
6. **Reviewer findings** — what was caught and how it was resolved
7. **Known limitations** — anything intentionally deferred
8. **Follow-up items** — issues created for future work

AC posts a reference link on the original issue pointing to the SOW on the PR.

**Exit:** Reviewer finds no P0/P1 issues. SOW is posted. HC merges — the AC never merges.

---

## When to Skip or Compress Stages (Compressed Workflows)

| Scenario | Approach |
|----------|----------|
| Trivial fix (typo, config change, dependency bump) | Skip Plan — Assess → Implement → Deliver (compressed self-review) |
| Bug fix with obvious cause | Assess → Plan (brief) → Implement → Deliver |
| Large change (15+ files, independent subsystems) | Full lifecycle + `/orch` for parallel agents |
| Documentation-only change | Skip Assess and Plan — Implement → Deliver |

**HC decides when to compress. AC does not self-select a compressed workflow.**

## Automated / Streamlined Track (`/ship`)

For standard, engine-internal work the HC can run the whole lifecycle hands-off with `/ship NNN`. It sequences `/assess → /cplan → /impl → /verify → /rtr → /final` and replaces the per-stage "wait for HC" pauses with exactly **two gates**:

1. **Plan approval** — after `/cplan` *and* the Reviewer's (Codex) pass over the plan, `/ship` stops and waits for the HC to approve the plan (or pick a different option). **To keep the build phase in clean context, the HC should start a fresh session (or `/compact`) after approving and resume with `/impl NNN`** — the plan is durably on the issue, so the reset loses nothing and keeps the build out of the degraded long-context zone.
2. **Merge** — after `/final` posts the SOW with green CI and no open P0/P1, `/ship` stops. The HC merges. `/ship` never merges itself.

Everything in between runs autonomously, **plus** unconditional emergency stops: a required check or CI failure that can't be auto-resolved, a discovery that the change is ecosystem-propagating in a way the plan didn't anticipate (gemspec runtime dependency, breaking component API, design-token value change, gem packaging), or an architectural/ambiguous review comment. On any of those, `/ship` halts and asks rather than guessing.

**Context hygiene — subagent offloading.** `/ship`'s three heaviest operations are dispatched to subagents whose context is discarded, so the orchestrator keeps only a compact structured summary: `/assess` codebase exploration → a read-only `Explore` subagent (exploration-summary); the `/impl` code + test/lint/fix loop → a `general-purpose` subagent in the shared worktree (check-result; the orchestrator reconciles git state, then commits/pushes/opens the PR without reloading the diff); the `/verify` full-diff review → a read-only `general-purpose` subagent (drift-report). Both required checks and the `.claude/rules/testing.md` definition of done run **inside** the subagent at full strength.

**External review without Actions.** This engine has no Codex GitHub Actions (`.github/workflows/` contains only `ci.yml`), so `/ship` invokes Codex directly — on the plan before gate 1 and on the PR diff during Phase 2. If no second model is reachable, the run stops and asks the HC rather than logging an unverified pass.

**Identifiers:** `/ship NNN` takes the **issue** id. `/impl` opens a PR with a *different* number; the PR-scoped stages (`/verify`, `/rtr`, `/final`, `gh pr checks`) operate on that **PR number**. To resume mid-lifecycle, invoke the underlying stage command directly — `/impl NNN` (issue) or `/verify <PR_NUMBER>` / `/rtr <PR_NUMBER>` (PR).

**Eligibility mirrors the ecosystem-propagation rule:** use `/ship` for component variants, spec/preview backfills, refactors within existing component APIs, well-understood fixes, and docs/config maintenance. For changes that propagate to all four consuming apps — gemspec runtime dependencies, breaking component API changes, design-token value changes — run the stages manually and synchronously.

## Command Mapping

| Stage | Command | Purpose |
|-------|---------|---------|
| 1 — Assess | `/assess` | Issue assessment with options and risks |
| 2 — Plan | `/cplan` | Implementation plan with testing strategy |
| 3 — Implement | `/impl` | Execute the plan, self-review, create PR |
| 4 — Verify | `/verify` | PR self-review against the plan |
| 5 — Deliver | `/final` | SOW generation and merge preparation |
| 5 — Deliver (support) | `/rtr` | Respond to Reviewer comments by severity |
| Full hands-off run | `/ship` | Sequences all stages with two human gates |
| Supporting | `/orch` | Multi-agent orchestration for large changes |
| Supporting | `/explore` | Codebase research for a topic |
| Supporting | `/dep-review` | Dependency update PR review |
| Supporting | `/compare` | Drift check against the Optimus template |
| Supporting | `/memory-review` | Auto-memory audit |

## Measuring Improvement

Track over time:
- **Reviewer P0/P1 findings per PR** — goal: trending toward zero
- **Passes per stage** — goal: 1 pass (Reviewer confirms, not corrects)
- **HC interventions** — goal: HC makes decisions, not corrections

When the Reviewer consistently finds nothing at a stage, HC can experiment with dropping that review and relying on self-review alone.
