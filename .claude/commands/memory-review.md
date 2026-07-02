Audit the current project's auto-memory and recommend maintenance actions.

Reference: `docs/standards/memory-management.md`

## Steps

1. **Locate the memory directory** — Determine the current project's memory path under `~/.claude/projects/`. Read all files in the directory.

2. **Check MEMORY.md health**:
   - Count lines. Warn if > 150 lines, error if > 200 lines (truncation boundary).
   - Verify it is index-only (pointers to topic files, not inline content).
   - Flag any standing instructions that belong in CLAUDE.md or `.claude/rules/` instead.

3. **Check topic file frontmatter** — Each topic file (not MEMORY.md) must have frontmatter:
   ```markdown
   ---
   name: [name]
   description: [one-line description]
   type: [user | feedback | project | reference]
   ---
   ```
   Flag files missing any of the three required fields.

4. **Check for stale entries** — For each topic file:
   - If it references GitHub issues, check their status: `gh issue view NUMBER --json state --jq '.state'`
   - If it references GitHub PRs, check their status: `gh pr view NUMBER --json state --jq '.state'`
   - Flag entries referencing closed issues or merged PRs as potentially stale
   - Flag entries with dates older than 90 days as candidates for review

5. **Check for misplaced content** — Flag entries that belong in repo-tracked files:
   - Standing instructions or workflow rules → should be in CLAUDE.md or `.claude/rules/`
   - Coding conventions or patterns → should be in `.claude/rules/`
   - Architecture or system design → should be in `docs/`
   - Content that duplicates CLAUDE.md, `.claude/rules/`, or `docs/` files

6. **Check for contradictions** — Compare memory entries against:
   - CLAUDE.md anti-patterns and required workflow
   - `.claude/rules/*.md` content
   - Other memory entries in the same directory

7. **Estimate token usage**:
   - Count total characters across all memory files
   - Estimate tokens (~4 characters per token)
   - Warn if total exceeds 8,000 tokens, error if exceeds 10,000 tokens

8. **Check for orphaned worktree memory** — Look for `*--claude-worktrees-*/memory/` directories under `~/.claude/projects/` for the current project. Flag any that exist.

9. **Present findings** — Use the output format below. Do NOT modify any files without HC approval.

## Output Format

```markdown
## Memory Review Report

### Summary
- **Project:** [project name]
- **Memory directory:** [path]
- **Total files:** [count]
- **Total lines:** [count]
- **Estimated tokens:** [count] / 10,000 budget
- **MEMORY.md lines:** [count] / 200 limit
- **Overall health:** [healthy | needs attention | critical]

### MEMORY.md Health
- [Findings — line count, index-only compliance, misplaced content]

### Frontmatter Compliance
| File | name | description | type | Status |
|------|------|-------------|------|--------|
| [file] | [present/missing] | [present/missing] | [present/missing] | [pass/fail] |

### Stale Entries
| File | Reference | Current Status | Recommendation |
|------|-----------|---------------|----------------|
| [file] | [issue/PR #] | [open/closed/merged] | [keep/update/remove] |

### Misplaced Content
| File | Content | Should Be In | Recommendation |
|------|---------|-------------|----------------|
| [file] | [description] | [CLAUDE.md / .claude/rules/ / docs/] | [move/remove] |

### Contradictions
| File | Entry | Conflicts With | Recommendation |
|------|-------|---------------|----------------|
| [file] | [entry] | [source] | [resolve how] |

### Token Budget
- **Total:** [tokens] / 10,000
- **Breakdown:** [per-file token estimates]

### Orphaned Worktree Memory
- [List any found, or "None"]

### Recommended Actions
1. [Prioritized list of specific actions — what to remove, update, or move]
```

## Important

- Do NOT modify any memory files automatically — always present recommendations for HC approval first
- If `gh` commands fail (e.g., not authenticated for a repo), skip the staleness check for those references and note it in the report
- Run this command periodically (quarterly baseline) or after closing major issues/PRs
