Autonomously drive GitHub issue #$ARGUMENTS through the full MPI Development Lifecycle, stopping only at the two human gates: **plan approval** and **merge**.

This is the **streamlined / hands-off track** of the MPI Development Lifecycle (see `docs/standards/development-lifecycle.md`). It composes the existing stage commands — `/assess`, `/cplan`, `/impl`, `/verify`, `/rtr`, `/final` — into one supervised run. It does NOT replace them; it sequences them and overrides the per-stage "wait for HC" gates with a single pair of real checkpoints, keeping the external Reviewer (Codex — see the lifecycle doc's Roles) in the loop at both the plan gate and the PR review.

## When to use

- Standard, engine-internal work: a new component variant, a spec/preview backfill, a refactor within existing component APIs, a well-understood bug fix, docs or agent-config maintenance.
- The issue is well-specified enough to plan without a back-and-forth.

## When NOT to use (run the stages manually instead)

- **Ecosystem-propagating changes** — anything that reaches into all four consuming apps (Markaz, SFA, Garden, Harvest): gemspec **runtime dependency** changes (see `.claude/rules/dependencies.md` — an ecosystem-wide decision), **breaking changes to a public component API**, **design-token value changes** in `_tokens.scss`, or changes to what ships in the gem (the gemspec `files` glob). `/ship` will still *stop and ask* if it discovers such a change mid-run, but prefer the manual lifecycle here from the start.
- The issue is ambiguous or underspecified — `/assess` would need to ask clarifying questions anyway.

## The two gates (and nothing else by default)

1. **Plan-approval gate** — after `/cplan`, post the plan and **STOP**. Await the HC's explicit "approved" (or chosen option / revisions) before writing any code.
2. **Merge gate** — after `/final` posts the SOW and CI is green with no open P0/P1, **STOP**. The HC clicks merge. Never merge the PR yourself.

Between those two gates, run autonomously. **Plus** these unconditional emergency stops — if any occurs, halt and ask the HC with `AskUserQuestion`, do not guess:

- A required check (`bundle exec rubocop -a`, `bundle exec rspec`, or CI) fails and the fix is non-obvious or would change behavior beyond the plan.
- Implementation reveals the change is ecosystem-propagating in a way the plan didn't anticipate — a gemspec runtime dependency, a breaking component API change, a design-token value change, or a gem-packaging change.
- A Reviewer comment is architectural, ambiguous, or contradicts the approved plan (a **Discussion**-class finding — see auto-`/rtr` policy below).

## Context hygiene via subagent offloading

`/ship`'s biggest context cost is three heavy operations whose *output* dwarfs the *signal* the orchestrator needs. Each is **dispatched to a subagent whose context is discarded**; the orchestrator keeps only a compact structured summary. This keeps the highest-judgment work (planning, reconciliation, the merge decision) out of the degraded long-context zone. The per-stage commands define the work each subagent performs; this is the map:

| Heavy op | Stage | Subagent | Returns |
|----------|-------|----------|---------|
| Codebase exploration | `/assess` step 4 | built-in `Explore` (read-only) | exploration-summary (file map + findings) |
| Code + test/lint/fix loop | `/impl` steps 3–5 | built-in `general-purpose`, **shared worktree** | check-result (per-check results + git-state + commit/PR body) |
| Full-diff review | `/verify` | built-in `general-purpose` (read-only) | drift-report (+ ready-to-post self-review markdown) |

Built-in agent types only (`Explore`, `general-purpose`) — targeted prompts that embed the stage's checklist and the `.claude/rules/testing.md` definition of done are the contract. Both required checks and the testing definition-of-done run **inside** the subagent at full strength — offloading changes *where* the work runs, never *whether* the gates apply.

**Faithfulness — the review subagent's second pass must be real, not assumed.** A `/verify` subagent that misses a finding *hides* it from the orchestrator. The backstop is the independent external Reviewer (Codex). This engine has **no Codex GitHub Actions** (`.github/workflows/` contains only `ci.yml`) — do not poll for a `codex-review` or `codex-plan-review` workflow run; none exists. Instead, **invoke Codex directly**: on the plan in Phase 1, and on the PR diff in Phase 2. If no second model is reachable, treat the lone `/verify` pass as unverified and **stop and ask the HC**. Never log "Codex reviewed" without a Codex-authored review actually in hand.

## Phase 1 — Plan (stops at gate 1)

1. Run the full `/assess $ARGUMENTS` steps — its step-4 codebase exploration is dispatched to a read-only `Explore` subagent that returns an exploration-summary (see `assess.md` and *Context hygiene* above). Post the assessment comment on the issue and display it.
2. If `/assess` surfaced blocking clarifying questions, **stop and ask** — do not proceed to a plan on guesses.
3. Otherwise pick the recommended option and run the full `/cplan $ARGUMENTS` steps. Post the plan comment on the issue and display it.
4. **Codex reviews the plan, then you reconcile** (the external review happens *before* any code is written — the cheapest place to catch a flawed plan):
   - **Obtain Codex's review of the plan** by invoking Codex directly against the plan plus the relevant code (there is no plan-review GitHub Action in this repo).
   - **Reconcile.** Read Codex's review critically. Apply the same severity lens as the PR auto-`/rtr` policy (per `docs/standards/code-review.md` "Severity Priority"): fold in valid P0/P1/P2 points, and for anything architectural/ambiguous or that conflicts with the chosen option, **stop and ask the HC** rather than silently reshaping the plan.
   - **Repost.** If you revised the plan, post the updated plan and a short "Codex flagged X → handled by Y" note so the HC sees what the second model caught. If Codex found nothing material, say so.
5. **STOP.** Tell the HC: "Plan posted and Codex-reviewed on #$ARGUMENTS. Reply `approved` (or pick a different option / request changes) to start the autonomous build." **Recommend a clean-context start for the build:** Phase 1 (assess + plan + Codex reconcile) can fill a large fraction of the context window before any code is written, so advise the HC to **begin Phase 2 in a fresh session** (or `/compact` first) and resume with `/impl $ARGUMENTS` — the approved plan is durably on the issue, so a reset loses nothing. Continuing in-session is supported but carries Phase 1's accumulated context into the build. End the turn.

## Phase 2 — Build → Review → SOW (resumes on approval, stops at gate 2)

Trigger: HC approves the plan in the conversation. `/ship` takes only the numeric issue id as `$ARGUMENTS` — it does not parse resume flags. To resume in a fresh session, run the underlying stage command directly (`/impl NNN`, then `/verify <PR_NUMBER>`, etc.).

> **Identifiers — read first.** `$ARGUMENTS` is the **issue** id. `/impl` opens a PR whose number is **different**. The PR-scoped stages — `/verify`, `/rtr`, `/final`, and `gh pr checks` — operate on the **PR number**, not the issue id (see `.claude/commands/{verify,rtr,final}.md`). Capture the PR number `/impl` creates as `<PR_NUMBER>` and pass *that* to every PR-scoped stage below. Pass `$ARGUMENTS` only to issue-scoped commands.

1. **Implement** — run the full `/impl $ARGUMENTS` steps: feature branch, code + specs per the plan's testing strategy (spec + Lookbook preview for every component touched), both required checks green, self-review checklist, commit, push, open the PR, post implementation notes. The orchestrator creates the branch and confirms a clean tree, then the code + test/lint/fix loop runs in a shared-worktree `general-purpose` subagent; the orchestrator reconciles git state against the returned **check-result** and then commits / pushes / opens the PR from it — never reloading the diff (see `impl.md` and *Context hygiene* above). **Record the new PR number as `<PR_NUMBER>`** (e.g. from `gh pr view --json number`).
   - **Issue linking** — use `Closes #$ARGUMENTS` for a normal (leaf) issue. **If `$ARGUMENTS` is an umbrella/epic issue** delivered across multiple PRs, reference it as `Part of #$ARGUMENTS` and never with a closing keyword adjacent — GitHub ignores negation and would close the umbrella when this PR merges, orphaning the remaining phases. Close the specific phase sub-issue instead.
2. **Verify** — run the full `/verify <PR_NUMBER>` steps: the diff review is dispatched to a read-only `general-purpose` subagent that returns a **drift-report**; fix any drift NOW, then post the self-review comment from the report (see `verify.md`).
3. **External review — obtain it directly.** There is no PR-review GitHub Action in this repo, so opening the PR triggers nothing by itself. **Invoke Codex directly on the PR diff** and have it post (or relay) its findings, so the `/verify` subagent's pass has a real independent second model. **GitHub Copilot may also post a PR _review_ with inline diff comments** (this repo carries `.github/copilot-instructions.md`). Inline reviews are surfaced by `gh pr view <PR_NUMBER> --json reviews` and `gh api repos/{owner}/{repo}/pulls/<PR_NUMBER>/comments` — **not** by `gh pr checks` or issue-level `--comments`, so fetch the review surface explicitly or you will silently miss Copilot's findings. In the local CLI there is no event push — re-check the review surface after each push and before `/final`.
4. **Auto-respond to review** — **first fetch the full review surface from every reviewer** (`gh pr view <PR_NUMBER> --json reviews`, `gh api repos/{owner}/{repo}/pulls/<PR_NUMBER>/comments` for inline threads, and issue-level comments — checking CI status or issue comments alone misses inline reviews), then for each batch apply the `/rtr <PR_NUMBER>` steps with this **autonomous resolution policy** (replacing `/rtr`'s "wait for HC to choose"), severities per `docs/standards/code-review.md` "Severity Priority":
   - **P0 / P1** — fix automatically, re-run both required checks, push, reply to each comment with the fixing commit.
   - **P2** — fix if straightforward; otherwise reply with rationale or defer to a follow-up issue.
   - **Discussion / architectural / ambiguous / conflicts-with-plan** — **stop and ask the HC** (`AskUserQuestion`). Do not guess on architecture.
   - Post the Review Response Summary comment after each round.
   - Loop until CI is green (`gh pr checks <PR_NUMBER>`) and there are no open P0/P1 findings.
5. **Context-budget check, then Finalize.** Before `/final`: if this session has accumulated heavy context (multiple full test-suite runs, large diffs, long review threads), **stop and ask the HC to resume `/final <PR_NUMBER>` in a fresh session** — `/final` is the last quality gate plus SOW generation and must run with full attention, not deep in a filled window (auto-compaction is not a safety net; it fires well inside the degraded zone). Otherwise run the full `/final <PR_NUMBER>` steps: rebase if needed, confirm both required checks + CI green, generate and post the SOW, post the reference link on the issue, surface any `CLAUDE.md`/rules improvement suggestions to the HC.
6. **STOP at the merge gate.** Tell the HC the PR is green, reviewed, and SOW-posted — ready to merge. **Do not merge.** Re-check CI status and merge-conflict state when reporting — they can change between the last push and the gate.

## Quality bar

`/ship` must never lower the bar of the individual stages to "keep the pipeline moving." Every gate the stage commands enforce — both required checks, the `.claude/rules/testing.md` definition of done, the `.claude/rules/self-review.md` checklist — still applies at full strength. Every component touched still ships with its spec and Lookbook preview. Faster cadence, same rigor. If you cannot clear a gate honestly, stop and say so.

## Attribution

Every GitHub comment posted across the run carries `— Claude Code (Fable 5)` (or current model) per `CLAUDE.md`. Commits carry the `Co-Authored-By` trailer.
