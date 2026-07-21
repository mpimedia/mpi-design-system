# Self-Review Rules

Applies to: `app/**`, `spec/**`, `lib/**`

## Before Declaring Work Done

Every time you finish writing or modifying code, run this checklist before telling the
HC the work is complete:

- [ ] **Plan alignment** — does the change match the issue/plan? Any scope creep, and any
      planned item silently dropped?
- [ ] **Spec + preview per component** — does every component change have a corresponding
      spec update and Lookbook preview update?
- [ ] **Test quality** — are assertions meaningful? For each test: "If this test passed
      but the component was broken, would I know?" A spec that only checks the component
      renders is a false green
- [ ] **Edge cases** — invalid params, nil values, empty content, fallback defaults
- [ ] **No debug leftovers** — no `puts`, `console.log`, `binding.irb`, commented-out
      code, or "TODO" / "needs manual testing" comments. Remove them and write the test
- [ ] **Catalog and token compliance** — does the component match its `catalog/` spec?
      Are all values Bootstrap classes or tokens from `_tokens.scss` / `tokens/*.md`
      (no invented colors, sizes, or spacing)?
- [ ] **Accessibility pass** — keyboard access, ARIA roles/labels, 4.5:1 / 3:1 contrast,
      visible focus indicators
- [ ] **Executed every check you wrote in prose** — a command, gate, or runbook step in a
      PR description, comment, or doc is a check no suite will ever run for you. Paste it
      into a shell, feed it the *failure* case, and confirm it aborts. Verifying only the
      happy path cannot distinguish a working gate from one that always passes — see
      `.claude/rules/testing.md` ("A check written in documentation is still a check")
- [ ] **Both required checks green** — the engine has exactly two, and both must pass
      before any commit or push (no Brakeman or bundler-audit here):
      - `bundle exec rubocop -a` — zero offenses
      - `bundle exec rspec` — zero failures

## Never Deflect Work

- Never say "needs manual testing" without proving `render_inline` + Capybara matchers
  can't cover it
- Never produce minimal assertions and declare the work complete
- Never cut corners on the last 20% — edge cases, fallback behavior, and accessibility
  are where a design system earns its keep, because every consuming app inherits them

## Quality Bar

Think like a senior engineer whose component will render in four applications:

- Would you be comfortable if a critical reviewer examined every line?
- Did you test the component's behavior, or that the code runs without errors?
  Those are different things.
- Are you done, or just at the point where it's tempting to stop?
