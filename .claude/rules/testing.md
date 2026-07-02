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
- There is **no Selenium or system-spec infrastructure in this repo** — the test Gemfile
  group contains only `rspec-rails` and `capybara` (rack-only matchers). Do not write
  `js: true` or `type: :system` specs, and do not reference browser drivers that are not
  in the Gemfile. Stimulus behavior is verified by asserting the rendered `data-controller`
  / `data-*-target` / `data-action` attributes

## Layout

- Specs mirror components exactly: `spec/components/admin/<name>/component_spec.rb`
  for `app/components/admin/<name>/component.rb`
- Lookbook previews live at `spec/components/previews/admin/<name>/component_preview.rb`
  and inherit `ApplicationComponentPreview` (base class at
  `spec/components/previews/application_component_preview.rb`, which inherits
  `ViewComponent::Preview`). Use Lookbook annotations (`@label`, `@display`) and
  `render_with_template` for multi-example previews
- `spec/dummy/` is the integration harness: it mounts the engine and serves Lookbook at
  `/lookbook` in development (`spec/dummy/config/initializers/lookbook.rb` points preview
  paths at `spec/components/previews`)
- CI runs with `CI=true`, which makes the dummy app eager-load every component and preview
  constant — a spec suite that passes locally can still fail CI if a constant or file path
  is broken, so keep names and paths exact

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
6. **A matching Lookbook preview** exists and its constants load (CI eager-load will
   catch a broken preview)

## Naming Convention

Follow the `describe` / `context` / `it` structure:

```ruby
RSpec.describe Admin::Badge::Component, type: :component do
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
- Never reference models, the database, or request/feature specs — the engine has none
- Never claim a behavior "needs manual testing" without first attempting it with
  `render_inline` and Capybara matchers
- Never skip edge cases because "they're unlikely"
