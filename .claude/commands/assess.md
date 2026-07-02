Review GitHub issue #$ARGUMENTS and prepare an assessment for the Human Contributor (HC).

This is **Stage 1** of the MPI Development Lifecycle (see `docs/standards/development-lifecycle.md`).

## Steps

1. **Read the issue** using `gh issue view $ARGUMENTS --comments` — capture the title, description, labels, milestone, and any existing comments
2. **Check for duplicates and related work**:
   - Search for related issues: `gh issue list --search "<keywords from issue title>" --state all --limit 10`
   - Search for related PRs: `gh pr list --search "<keywords from issue title>" --state all --limit 10`
   - If duplicates or related work are found, note them in the assessment and ask the HC whether to proceed or consolidate
3. **Read design-system context**:
   - Start with `CLAUDE.md` and `AGENTS.md` for engine conventions
   - Read the component catalog if the issue touches UI: `catalog/elements/`, `catalog/components/`, `catalog/patterns/`, `catalog/layouts/`
   - Read token documentation if the issue touches visual values: `tokens/colors.md`, `tokens/typography.md`, `tokens/spacing.md`, `tokens/bootstrap-overrides.md`
4. **Explore the codebase** — read the files and systems that would be affected. Trace components (`app/components/mpi_design_system/admin/`), Stimulus controllers (`app/javascript/mpi_design_system/controllers/`), SCSS tokens (`app/assets/stylesheets/mpi_design_system/`), specs, and Lookbook previews. Focus on understanding the current state.
5. **Check test coverage** for affected areas — look at existing component specs in `spec/components/` to understand what's covered and what gaps a change might introduce
6. **Identify project-specific concerns**:
   - Does this add a component? → Check the catalog first — does an existing component or variant already cover it?
   - Does this change a component's API? → Consider consuming apps (Markaz, SFA, Garden, Harvest); flag breaking changes
   - Does this touch visual values? → Use design tokens and Bootstrap 5 classes, never arbitrary values
   - Does this add JS behavior? → Stimulus controller, exported via `app/javascript/mpi_design_system/index.js`
   - Does this change what ships in the gem? → Check the gemspec `files` glob (`{app,config,lib}/**/*`)
   - Does this affect accessibility? → WCAG 2.1 AA, keyboard access, ARIA, contrast ratios
7. **Research ecosystem solutions** — before proposing custom implementations:
   - Check if Bootstrap 5 already solves the problem (built-in components, utilities)
   - Check if ViewComponent or Stimulus conventions already cover it (slots, collections, targets, values)
   - List what was considered in the assessment, even if rejected
8. **Identify unknowns** — list anything ambiguous or underspecified in the issue
9. **Ask clarifying questions** — if there are gaps in the requirements, ask the HC before proceeding (ask, don't guess)

## Complexity Criteria

- **Small** — 5 files or fewer, single component or token change, no API changes
- **Medium** — 6-15 files, new component with spec and preview, touches 2-3 areas, single agent
- **Large** — 15+ files, cross-cutting changes (multiple components, JS + SCSS + templates), consuming-app impact → recommend `/orch` for parallel agents

**Compressed workflows** (HC decides, not AC): Trivial fixes (typos, config) may skip Plan; documentation-only changes may skip Assess and Plan. See lifecycle doc for details.

## Rules References

When assessing, consult these rules as relevant:
- `.claude/rules/frontend.md` — ViewComponent, Stimulus, and Bootstrap 5 patterns
- `.claude/rules/testing.md` — Testing coverage requirements (affects scope estimates)
- `.claude/rules/dependencies.md` — Dependency update policy (affects risk assessment)

## Output Format

Post the assessment as a comment on the issue using `gh issue comment $ARGUMENTS --body "..."`.

Also display the assessment in the conversation so the HC can discuss before choosing an option.

Use this template for the GitHub comment:

```markdown
## Issue Assessment

### Summary
[What the issue is asking for in clear terms]

### Systems Affected
| System | Files/Areas | Impact |
|--------|-------------|--------|
| [e.g., Components] | [e.g., `app/components/mpi_design_system/admin/badge/`] | [e.g., New variant] |

### Complexity: [Small | Medium | Large]
- [Key factors driving complexity]

### Related Issues/PRs
- [List any related work found, or "None found"]

### Project-Specific Considerations
- [Catalog overlap, consuming-app impact, token usage, accessibility — or "None"]

### Open Questions
- [Anything ambiguous that needs HC input — or "None"]

### Risk Assessment
- [What could go wrong, what's the blast radius of this change]

### Implementation Options

#### Option A: [Name]
- **Approach:** [Description]
- **Pros:** [Benefits]
- **Cons:** [Drawbacks]
- **Risk:** [What could go wrong with this approach]
- **Estimated scope:** [files, specs, previews]

#### Option B: [Name]
- **Approach:** [Description]
- **Pros:** [Benefits]
- **Cons:** [Drawbacks]
- **Risk:** [What could go wrong with this approach]
- **Estimated scope:** [files, specs, previews]

### Recommendation
Option [X] because [rationale].

### Next Step
HC: Reply with your chosen option and run `/cplan $ARGUMENTS` to generate the implementation plan.

— Claude Code (Fable 5)
```

## Quality Standard

Before posting the assessment, self-review:
- Did I research the codebase or just guess based on the issue description?
- Are my options genuinely different approaches, or variations of the same thing?
- Did I identify risks that could waste time during implementation?
- Would a critical reviewer find gaps in my analysis?

## Attribution

Include `— Claude Code (Fable 5)` (or current model) at the bottom of the GitHub comment per CLAUDE.md agent attribution requirements.
