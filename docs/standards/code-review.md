# MPI Design System Code Review Standards

These standards apply to all reviewers: Human Contributors (HC), AI Contributors (AC), and external Reviewers. The severity framework below is the canonical expansion of the "Review Guidelines" summary in `AGENTS.md` — keep the two consistent (see `docs/standards/cross-repo-sync.md`).

## Automated Checks (Must Pass)

Before any review begins, both required checks must pass:

- `bundle exec rubocop -a` — zero offenses
- `bundle exec rspec` — zero failures

These two are the engine's complete required-check set. App repos in the MPI suite run additional app-only checks; their absence here is deliberate — see `docs/standards/cross-repo-sync.md`.

## ViewComponents

- [ ] Components follow the `MpiDesignSystem::Admin::Name::Component` pattern at `app/components/mpi_design_system/admin/`
- [ ] Each component is a `component.rb` (Ruby logic) + `component.html.erb` (template) pair
- [ ] Slots use `renders_one` / `renders_many`
- [ ] Conditional logic lives in the Ruby class, not the template
- [ ] Lookbook preview added or updated in `spec/components/previews/`

## Styling and Tokens

- [ ] Bootstrap 5 classes for all styling — no custom CSS unless absolutely necessary
- [ ] Values come from design tokens (`_tokens.scss`, `tokens/` docs) — no arbitrary colors, sizes, or spacing
- [ ] Semantic color classes (`btn-primary`, `text-danger`) over custom hex values
- [ ] Responsive by default — Bootstrap grid and responsive utilities

## Stimulus / JavaScript

- [ ] Interactive behavior uses Stimulus controllers in `app/javascript/mpi_design_system/controllers/`
- [ ] New controllers are registered in `controllers/index.js` so `registerMpiControllers` picks them up
- [ ] Hotwire stack only — no other client-side frameworks

## Security

- [ ] User-supplied content is escaped in ERB templates — no `raw` / `html_safe` without sanitization
- [ ] External links pair `target: "_blank"` with `rel: "noopener noreferrer"`
- [ ] No secrets or credentials in code, specs, or fixtures

## Accessibility

- [ ] WCAG 2.1 AA compliance minimum
- [ ] All interactive elements keyboard-accessible
- [ ] Appropriate ARIA roles and labels
- [ ] Contrast: 4.5:1 for normal text, 3:1 for large text
- [ ] Visible focus indicators

## Gem Packaging and Consuming Apps

- [ ] Changes to what ships in the gem are checked against the gemspec `files` glob (`{app,config,lib}/**/*`)
- [ ] Breaking component API changes are flagged — they affect all consuming apps (Markaz, SFA, Garden, Harvest)

## Tests

- [ ] Component specs cover every variant, size, and state with assertions on rendered output (`render_inline` + Capybara matchers) — not just "it renders"
- [ ] Edge cases: invalid/missing params, empty collections, boundary values
- [ ] Interactive behavior exercised through the dummy app (`spec/dummy/`)
- [ ] Accessibility assertions (ARIA attributes, keyboard access) where relevant
- [ ] See `.claude/rules/testing.md` for the full definition of done

## Documentation

- [ ] Catalog (`catalog/`) and token docs (`tokens/`) updated when the visual language changes
- [ ] `CLAUDE.md` updated if new patterns or commands are introduced
- [ ] Commit messages follow the format in `CLAUDE.md`

## Agent Attribution

- [ ] Every commit has a `Co-Authored-By` trailer for the agent that wrote it
- [ ] PR description includes agent attribution footer
- [ ] Issue/PR comments include an attribution line

## Severity Priority

When triaging review findings, classify each issue by severity. These definitions match the "Review Guidelines" in `AGENTS.md`.

### P0 — Must Fix (blocks merge)

- Security vulnerabilities (XSS in component templates, missing escaping)
- Broken tests or tests that don't test what they claim
- Accessibility violations (missing ARIA attributes, poor contrast)

### P1 — Should Fix (request changes; merge after fix)

- Pattern violations (components not following the `MpiDesignSystem::Admin::Name::Component` convention)
- Missing tests for new components
- Incorrect Bootstrap class usage
- Missing responsive behavior

### P2 — Consider (suggest; fix or explain why not — HC decides)

- Naming improvements
- Code organization suggestions
- Additional component variants or states

### Discussion

- Architectural questions, alternative approaches, clarification requests — not defects; resolve in conversation before or alongside the fix cycle

### Resolution Rules

- All P0 and P1 findings must be resolved before the SOW is generated (Stage 5 of `docs/standards/development-lifecycle.md`)
- Do not argue with Reviewer findings unless factually incorrect — if the Reviewer flags it, it's a real gap
