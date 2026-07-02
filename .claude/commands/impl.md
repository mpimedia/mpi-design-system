Execute the implementation plan for GitHub issue #$ARGUMENTS.

This is **Stage 3** of the MPI Development Lifecycle (see `docs/standards/development-lifecycle.md`).

## Steps

1. **Read the issue, plan, and agent strategy** using `gh issue view $ARGUMENTS --comments`
2. **Check current branch** — if on `main`, create the feature branch specified in the plan
3. **Execute each task** in the planned order:
   - Write or modify code following patterns in `CLAUDE.md` and `.claude/rules/frontend.md`
   - Write or update specs following the testing strategy defined in the plan and `.claude/rules/testing.md`
   - Read existing code in the relevant area before writing — discover patterns from the codebase
   - Use ViewComponent conventions (`MpiDesignSystem::Admin::Name::Component` pattern, `component.rb` + `component.html.erb`)
   - Follow Bootstrap 5 classes for all styling; use design tokens from `_tokens.scss`, never arbitrary values
   - Use Stimulus controllers for interactive behavior, exported via `app/javascript/mpi_design_system/index.js`
   - Add a Lookbook preview for every new component (`spec/components/previews/`)
4. **Run quality checks**:
   ```bash
   bundle exec rubocop -a
   bundle exec rspec
   ```
   Fix any failures before proceeding.
5. **Self-review before PR** — apply `.claude/rules/self-review.md` checklist and fix anything that fails:
   - [ ] Every item in the plan is implemented
   - [ ] Every test scenario from the plan's testing strategy is covered
   - [ ] Component specs: rendering, every variant/size/state, meaningful assertions on output
   - [ ] Lookbook preview added or updated for changed components
   - [ ] Accessibility: ARIA attributes, keyboard access, contrast (WCAG 2.1 AA)
   - [ ] "What would a critical external reviewer flag here?" — read every test and ask: "If this test passed but the feature was broken, would I know?"
   - [ ] No "TODO" or "needs manual testing" comments — if something seems untestable, research the stack (Capybara, ViewComponent test helpers, the dummy app) before claiming it
   - [ ] Both checks pass (`bundle exec rubocop -a`, `bundle exec rspec`)
6. **Commit with detailed message** following the format in `CLAUDE.md`
7. **Push and create PR**:
   - Push branch with `git push -u origin <branch>`
   - Create PR with `gh pr create` using the format in `CLAUDE.md`
   - Link to the issue with `Closes #$ARGUMENTS`
8. **Post implementation notes on the PR** as a comment documenting what was done, decisions made during implementation, and anything the reviewer should pay attention to
9. **Post a brief update on the issue** linking to the PR (e.g., "Implementation PR: #NNN")

## Next Step

After PR is created, HC runs `/verify $ARGUMENTS` for Stage 4 self-review against the plan.

## Quality Gates

Do NOT create the PR until:
- [ ] `bundle exec rubocop -a` passes with no offenses
- [ ] `bundle exec rspec` passes with no failures
- [ ] All planned tasks are complete
- [ ] Self-review checklist (step 5) is complete
- [ ] Commit message follows CLAUDE.md format
- [ ] PR description includes Summary, Changes, Technical Approach, Testing, and Checklist sections

## Attribution

Include `— Claude Code (Fable 5)` (or current model) at the bottom of any GitHub comments.
