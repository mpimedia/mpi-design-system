Create an implementation plan for GitHub issue #$ARGUMENTS based on the chosen option from the assessment.

## Steps

1. **Read the issue and comments** using `gh issue view $ARGUMENTS --comments` to get the full context including the assessment and HC's chosen option
2. **Break down the work** into discrete, ordered tasks
3. **Identify files to create or modify** for each task
4. **Determine the test strategy** — what specs to write or update, referencing existing patterns in `spec/`
5. **Determine the development environment**:
   - Evaluate whether this work should use **git worktrees** or **worktrunk** (`wt`) instead of a simple branch:
     - **Simple branch** — Single-focus work, small scope, one agent
     - **Worktree** (`git worktree add`) — Use when work needs isolation from the main working directory (e.g., long-running feature alongside hotfixes, or parallel agents that each need their own checkout)
     - **Worktrunk** (`wt create`) — Use when managing multiple worktrees with shared hooks, configuration, and automated commit message generation. Preferred for multi-agent parallel work.
   - Branch naming: `feature/`, `fix/`, `chore/`, or `docs/` prefix
   - Whether parallel agents would help (independent tasks across different files/systems)
   - If parallel agents are recommended, each agent should get its own worktree via `wt create <branch-name>`
6. **Check for risks** — breaking changes to existing components, spec failures, engine compatibility
7. **Write the plan** in a structured format

## Output Format

Post the plan as a comment on the issue using `gh issue comment $ARGUMENTS --body "..."`.

The plan should include:

```markdown
## Implementation Plan

### Development Environment
- Environment: [simple branch | git worktree | worktrunk]
- Branch: `feature/issue-NNN-description`
- Worktrees needed: [none | list of worktree branches and their purpose]
- Agent strategy: [single agent | parallel agents with breakdown]
- Estimated scope: [files to change, specs to write]

### Tasks
1. [Task description] — [files affected]
2. [Task description] — [files affected]
...

### Test Plan
- [What specs to add/modify]
- [Edge cases to cover]

### Risks & Considerations
- [Any engine compatibility, breaking change, or consuming app concerns]
```

Also display the plan in the conversation for HC review before execution.
