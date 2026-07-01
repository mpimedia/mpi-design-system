Read and respond to PR review comments for PR #$ARGUMENTS.

This supports **Stage 5 (Deliver)** of the MPI Development Lifecycle (see `docs/standards/development-lifecycle.md`).

## Steps

1. **Fetch all review comments** using:
   ```bash
   gh pr view $ARGUMENTS --comments
   gh api repos/{owner}/{repo}/pulls/$ARGUMENTS/comments
   gh api repos/{owner}/{repo}/pulls/$ARGUMENTS/reviews
   ```

2. **Categorize each comment by severity** (per `docs/standards/code-review.md` "Severity Priority" section):
   - **P0 — Must Fix** — Security (XSS in templates, missing escaping), broken tests, accessibility violations
   - **P1 — Should Fix** — Pattern violations, missing tests, incorrect Bootstrap usage, missing responsive behavior
   - **P2 — Consider** — Naming, organization, additional variants or states
   - **Discussion** — Architectural questions, alternative approaches, clarification requests

3. **Summarize for the HC** — present a table:
   ```markdown
   | # | Comment | Severity | Proposed Resolution |
   |---|---------|----------|---------------------|
   | 1 | [summary] | P0 | [specific fix] |
   | 2 | [summary] | P1 | [specific fix] |
   | 3 | [summary] | P2 | [fix or explain why not] |
   | 4 | [summary] | Discussion | [recommendation with reasoning] |
   ```

4. **Present options** to the HC:
   - Option A: Address all P0, P1, and P2 findings (recommended if straightforward)
   - Option B: Address P0 and P1, respond to P2 with rationale
   - Option C: Custom selection — HC chooses which to address

5. **Wait for HC to choose** before making any changes

## After HC Chooses

1. Make the requested changes
2. Run all quality checks:
   ```bash
   bundle exec rubocop -a
   bundle exec rspec
   ```
3. Self-review changes against `.claude/rules/self-review.md` — don't introduce new issues while fixing old ones
4. Commit with a message referencing the review feedback
5. Push to the PR branch
6. Reply to each addressed comment on the PR explaining what was changed:
   ```markdown
   Fixed in [commit hash] — [brief description of what changed].

   — Claude Code (Fable 5)
   ```
7. For P2/Discussion items not addressed, reply with rationale:
   ```markdown
   Acknowledged — [explanation of why this was not changed, or deferred to follow-up issue #NNN].

   — Claude Code (Fable 5)
   ```
8. Post a summary comment on the PR:
   ```markdown
   ## Review Response Summary

   | # | Finding | Severity | Action |
   |---|---------|----------|--------|
   | 1 | [summary] | P0 | Fixed in [commit] |
   | 2 | [summary] | P1 | Fixed in [commit] |
   | 3 | [summary] | P2 | Deferred — [reason] |

   All quality checks pass. Ready for `/final $ARGUMENTS`.

   — Claude Code (Fable 5)
   ```

## Next Step

After all review comments are addressed, HC runs `/final $ARGUMENTS` to generate the SOW and prepare for merge.

## Attribution

Include `— Claude Code (Fable 5)` (or current model) at the bottom of any GitHub comments.
