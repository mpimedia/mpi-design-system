Finalize and prepare PR #$ARGUMENTS for merge.

## Steps

1. **Verify PR is ready**:
   - Pull latest from the base branch and rebase if needed
   - Run `bundle exec rubocop -a` — must pass
   - Run `bundle exec rspec` — must pass
   - Check that all review comments have been addressed
   - Verify CI checks are passing with `gh pr checks $ARGUMENTS`

2. **Generate SOW (Statement of Work)** and post as a PR comment:
   ```markdown
   ## Statement of Work

   ### Summary
   [What was accomplished and why]

   ### Changes Made
   | File | Action | Description |
   |------|--------|-------------|
   | path/to/file | Created/Modified/Deleted | What changed |

   ### Technical Decisions
   - [Key decisions made and rationale]

   ### Testing
   - [Tests added/modified, coverage]
   - Rubocop: [result]
   - RSpec: [X examples, 0 failures]

   ### Linked Issue
   Closes #NNN
   ```

3. **Post the SOW** using `gh pr comment $ARGUMENTS --body "..."`

4. **Notify HC** that the PR is ready for final review and merge

## Do NOT merge the PR yourself — wait for HC to request merge.
