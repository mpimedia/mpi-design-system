# Testing Rules

Applies to: `spec/**`

## Stack

- RSpec (`rspec-rails`) with ViewComponent test helpers and Capybara matchers —
  `spec/spec_helper.rb` includes `ViewComponent::TestHelpers` and `Capybara::RSpecMatchers`
  for `type: :component` specs
- Render with `render_inline(described_class.new(...))`, assert with Capybara matchers
  (`expect(page).to have_css(...)`, `have_text`, `have_link`)
- The engine has no database and no models — the dummy app (`spec/dummy/`) boots without
  ActiveRecord, so there is no FactoryBot, no fixtures, and no model/request specs
- **Default to `render_inline`** for Stimulus behavior — assert the rendered
  `data-controller` / `data-*-target` / `data-action` attributes. A render-level spec is
  fast, needs no browser, and proves the ERB emits the right wiring.
- **Browser-level feature specs are supported** for the (rare) behavior `render_inline`
  cannot prove — that JavaScript actually *runs* (a Stimulus controller binds, the DOM
  mutates on interaction). The test Gemfile group includes `selenium-webdriver`, and
  `spec/support/capybara.rb` registers a headless-Chrome driver (`Capybara.javascript_driver`)
  and switches drivers on `js: true`. Write such a spec as `type: :feature, js: true` under
  `spec/features/`. **Prerequisite:** a feature spec renders a real Propshaft-served
  esbuild/dart-sass bundle, so the gitignored `spec/dummy/app/assets/builds/*` must be built
  first — CI builds them and sets `MDS_ASSETS_PREBUILT=1`; locally `spec/support/capybara.rb`
  builds them on demand. Reserve the browser for genuine JS behavior; do not reach for it
  when a `render_inline` assertion suffices. (Reference: the `mpi--tag-input` feature spec, #103.)
- **The preview-render sweep must stay asset-free.** `render_preview` renders through a layout,
  and the dummy app's application layout calls `stylesheet_link_tag` / `javascript_include_tag`
  — Propshaft raises on those when the gitignored `spec/dummy/app/assets/builds/*` bundle is
  absent (it is built only for feature specs). So the sweep
  (`spec/components/previews/preview_rendering_spec.rb`) renders through a bare, asset-free
  layout (`spec/dummy/app/views/layouts/component_preview.html.erb`) scoped to the test env via
  `config.view_component.previews.default_layout` in `spec/dummy/config/environments/test.rb`.
  Keep it that way — do not "fix" a sweep failure by building assets, which recouples a
  unit-level render gate to the asset pipeline; development Lookbook keeps the full application
  layout. (#111.)
- **Prove hidden-on-load with computed style, not `visible: :hidden`.** Capybara's
  `have_css(..., visible: :hidden)` can false-pass on an empty/zero-size element even when the
  CSS meant to hide it was dropped. To prove an element is actually hidden in a browser spec,
  read the computed style — `page.evaluate_script("getComputedStyle(el).display")` — as the
  `mpi--tag-input` feature spec does. (#111.)

## Layout

- Specs mirror components exactly: `spec/components/mpi_design_system/admin/<name>/component_spec.rb`
  for `app/components/mpi_design_system/admin/<name>/component.rb`
- Lookbook previews live at `spec/components/previews/mpi_design_system/admin/<name>/component_preview.rb`
  and inherit `ApplicationComponentPreview` (base class at
  `spec/components/previews/application_component_preview.rb`, which inherits
  `ViewComponent::Preview`). Use Lookbook annotations (`@label`, `@display`) and
  `render_with_template` for multi-example previews
- `spec/dummy/` is the integration harness: it mounts the engine and serves Lookbook at
  `/lookbook` in development (`spec/dummy/config/initializers/lookbook.rb` points preview
  paths at `spec/components/previews`)
- CI runs with `CI=true`, which makes the dummy app eager-load every component and preview
  *constant* — a spec suite that passes locally can still fail CI if a constant or file path
  is broken, so keep names and paths exact. **Eager-load does not _render_ previews**, so a
  preview that references a missing template or passes a bad kwarg to a component eager-loads
  clean yet raises only at render time — gate previews by rendering them (see Definition of
  Done #6), never by eager-load alone

## Definition of Done for a Component Spec

No component is complete until its spec covers:

1. **Default render** — renders with only the required params
2. **Every option exercised** — each variant, size, state, and color the component accepts
   has at least one example
3. **Meaningful assertions** — assert the classes, text, and attributes that make the
   component correct, not merely that it renders. Ask: "If this test passed but the
   component was broken, would I know?"
4. **Edge cases** — missing/invalid params (e.g. an invalid color falls back to the
   default), empty or nil content, empty collections
5. **Accessibility assertions where relevant** — `aria-label`s, roles, and
   derived contrast classes (e.g. `text-bg-warning` yields dark text for AA contrast)
6. **A matching Lookbook preview** exists and actually **renders** — not merely eager-loads.
   Eager-load loads the preview *constant* but never renders it, so a missing template
   (`render_with_template(template: "…")`) or a bad component kwarg ships green under a fully
   passing suite. This gate is enforced by `spec/components/previews/preview_rendering_spec.rb`,
   which renders every Lookbook scenario and fails if any raises:
   `ViewComponent::Preview.all.each { |p| p.examples.each { |s| render_preview(s, from: p) } }`
   — the sweep that caught two preview defects the 500-example suite missed during the #103
   rename (#111). It enumerates `preview.examples` (ViewComponent's own
   `public_instance_methods(false)`, which excludes private preview helpers) and renders through
   a bare, asset-free layout to stay hermetic (see **Stack**'s preview-sweep note).

## Naming Convention

Follow the `describe` / `context` / `it` structure:

```ruby
RSpec.describe MpiDesignSystem::Admin::Badge::Component, type: :component do
  context "with an invalid color" do
    it "falls back to the primary color" do
      render_inline(described_class.new(label: "Test", color: :invalid))

      expect(page).to have_css("span.badge.text-bg-primary")
    end
  end
end
```

- `context` — specific scenario or state (`when`, `with`, `without`)
- `it` — one outcome, with a description that states the expected behavior
- Use `let` for setup, not instance variables

## Two False Greens Worth Naming

DoD #3 asks "if this test passed but the component was broken, would I know?" Two specific
shapes answer *no* while looking thorough. Both shipped green in #136 and were caught only in
review.

**1. Asserting a value the implementation would produce by a different path.**

```ruby
# FALSE GREEN — "button" is also what the derivation emits, so an implementation
# that ignored `role:` entirely passes this identically.
render_inline(described_class.new(label: "X", href: "/x", method: :delete, role: "button"))
expect(page).to have_css("a[role='button']")

# REAL — a value the derivation can never produce, so only an echoed override passes.
render_inline(described_class.new(label: "X", href: "/x", method: :delete, role: "menuitem"))
expect(page).to have_css("a[role='menuitem']")
```

When testing an override, a fallback, or a passthrough, pick a value the *other* branch cannot
generate. If the expected value is reachable two ways, the test does not distinguish them.

**2. An absence assertion with nothing proving the element rendered.**

```ruby
# FALSE GREEN — passes if the anchor renders without the attribute, AND passes if
# nothing rendered at all, AND passes if a <button> rendered instead.
expect(page).not_to have_css("a[role]")

# REAL — pins the element first, then the absence.
expect(page).to have_css("a.btn.btn-primary[href='/contacts/1']", text: "View")
expect(page).not_to have_css("a[role]")
```

Every `not_to have_css` needs a positive assertion beside it. The same applies to
`not_to have_text`.

**Related:** when a constant drives behavior (`ACTION_METHODS`, `COLORS`, `SIZES`), loop it
rather than spot-checking one member — otherwise a typo in the constant ships green.

## A Guard Is Not Real Until You Have Watched It Fail

The two shapes above are assertions that *can* fail but don't discriminate. This is the
third shape: an assertion that **cannot fail at all**, and the sentence next to it claiming
it can.

`spec/packaging/changelog_spec.rb` asserted `expect(changelog).to include("0.2.0")` under an
example named "documents the 0.2.0 release". A changelog keeps its history, so that passed
forever no matter what was being released — green at v0.2.0, still green at v0.6.0, and it
would have been green at v9.0.0. A release that forgot its CHANGELOG entry entirely passed.
The example did not test the release; it tested that the past still existed (#127).

**The rule: for every element you call load-bearing, remove it and watch a test go red.**
Not "reason that it would" — run it. In #127 the fix itself broke this rule twice, and both
were caught only by execution:

- The header comment said the `^` anchor was load-bearing. Removing it left the entire suite
  green — the anchor was documented, not tested. Fixed by adding a mid-line/indented example.
- It said the `[ \t]+` (not `\s+`) definition scan was load-bearing. Replacing it with `\s+`
  also left the suite green. Fixed by adding a fixture whose destination was deleted.

```ruby
# NOT A GUARD — the pattern's strictness is asserted in a comment and nowhere else.
# Replace [ \t]+ with \s+ and nothing reddens.
let(:definition_pattern) { /^\[([^\]]+)\]:[ \t]+\S/ }

# REAL — a fixture that only the strict form rejects. Under \s+ this example fails,
# because \s crosses the blank line and takes the next line's first character as the URL.
it "counts the well-formed definition but not the destination-less one" do
  expect("[1.0.0]: https://example.test/v1".scan(definition_pattern).flatten).to eq([ "1.0.0" ])
  expect("[1.0.0]:\n\n<!-- gone -->\n".scan(definition_pattern).flatten).to be_empty
end
```

Note the positive half: without it the example passes on a pattern that matches nothing at
all. Proving a guard can fail does not exempt it from False Green #2.

Two practical rules when mutation-testing:

- **Isolate the spec file.** `version_spec.rb` independently pins the version, so bumping
  `VERSION` reddens it regardless — a full-suite red proves nothing about the guard you are
  testing. Run the single file.
- **Never mutate with `git stash`** (shared stash stack, see `CLAUDE.md`). Edit, capture the
  failure, revert, then confirm `git diff` shows only the intended change.

**Verify claims about a pattern by executing it, not by reading it.** #127's plan review
produced a confident, wrong claim that `\[`/`\]` form a character class; a three-line Ruby
script refuted it in seconds. The same script found two real defects reading had missed.

This is the spec-level twin of `.claude/rules/frontend.md`'s "prove a new build guard by
breaking it" (#136) and its "verify a contrast rule against an external oracle, never against
itself" (#130). Same failure, three layers: a check that grades its own homework, a check that
never fails, and a claim nobody executed.

## Anti-Patterns

- Never assert only that a component "renders without error" — that is a false green
- Never assert a value the implementation could produce by another path, and never leave a
  `not_to have_css` unpaired with a positive assertion — see **Two False Greens** above
- Never describe part of an assertion as load-bearing without a test that reddens when it is
  removed, and never pin a literal that the artifact under test retains forever (a version, a
  date, an id) — see **A Guard Is Not Real Until You Have Watched It Fail** above
- Never test private methods — test through the rendered output
- Never reference models, the database, or request specs — the engine has none (browser
  feature specs exist, but only for genuine JS behavior — see Stack; default to `render_inline`)
- Never claim a behavior "needs manual testing" without first attempting it with
  `render_inline` and Capybara matchers
- Never skip edge cases because "they're unlikely"
