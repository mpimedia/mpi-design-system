Orchestrate a multi-agent strategy for implementing issue #$ARGUMENTS.

## Prerequisites

- An implementation plan must already exist on the issue (run `/project:cplan` first)
- An agent strategy recommendation should exist (run `/project:esti` first, or this command will generate one)

## Steps

1. **Read the issue, plan, and agent estimate** using `gh issue view $ARGUMENTS --comments`

2. **Identify parallelizable work streams**:
   - Group tasks by file/system independence (components vs specs vs docs)
   - Identify hard dependencies (shared code before dependent components)
   - Flag shared state conflicts (two agents editing the same file)

3. **Design the worktree layout** (if parallel agents are warranted):
   - Create a worktree for each independent work stream using `wt create <branch-name>`
   - Name branches descriptively: `feature/NNN-components`, `feature/NNN-specs`, `feature/NNN-docs`
   - Define the merge order (which branch merges first, rebasing strategy)

4. **Generate agent assignments**:
   - For each work stream, define:
     - What the agent builds
     - Which files it owns (exclusive — no two agents touch the same file)
     - What it should run before committing (`rubocop -a`, relevant specs)
     - Its completion signal (PR created, or commit pushed)
   - Define the integration step (who merges, who runs full test suite)

5. **Create coordination instructions**:
   - Which agent starts first (if there's a dependency)
   - How agents communicate shared interfaces (e.g., "Agent B expects Agent A to create `app/components/admin/foo/component.rb`")
   - Conflict resolution: if two agents need the same file, one owns it and the other waits

6. **Post the orchestration plan** as a comment on the issue using `gh issue comment $ARGUMENTS --body "..."`

## Output Format

```markdown
## Multi-Agent Orchestration Plan for #NNN

### Strategy: [Parallel | Sequential | Hybrid]

### Work Streams

#### Stream 1: [Name] (Agent: Main)
- **Branch**: `feature/NNN-description`
- **Owns**: [list of files this agent exclusively modifies]
- **Tasks**: [numbered task list]
- **Pre-commit checks**: `bundle exec rubocop -a && bundle exec rspec spec/path/`
- **Depends on**: [nothing | Stream N]

#### Stream 2: [Name] (Agent: Background)
- **Branch**: `feature/NNN-description`
- **Owns**: [list of files]
- **Tasks**: [numbered task list]
- **Pre-commit checks**: `bundle exec rubocop -a && bundle exec rspec spec/path/`
- **Depends on**: [Stream 1 | nothing]

### Shared Interfaces
| Interface | Owner | Consumer | Contract |
|-----------|-------|----------|----------|
| [component/method] | Stream 1 | Stream 2 | [expected signature/behavior] |

### Integration Plan
1. [First stream merges to feature branch]
2. [Second stream rebases and merges]
3. [Run full test suite]
4. [Create PR from integration branch]

### Rollback Plan
- If streams conflict: [resolution strategy]
- If integration fails: [fallback to sequential approach]
```

Also display the plan in the conversation for HC review before execution.
