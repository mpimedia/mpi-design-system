Read and respond to PR review comments for PR #$ARGUMENTS.

## Steps

1. **Fetch all review comments** using:
   ```bash
   gh pr view $ARGUMENTS --comments
   gh api repos/{owner}/{repo}/pulls/$ARGUMENTS/comments
   gh api repos/{owner}/{repo}/pulls/$ARGUMENTS/reviews
   ```
2. **Categorize each comment**:
   - **Must fix** — Security issues, bugs, broken tests
   - **Should fix** — Code quality, naming, pattern violations, missing edge cases
   - **Discussion** — Architectural questions, alternative approaches, style preferences
3. **Summarize for the HC**:
   - List each comment with category and your assessment
   - For each "must fix" and "should fix", propose a specific resolution
   - For "discussion" items, provide your recommendation with reasoning
4. **Present options** to the HC:
   - Option A: Address all comments (recommended if all are straightforward)
   - Option B: Address must-fix and should-fix, respond to discussion items with rationale
   - Option C: Custom selection — let HC choose which to address
5. **Wait for HC to choose** before making any changes

## After HC Chooses

1. Make the requested changes
2. Run `bundle exec rubocop -a` and `bundle exec rspec`
3. Commit with a message referencing the review feedback
4. Push to the PR branch
5. Reply to each addressed comment on the PR explaining what was changed
6. Post a summary comment on the PR noting all changes made
