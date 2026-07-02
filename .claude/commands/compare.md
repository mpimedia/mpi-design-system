Compare this repo's agent configuration standards against the Optimus template (or another MPI project): $ARGUMENTS

This is the periodic drift-check for `docs/standards/cross-repo-sync.md` — run it when Optimus's agent config changes, or quarterly as a baseline.

## Steps

1. **Resolve the comparison target**:
   - Default (no argument, or `optimus`): compare **this repo** against Optimus, the canonical template
   - Read `.claude/projects.json` to find a project by name (markaz, sfa, garden, harvest, design_system)
   - Read `.claude/projects.local.json` for local paths if available
   - If no local path, use `gh api` to fetch files from the GitHub repo

2. **Read Optimus shared standards** (the source of truth):
   - `CLAUDE.md` — shared sections: Permissions and Autonomy, Commit and PR Standards, Agent Attribution, Required Workflow, Commands, Testing
   - `AGENTS.md` — shared sections: Pre-Commit Requirements, PR Instructions, Review Guidelines, Agent Attribution
   - `.claude/settings.json` — attribution block, hooks, enabledPlugins
   - `.claude/hooks/enforce-branch-creation.sh`
   - `.claude/commands/` — all command templates
   - `.claude/rules/` — rule files (note which are app-only: backend.md, migrations.md, security.md)
   - `docs/standards/` — development-lifecycle.md, code-review.md, memory-management.md, cross-repo-sync.md
   - `.githooks/` + `bin/guard-protected-branch` + `bin/install-git-hooks`

3. **Read this repo's corresponding files** (if they exist)

4. **Compare and report** — applying engine scope (per `docs/standards/cross-repo-sync.md`):
   - Which shared files are missing here
   - Which shared files exist but have drifted from the Optimus version
   - Which engine-specific tailorings are correct (deliberately omitted app-only material is NOT drift)
   - Specific lines or sections that differ

5. **Generate recommendations**:
   - Files to sync (machinery: commands, hooks, settings structure — converge tightly)
   - Files to adapt (domain content: rules, standards — engine-tailored, structure only)
   - Files to leave alone (correct engine tailorings)

## Output Format

```markdown
## Standards Comparison: Optimus vs [Target]

### Missing Files
- [files that should exist but don't]

### Drifted Files
| File | Drift Summary | Sync or Adapt? |
|------|--------------|----------------|
| ... | ... | ... |

### Correctly Tailored
- [engine-specific files that are appropriately different, with rationale]

### Recommended Actions
1. [specific action with file and section]
2. ...
```

Display the report in the conversation. If the HC approves, offer to create a PR with the sync changes.
