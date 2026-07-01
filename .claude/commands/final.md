Finalize and prepare PR #$ARGUMENTS for merge.

This is **Stage 5** of the MPI Development Lifecycle (see `docs/standards/development-lifecycle.md`).

## Steps

1. **Verify PR is ready**:
   - Pull latest from the base branch and rebase if needed
   - Run `bundle exec rubocop -a` — must pass
   - Run `bundle exec rspec` — must pass
   - Check that all review comments have been addressed
   - Verify CI checks are passing with `gh pr checks $ARGUMENTS`

2. **Address any remaining Reviewer feedback** (per `AGENTS.md` severity levels):
   - **P0 — Must Fix** — Security, broken tests, accessibility violations. Fix before SOW. No exceptions.
   - **P1 — Should Fix** — Pattern violations, missing tests, incorrect Bootstrap usage, missing responsive behavior. Fix before SOW in most cases.
   - **P2 — Consider** — Naming, organization, additional variants. Fix or explain why not (HC decides).
   - Do not argue with Reviewer findings unless factually incorrect — if Reviewer flags it, it's a real gap
   - All P0 and P1 findings must be resolved before generating the SOW

3. **Generate SOW (Statement of Work)** and post as a PR comment using `gh pr comment $ARGUMENTS --body "..."`:

   ```markdown
   ## Statement of Work

   ### Issue
   [Link to issue] — [one-line summary of the problem]

   ### Option Chosen
   [Which option from the assessment was selected and why]

   ### Technical Decisions
   - [Non-obvious choices made and the reasoning behind them]
   - [Alternatives that were considered and why they were rejected]

   ### What Changed
   | File | Action | Purpose |
   |------|--------|---------|
   | path/to/file | Created/Modified/Deleted | What changed and why |

   ### Testing Coverage
   - **Component specs:** [what's covered]
   - **Lookbook previews:** [what's covered]
   - **Edge cases:** [what's covered]
   - Results: RSpec [X examples, 0 failures], Rubocop [no offenses]

   ### Reviewer Findings
   | Finding | Severity | Resolution |
   |---------|----------|------------|
   | [What was flagged] | P0/P1/P2 | [How it was resolved] |

   ### Known Limitations
   - [Anything intentionally deferred or out of scope]

   ### Follow-Up Items
   - [Issues created for future work, with links]

   ### Linked Issue
   Closes #NNN

   — Claude Code (Fable 5)
   ```

4. **Post reference link on the original issue**:
   - Find linked issue: `gh pr view $ARGUMENTS --json closingIssuesReferences --jq '.closingIssuesReferences[].number'`
   - Post using `gh issue comment <issue-number> --body "..."`:
   ```markdown
   SOW posted on PR #$ARGUMENTS: [link to PR]

   — Claude Code (Fable 5)
   ```

5. **Suggest CLAUDE.md or rules improvements** based on what was learned during this implementation:
   - Did any convention or pattern come up that isn't documented?
   - Did a Reviewer finding reveal a gap in the rules?
   - Should a new anti-pattern or quality expectation be added?
   - Present suggestions to HC — do not edit CLAUDE.md or rules without approval

6. **Notify HC** that the PR is ready for final review and merge

## Do NOT merge the PR yourself — wait for HC to request merge.

## Attribution

Include `— Claude Code (Fable 5)` (or current model) at the bottom of any GitHub comments.
