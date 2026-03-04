Compare the agent configuration standards between Optimus and the target MPI project: $ARGUMENTS

## Steps

1. **Resolve the target project path**:
   - Read `.claude/projects.json` to find the project by name (avails, sfa, garden, harvest)
   - Read `.claude/projects.local.json` for local paths if available
   - If no local path, use `gh api` to fetch files from the GitHub repo

2. **Read Optimus shared standards** (the source of truth):
   - `CLAUDE.md` — shared sections: Permissions and Autonomy, Commit and PR Standards, Agent Attribution, Required Workflow, Commands, Testing, Key Gems
   - `AGENTS.md` — shared sections: Pre-Commit Requirements, PR Instructions, Review Guidelines, Agent Attribution
   - `.claude/hooks/enforce-branch-creation.sh`
   - `.claude/commands/` — all command templates

3. **Read the target project's corresponding files** (if they exist)

4. **Compare and report**:
   - Which shared files are missing in the target project
   - Which shared files exist but have drifted from the Optimus version
   - Which project-specific sections are correctly customized
   - Specific lines or sections that differ

5. **Generate recommendations**:
   - Files to copy as-is (pure shared standards)
   - Files to merge (shared skeleton + project-specific content)
   - Sections to update in existing files

## Output Format

```markdown
## Standards Comparison: Optimus vs [Target Project]

### Missing Files
- [files that should exist but don't]

### Drifted Files
| File | Drift Summary |
|------|--------------|
| ... | ... |

### Correctly Customized
- [project-specific files that are appropriately different]

### Recommended Actions
1. [specific action with file and section]
2. ...
```

Display the report in the conversation. If the HC approves, offer to create a PR in the target repo with the sync changes.
