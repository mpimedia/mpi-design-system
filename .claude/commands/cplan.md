Create an implementation plan for GitHub issue #$ARGUMENTS based on the chosen option from the assessment.

This is **Stage 2** of the MPI Development Lifecycle (see `docs/standards/development-lifecycle.md`).

## Steps

1. **Read the issue and comments** using `gh issue view $ARGUMENTS --comments` to get the full context including the assessment and HC's chosen option
2. **Break down the work** into discrete, ordered tasks
3. **Identify files to create or modify** for each task
4. **Define the testing strategy** — this is decided NOW, not during implementation:
   - Which spec types are needed (component, JS behavior via dummy-app feature spec)
   - Specific scenarios to test for each spec type
   - Edge cases: missing/invalid parameters, empty collections, all variants and sizes
   - Whether a Lookbook preview is needed (every new component gets one)
   - Reference `.claude/rules/testing.md` for coverage requirements
5. **Determine the development environment**:
   - **Simple branch** — Single-focus work, small scope, one agent
   - **Worktree** (`git worktree add`) — When work needs isolation (parallel agents, long-running feature alongside hotfixes)
   - Branch naming: `feature/`, `fix/`, `chore/`, or `docs/` prefix
6. **Determine agent strategy** (AC recommends, HC decides):
   - **Single agent** — Under 15 files, tightly coupled tasks
   - **Parallel agents** — 15+ files, independent subsystems. Each agent gets its own worktree with exclusive file ownership. If recommending parallel, HC should run `/orch` after approving the plan.
   - **Background agents** — Long-running tasks (full test suite, linting) while main agent continues
7. **Check for risks** — breaking changes to component APIs, consuming-app impact (Markaz, SFA, Garden, Harvest), gem packaging changes, accessibility regressions
8. **Write the plan** in a structured format

## Output Format

Post the plan as a comment on the issue using `gh issue comment $ARGUMENTS --body "..."`.

Also display the plan in the conversation for HC review before execution.

```markdown
## Implementation Plan

### Development Environment
- Environment: [simple branch | git worktree]
- Branch: `feature/issue-NNN-description`
- Agent strategy: [single agent | parallel agents — recommend `/orch`]
- Estimated scope: [X files to change, Y specs to write]

### Tasks
1. [Task description] — [files affected]
2. [Task description] — [files affected]
...

### Testing Strategy
Define EVERY test that will be written:

#### Component Specs
- [Component]: rendering with required/optional params, every variant, size, and state
- Assertions on rendered output (`render_inline` + Capybara matchers), not just "it renders"

#### Lookbook Previews
- [Component]: preview with representative params for every variant

#### JS / Interactive Behavior
- [Stimulus controller]: behavior exercised through the dummy app (`spec/dummy/`)

#### Edge Cases
- Invalid params: [specific scenarios]
- Empty/missing content: [specific scenarios]
- Accessibility: [ARIA attributes, keyboard access assertions]

### Risks & Considerations
- [Any component API, consuming-app, packaging, or accessibility concerns]

### Next Step
HC: Approve to proceed with `/impl $ARGUMENTS`.

— Claude Code (Fable 5)
```

## Quality Standard

Before posting the plan, self-review:
- Is every task specific enough to implement without guessing?
- Does the testing strategy cover the full definition of done from `.claude/rules/testing.md`?
- Would a critical reviewer find missing edge cases or untested scenarios?
- Are risks identified that could block implementation?

## Attribution

Include `— Claude Code (Fable 5)` (or current model) at the bottom of the GitHub comment.
