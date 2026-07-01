Self-review PR #$ARGUMENTS against the implementation plan before Reviewer sees it.

This is **Stage 4** of the MPI Development Lifecycle (see `docs/standards/development-lifecycle.md`).

## Steps

1. **Read the PR** using `gh pr view $ARGUMENTS` and `gh pr diff $ARGUMENTS`
2. **Read the implementation plan** from the linked issue:
   - Run `gh pr view $ARGUMENTS --json closingIssuesReferences --jq '.closingIssuesReferences[].number'` to find linked issue numbers
   - Read the plan from issue comments using `gh issue view <number> --comments`
3. **Check plan alignment**:
   - Every task in the plan has a corresponding change in the diff
   - No files changed that aren't in the plan (no scope creep)
   - No plan items missing from the implementation
4. **Review test quality** — apply `.claude/rules/testing.md` definition of done for every spec in the diff:
   - Are assertions meaningful? A test that only checks the component renders without error is a false green
   - Ask: "If this test passed but the feature was broken, would I know?"
   - Component specs: every variant, size, and state covered? Output asserted with Capybara matchers?
   - Lookbook previews: added or updated for every changed component?
   - Interactive behavior: Stimulus controllers exercised through the dummy app?
   - Edge cases: invalid params, empty content, boundary values tested?
   - Accessibility: ARIA attributes and keyboard access asserted where relevant?
5. **Check for common Reviewer findings**:
   - Incomplete test coverage — the most frequent finding
   - Missing error/edge case handling
   - Requirements from the issue not fully addressed
   - Code quality issues (naming, structure, duplication)
   - Accessibility gaps (missing ARIA, contrast, focus indicators)
6. **Check for cleanliness**:
   - No debug code (`puts`, `byebug`, `binding.pry`, `console.log`)
   - No commented-out code
   - No "TODO" or "needs manual testing" comments
   - No unrelated changes
7. **Review the PR description**:
   - Summary, Changes, Technical Approach, Testing, Checklist sections present
   - Accurately describes what was done and why

## Fix Issues

If any check fails, fix it NOW — don't document it for later. The goal is that when Reviewer sees this PR, they find nothing.

## Output

After completing self-review, post a comment on the PR:

```markdown
## Self-Review Complete

### Plan Alignment
- [x] All plan items implemented
- [x] No scope creep — only planned files changed
- [List any deviations and why]

### Test Coverage Verified
- [x] Component specs: [summary]
- [x] Lookbook previews: [summary]
- [x] Interactive behavior: [summary]
- [x] Edge cases: [summary]

### Reviewer Readiness
- [x] No debug code, no TODOs, no commented-out code
- [x] PR description complete
- [x] All quality checks pass

PR is ready for Reviewer.

— Claude Code (Fable 5)
```

Notify HC that the PR is ready to send to Reviewer. After Reviewer feedback, HC runs `/rtr $ARGUMENTS` then `/final $ARGUMENTS`.

## Attribution

Include `— Claude Code (Fable 5)` (or current model) at the bottom of any GitHub comments.
