Review a Dependabot or dependency update PR #$ARGUMENTS and assess its impact.

## Steps

1. **Read the PR** using `gh pr view $ARGUMENTS` to understand what dependency is being updated
2. **Get the diff** using `gh pr diff $ARGUMENTS` to see what changed in `Gemfile`, `package.json`, or `yarn.lock`
3. **Identify the dependency** — extract the gem/package name, old version, and new version
4. **Check for breaking changes**:
   - Search the gem/package changelog or release notes for breaking changes between the old and new versions
   - Use Context7 or web search to find relevant documentation
   - Check if the major version changed (indicates potential breaking changes)
5. **Assess impact on the codebase**:
   - Search for usage of the dependency in `app/`, `spec/`, `config/`
   - Identify which components/features depend on this library
   - Check if any deprecated APIs are used that may be removed in the new version
6. **Run the test suite** against the PR branch:
   ```bash
   gh pr checkout $ARGUMENTS
   bundle install
   bundle exec rspec
   bundle exec rubocop -a
   ```
7. **Post assessment** as a PR comment using `gh pr comment $ARGUMENTS --body "..."`:

```markdown
## Dependency Update Review

### Change
- **Package:** [name]
- **Old version:** [X.Y.Z]
- **New version:** [A.B.C]
- **Version bump type:** [patch | minor | major]

### Breaking Changes
- [List any breaking changes found, or "None identified"]

### Impact Assessment
- **Risk:** [low | medium | high]
- **Files affected:** [count and list of files using this dependency]
- **Recommendation:** [merge | hold for investigation | requires code changes]

### Test Results
- RSpec: [X examples, Y failures]
- Rubocop: [result]

### Notes
- [Any additional context, deprecation warnings, migration steps needed]

— Claude Code (Opus 4.6)
```

8. **If tests fail**, investigate the failures and note whether they're related to the dependency update
9. **Return to the original branch** after review: `git checkout -`
