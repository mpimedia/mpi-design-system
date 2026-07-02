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
   contrast-pairing classes (e.g. `bg-warning` renders with `text-dark`)
6. **A matching Lookbook preview** exists and actually **renders** — not merely eager-loads.
   Eager-load loads the preview *constant* but never renders it, so a missing template
   (`render_with_template(template: "…")`) or a bad component kwarg ships green under a fully
   passing suite. Verify by rendering every scenario, e.g.
   `ViewComponent::Preview.all.each { |p| p.instance_methods(false).each { |s| render_preview(s, from: p) } }`
   — a sweep like this caught two preview defects the 500-example suite missed during the
   #103 rename. (An enforcing spec for this gate lands with the #111 preview fixes, once every
   scenario renders green.)

## Naming Convention

Follow the `describe` / `context` / `it` structure:

```ruby
RSpec.describe MpiDesignSystem::Admin::Badge::Component, type: :component do
  context "with an invalid color" do
    it "falls back to the primary color" do
      render_inline(described_class.new(label: "Test", color: :invalid))

      expect(page).to have_css("span.badge.bg-primary")
    end
  end
end
```

- `context` — specific scenario or state (`when`, `with`, `without`)
- `it` — one outcome, with a description that states the expected behavior
- Use `let` for setup, not instance variables

## Anti-Patterns

- Never assert only that a component "renders without error" — that is a false green
- Never test private methods — test through the rendered output
- Never reference models, the database, or request specs — the engine has none (browser
  feature specs exist, but only for genuine JS behavior — see Stack; default to `render_inline`)
- Never claim a behavior "needs manual testing" without first attempting it with
  `render_inline` and Capybara matchers
- Never skip edge cases because "they're unlikely"
