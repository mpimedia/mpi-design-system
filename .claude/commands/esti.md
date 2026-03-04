Analyze the implementation plan for issue #$ARGUMENTS and determine the optimal agent strategy.

## Steps

1. **Read the issue and plan** using `gh issue view $ARGUMENTS --comments`
2. **Analyze task dependencies** — which tasks depend on others vs can run independently
3. **Evaluate parallelization potential**:
   - Tasks touching different files/systems can run in parallel
   - Tasks with shared state or sequential dependencies must run serially
4. **Recommend agent allocation**:
   - **Single agent**: Small changes, tightly coupled tasks, < 5 files
   - **Parallel agents**: Independent subsystems (e.g., components + specs + docs can sometimes be split)
   - **Background agents**: Long-running tasks like test suites, linting
5. **Recommend workflow tools**:
   - **Simple branch**: Most tasks — `git checkout -b feature/...`
   - **Worktrees**: When you need to compare implementations or work on unrelated changes simultaneously
   - **Worktrunk**: When managing multiple worktrees with shared configuration

## Output Format

Provide a recommendation:

```markdown
## Agent Strategy for #NNN

### Recommendation: [Single Agent | Parallel Agents]

### Rationale
- [Why this strategy]

### Task Breakdown
| Task | Agent | Dependencies | Files |
|------|-------|-------------|-------|
| ... | Main | None | ... |
| ... | Background | Blocked by Task 1 | ... |

### Workflow
- Tool: [git branch | worktree | worktrunk]
- Branch: `feature/...`
- Reason: [why this workflow]
```
