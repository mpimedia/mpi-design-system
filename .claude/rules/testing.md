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

**Corollary — a conversion must guard what *survives*, not only what it removed.** When a change
strips some of an element's output but keeps the rest, guards written to prove the *removed* part
is gone can all pass while the *kept* part is silently deletable. This passes #2's own rule — the
element is pinned, then absence is asserted — yet still ships green when the survivor vanishes,
because nothing asserts the survivor is present. #149 converted `Pagination` from inline colour to
utilities and kept the geometry (`width: 32px`, `font-size: 13px`, `font-weight: 500`, the nav's
`padding-top`) inline. Its three guards each pinned the nav and the active page, then asserted *no
colour / no hex / no fixed-scheme utility* — all correct, all green even after deleting
`results_text_styles` outright or dropping `font-weight` from `page_btn_styles`, because the guards
police what left, not what stayed.

```ruby
# The guards prove colour is GONE. Nothing proves the geometry STAYED —
# empty `results_text_styles` and every guard is still green.
it "keeps the non-colour geometry that has no Bootstrap equivalent" do
  render_inline(described_class.new(current_page: 20, total_pages: 47, total_count: 1175, max_links: 7, url_builder: url_builder))
  expect(page).to have_css("nav[aria-label='Pagination'][style*='padding-top: 12px']")
  expect(page).to have_css("span.text-primary-emphasis[style*='font-size: 13px']", text: /Showing/)
  expect(page).to have_css("span[aria-current='page'][style*='width: 32px'][style*='font-weight: 500']", text: "20")
end
```

Watched failing both ways before trusting it: emptying `results_text_styles` and removing
`font-weight: 500` each reddens exactly this example. The rule: after a conversion, list what the
element still emits and pin it, or the next edit that removes it ships green.

**Related — pin the *complete* surviving inline style, not one representative declaration.** The
corollary says "list what the element still emits and pin it" — but a guard that pins *one*
representative survivor per element leaves the rest deletable-green, and that gap survives even a
careful review. #152 converted `FilterPanel`'s inline hex to utilities and kept each element's
geometry/layout/typography inline; the first guard pinned one declaration per helper (panel
`min-width`, title `font-weight`+`letter-spacing`, button `justify-content`+`width`, …) — and passed
the author's self-review **and** the external *plan* review, yet left panel `border-radius`/`padding`,
header/option/chevron `font-size`, and the button's `cursor`/`text-align` deletable without a red
test (caught only by the external *diff* review). For an inline-style→utility conversion, assert each
converted element's **complete** surviving inline style via exact equality —
`have_css("aside.bg-body.border[style='border-radius: 8px; padding: 0; min-width: 220px']")` — not
substring `[style*='…']` pins, which police only the fragments you happened to name. Exact match is
brittle in exactly the intended way: any dropped, added, or reordered survivor reddens, so a
deliberate geometry change updates the test on purpose. (`render_inline` emits the style string
verbatim — Nokogiri preserves attribute *values*, only lowercasing attribute *names* — so the exact
string is stable.) Proven by breaking it: removing `border-radius: 8px` (unguarded under the
representative version) reddens the exact-match example. (#152.)

**Related — a descendant selector false-passes when the class lands on an ancestor; pin the
structural relationship with a child combinator.** `have_css("div.text-body input[...]")` proves only
that *some* ancestor `div` of the input carries `.text-body` — not that the option *row* does. So it
stays green if the class is mistakenly emitted on a wrapper (`.filter-section`, `.pb-2`) instead of
the row itself — exactly the regression the assertion exists to catch (a cousin of False Green #1: the
selector matches by an unintended path). Pin the real DOM relationship with child combinators —
`div.text-body > label > input[...]` — so only the class on the row passes. Proven by breaking it:
moving `.text-body` up to the `.pb-2` wrapper reddens the child-combinator form while the descendant
form stays green. (#152.)

**Related:** when a constant drives behavior (`ACTION_METHODS`, `COLORS`, `SIZES`), loop it
rather than spot-checking one member — otherwise a typo in the constant ships green.

**Related — when the mapping is many-to-one, loop the *domain*, not the codomain.** Looping the
distinct *outputs* of a mapping feels equivalent to looping its keys and is not: keys that share an
output are covered by whichever one the loop happens to reach, so a typo in any of the others ships
green. `TagChip::Component::GROUP_VARIANTS` maps seven groups onto five semantics, with
`press_festival`/`production`/`vendors` all on `primary` — a per-*hue* loop therefore leaves two of
the seven keys entirely unproven, including in the JS mirror where the keys are duplicated by hand.
Loop `GROUP_VARIANTS.each_key`, and assert the resolved value per key. (Reference: #168 — external
review caught the per-hue loop; two duplicated JS keys had never been exercised.)

**Related — `render_inline` lowercases SVG attribute names, so a camelCase selector silently
matches nothing.** ViewComponent's `render_inline` parses output through Nokogiri's HTML parser,
which downcases attribute *names* (`viewBox` → `viewbox`, `preserveAspectRatio` →
`preserveaspectratio`). CSS attribute-name matching is case-sensitive, so
`have_css("svg[viewBox='0 0 22 26']")` matches **nothing** — and a `not_to` paired with it is a
guard that can never fail (False Green #2's cousin: the *selector*, not the DOM, is what's empty).
Use lowercase: `have_css("svg[viewbox='0 0 22 26']")`. Attribute *values* and element/class
selectors are unaffected. Confirm which form the parser emits with a one-line probe
(`puts page.native.to_html`) before trusting any camelCase attribute selector. (#155 — a
`not_to have_css("svg[viewBox=…]")` guard on the logo-mark override passed only because the
camelCase selector never matched; lowercasing it turned the guard real.)

**Related — a conversion that lives in an SCSS *partial* is invisible to `render_inline`; its
proof is a compile guard plus a browser spec, never a component spec.** The inline-hex→utility
conversions (#128 Badge, #149 Pagination) changed the *emitted markup* (class names / inline
`style`), so `render_inline` + Capybara could pin them. A partial conversion (#154 `_nav_bar.scss`,
`$var` → `var(--bs-*)`) changes only CSS *rules* — the `.mds-*` markup is byte-identical before and
after, so a component spec asserting those classes stays green while proving nothing about the
conversion (a false green *by construction*, not by weak assertion). Prove it where the change
lives: a per-selector compile guard (`bin/verify-nav-bar-adaptive`, run from
`yarn build:css:compat`) that the source is `var(--bs-*)`-driven, and a browser feature spec
(`spec/features/nav_bar_theme_spec.rb`) reading `getComputedStyle` under both `data-bs-theme`
modes — each proven by breaking it. Do not add a `render_inline` colour assertion for a partial
conversion; it cannot see CSS. (#154.)

**Related — a browser contrast spec must pin the painted *foreground*, not only the ratio.** A
computed-style assertion of the shape `ratio(fg, bg) >= 4.5` — reading `fg` from the element that
*should* carry the colour class — false-greens if that class stops applying: the element falls back
to inherited body text, which usually also clears AA against the same surface, so the ratio still
passes while the intended token has silently stopped driving the colour. Pin the *value* the class
must paint (`expect(computed(sel, "color")).to eq("#4F5B73")`) beside the ratio. The #149 pilot
already does this ("asserting the painted value as well as the ratio, because inherited body text
clears AA in both modes and would make a ratio-only assertion a false green"); it is a named rule
now because #150 regressed below it — its two new `ActiveFilterBar` browser checks asserted surface
+ ratio only, and external review had to restore the foreground pins (`#4F5B73` light / `#B4B8BD`
dark, both Chrome-measured). (#150.)

**Related — when a component legitimately keeps one hex (no Bootstrap equivalent), guard it by
parsing declarations, not by string-deleting the allowed value before a residual sweep.** A sweep of
the shape "delete the permitted hex from the style, then assert no hex remains" false-greens on the
*same* hex reused in another property: deleting every `#64748B` also deletes an unwanted
`outline: 1px solid #64748B`. Parse the style into declarations, assert the exact permitted
`property: value` pairs are present (`contain_exactly("background-color: #64748B", "color: #fff")`),
and reject a hex literal in every *other* declaration — then a stray hex in a new property reddens.
Prove it by adding one and watching red. (Reference: #150 — `AvatarStack` keeps `#64748B` for the
`+N` overflow chip; the first residual sweep string-deleted it and would have masked the same hex
reused elsewhere, caught by external review.)

**Related — a theme-adaptivity guard must forbid the colour-bearing *properties by name*, not only
literal-colour *values*.** A guard that rejects `color`/`background` declarations plus hex/rgb/hsl
literals still lets `border: 1px solid red` (a *named* colour) and `border: none` through — the exact
inline-border regression a hex→utility conversion removes. The property axis has to be the
authoritative whitelist, and the value axis a best-effort backstop. (Reference: #151 — the
FilterChipBar/DataTable conversion's first guard rejected only hex/rgb/hsl values and
`color`/`background` properties, so a named-colour or `none` border passed; caught by external review.)

**Do not hand-roll that guard — `spec/support/theme_adaptivity.rb` is THE canonical one.** Three specs
each carried a divergent private copy of the declaration parse until #183 consolidated them, and the
copies had already drifted apart (Dashboard's dropped `opacity`, which is #130's whole finding;
DataTable's dropped `background-image`, `fill`, `stroke` and every modern colour function). A private
copy is a guard nobody re-reviews when the rule moves. `spec/support/**/*.rb` is auto-required, so the
module is available to every spec including `spec/lib/`, and all three matchers accept a Nokogiri
fragment, a Capybara node, or a raw HTML string.

The module has **three axes, one matcher each**, and they are not interchangeable:

| Matcher | Subject | Catches | Blind to |
|---|---|---|---|
| `be_free_of_frozen_colour` | one element's surviving inline `style` string | `border: none`, a named colour, `opacity`, a `var(--bs-*)` with a frozen fallback | classes; attributes |
| `be_free_of_fixed_hue_utilities` | a rendered fragment | `btn-primary`, `bg-white`, `text-bg-primary`, bare `text-primary` | inline style entirely |
| `be_free_of_colour_literals` | a rendered fragment's serialised HTML | a hex in an **attribute** — an inline SVG `fill="#fff"` | named colours; modern colour functions |

A component whose colour moved onto classes needs the class matcher; a declaration scan cannot
distinguish `bg-danger` from `bg-white` because it never reads `class` at all.

The class matcher has **two layers, and only the second is an allowlist** — calling the whole thing
"an allowlist" is the prose-only assurance this file warns about, because it hides the layer that
decides what gets examined at all.

*Layer 1, the family classifier* (`COLOUR_UTILITY_PATTERN`), is **blacklist-shaped and cannot be
complete**: it enumerates the Bootstrap families known to paint, and a class matching none of them
is never inspected. #183's external review found that hole live — `.table-primary`, `.table-dark`,
`.focus-ring-primary`, `.dropdown-menu-dark` and `.navbar-dark` were all unclassified, so
`fixed_hue_utility_offences('<div class="table-primary">')` returned `[]` while DataTable and
TableForIndex both render a `<table>`; injecting `table-primary` into Dashboard left 144 examples
green. Adding a family is the only fix, so **when you meet a Bootstrap class the guard shrugs at,
classify it** rather than assuming silence means safety.

*Layer 2, within a classified family, is the allowlist*, in three tiers. Tier 1 is neutral
(`bg-transparent`, `border-0`, `text-decoration-none`, `table-sm` — classified by prefix, paints
nothing); tier 2 is genuinely adaptive (`bg-body*`/`text-body*`/`text-body-emphasis`, `table` and its
`-striped`/`-hover`/`-active` state classes, and `bg-*-subtle`/`text-*-emphasis`/`border-*-subtle`
**plus `alert-*` and `list-group-item-*`** for every Bootstrap semantic *including* `info`, `light`
and `dark` — "does it re-resolve" is a different question from "is it on MPI's palette"); tier 3 is a
**deliberate fixed hue**. Layer 2 fails **closed**: an unnamed member of a classified family is
rejected, so over-rejection costs one commented exception while under-rejection is a silent false
green. Verify every tier entry against **compiled** Bootstrap
(`node_modules/bootstrap/dist/css/bootstrap.css`, both the `:root` and `[data-bs-theme=dark]`
blocks) — #173 classified `alert-danger` and `list-group-item-warning` as fixed hues and #183
inherited the claim, and both are false: they resolve through the same
`--bs-#{semantic}-text-emphasis`/`-bg-subtle`/`-border-subtle` tokens the `-subtle`/`-emphasis`
utilities use, all of which the dark block redefines. Do not widen tiers 1–2 casually: their contents
*and* the family classifier are asserted directly in `spec/lib/theme_adaptivity_spec.rb` precisely so
that widening either is a visible, reviewable act rather than a quiet weakening of all fourteen
guarded specs at once.

**Take a tier-3 exception by removing the sanctioned CLASS — not by `allowing:`, and not by removing
the NODE.** Both wrong answers are wrong in opposite directions, and #183 shipped each in turn.

`allowing:` is too wide on the *placement* axis: it is class-scoped, so `.allowing("bg-danger")` also
passes a `bg-danger` on a text-bearing element elsewhere in the same fragment, which is the
regression the guard exists for.

`node.remove` is too wide on the *subject* axis: deleting the subtree also deletes every **other**
regression on that node and its descendants. The external review of #183's own fix commit
demonstrated it by injection — `bg-white` added directly to each removed node left all four fixed-hue
specs green (99 examples), and added to the remove-link *descendants* of ActiveFilterBar's and
FilterChipBar's pills left 43 green. The strip was policing the class it sanctioned and blinding the
scan to everything else the node carried.

Removing the class is exactly as wide as the exception and no wider — the node, its other classes,
its inline style and its whole subtree stay in the scan. The shared helper is
`ThemeAdaptivityHelpers#strip_sanctioned_hue` (`spec/support/theme_adaptivity.rb`); do not hand-roll
it, for the same reason the matchers themselves are shared:

```ruby
def without_decorative_dot_hues(fragment)
  dots = fragment.css(decorative_dot)                     # a `let`, never a constant-in-a-block
  # One entry PER NODE in document order, so the list length is the EXACT expected count and
  # each node must really carry the class named for it.
  strip_sanctioned_hue(dots, %w[bg-danger bg-success bg-success])
  dots.each { |dot| expect(dot.text.strip).to be_empty }  # each must be genuinely decorative
  fragment
end
```

**`expect(dots).not_to be_empty` is the wrong pin here, and this was found by running it.** The
failure mode a strip introduces is not "removes nothing" — the class matcher catches that anyway,
because the un-stripped dot's `bg-danger` is still there. It is an **over**-strip: widen the selector
to `span` and the scan afterwards inspects almost nothing while staying green. `not_to be_empty`
passes right through that; an exact count reddens in both directions. Proven by mutation: widening
`decorative_dot` to `"span"` leaves the example green under `not_to be_empty` and reddens it under
an exact count. That is why `strip_sanctioned_hue` takes a per-node list rather than a class plus a
node set: the count is not an optional extra assertion, it is the argument's own length.

The `text.strip` check is defence in depth rather than an independently isolated rule — with the
exact count in place, every wrong-strip mutation that could be constructed is caught by the count or
by the matcher. It stays because it is what makes "decorative" a *tested* property rather than a
claim in a comment, and WCAG 2.1 SC 1.4.11 is the entire basis for the exception. Pin the stripped
nodes' own classes in a separate example too, or stripping them from the *scan* removes them from the
*suite*.

**This applies to the *selected-state* exception too — `allowing:` has no legitimate call site left.**
The earlier version of this rule reserved `allowing:` "for a class that is fixed-hue everywhere it
appears in that component (a selected-state `text-bg-primary`, StatCard's large-text `text-danger`)".
That carve-out was wrong on its own terms, and #183's external review demonstrated it by injection:
`text-bg-primary` added to ActiveFilterBar's **non-selected** "Active:" label left 111 examples green.
"Fixed-hue everywhere it appears" is a claim about *placement*, and a class-scoped matcher cannot
check placement — so the allowance passes exactly the regression the exception's own conditions
forbid. Same for StatCard: `.allowing("text-danger")` equally passes a base `text-danger` on the 12px
trend, where the large-text 3:1 argument does not reach (3.41:1 in dark mode).

There are **four fixed-hue call sites: three selected-state surfaces** — ActiveFilterBar's and
FilterChipBar's active-filter pill, and Pagination's current page — **plus StatCard's large-text alert
value**, which is a *different* exception (`.claude/rules/frontend.md` — AA's 3:1 large-text floor,
not a selection affordance; `role='alert'` is the card's state, not a selected state). All four now
strip the sanctioned class rather than the node — keyed on the selected state itself where one exists
(`aria-current='page'` for Pagination) — with an exact count via `strip_sanctioned_hue`, an identity
assertion, a separate example pinning the node's classes *and* its state semantics, and a negative
assertion that a non-selected sibling does not carry the class. No component spec passes `allowing:`;
only `spec/lib/theme_adaptivity_spec.rb` still exercises it, to prove it is scoped to the named class
and is not a kill switch.

**Removing a NODE stays right for one case only — a CHILD COMPONENT's subtree** (AccountDetailPanel's
embedded `span.badge`, DataTable's and Dashboard's `AvatarCircle` roots, Dashboard's caller-owned chart
nodes). There the whole subtree is out of the parent's scope, not one sanctioned class on the parent's
own element, so the class strip does not apply. It still needs the exact expected count.

**And such a strip is only legitimate when what you strip is INDEPENDENTLY guarded.** Removing a child
component's subtree scopes the parent's scan correctly, but it also deletes the only evidence of that
child's classes from the parent suite — so if the child has no class-axis guard of its own, the strip
is a cross-component hole rather than a scoping decision. #183 shipped one: AccountDetailPanel removed
every `span.badge`, then asserted only that the Badge still carried `text-bg-primary` — an assertion
that permits arbitrary *additional* classes — while Badge's own spec had no class-axis guard at all.
`bg-white` added to `Badge#css_classes` was green across 242 examples (Badge, AccountDetailPanel,
TableForIndex, the preview sweep). Guard the child first, with the **exact** colour-bearing class set
per variant/colour/size (`contain_exactly`, not `include`), and give the parent's strip an exact
expected count exactly like the dot strips.

**"Per variant/colour/size" means the CARTESIAN PRODUCT, not one loop per axis.** #183's first fix
looped colours at the default size and sizes at the default colour, which reads as complete coverage
and is not: where the class list is composed from several parameters, a per-axis loop never renders
the *combinations*. The combination the ecosystem actually calls — AccountDetailPanel renders
`variant: :filled, size: :sm, color: :info` — was unrendered by the guard, so a `bg-white` conditional
on exactly that path shipped green across 102 examples, and the parent had stripped the evidence. Loop
`COLORS × SIZES` per variant and `GROUP_VARIANTS × SIZES` for the tag-group family, and prove it by
injecting on the live combination.

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

Three practical rules when mutation-testing:

- **Isolate the spec file.** `version_spec.rb` independently pins the version, so bumping
  `VERSION` reddens it regardless — a full-suite red proves nothing about the guard you are
  testing. Run the single file.
- **Never mutate with `git stash`** (shared stash stack, see `CLAUDE.md`). Edit, capture the
  failure, revert, then confirm `git diff` shows only the intended change.
- **A red suite is not a red *rule* — when two checks can catch the same mutation, neither is
  individually proven.** Isolating the *file* is not enough; overlapping checks inside it produce
  the same false confidence. #168's theme-adaptivity guard ran a property scan and a literal scan.
  Its recursive-fallback fix was *also* caught by the literal scan, and its independent-scans fix
  was *also* caught by the property rule — so **either fix could be deleted with the suite still
  green**, after the author had watched red and while every example passed. Exercise the unit
  directly, assert *which* check produced the offence, and choose a fixture only the target check
  can reject: #168's custom-property case used `chartreuse`, which the named-colour scan also
  catches, and became isolating only as `papayawhip` — absent from the blacklist and not a
  literal. Delete each rule one at a time and confirm the failure count changes by exactly what
  that rule owns. (Reference: #168 round 2 — the sharpest of three review passes; round 1's fixes
  were correct and effectively untested.)

**A guard must fail *closed* on input it cannot parse.** A validator has three outcomes, not two —
pass, fail, and *don't know* — and routing "don't know" to pass is how a guard ships fail-open with
its own tests green. #168's `adaptive_value?` returned `nil` both for "this value has no fallback"
and for "I could not parse this value", and `nil` meant adaptive; executed against the guard,
`color: var(--bs-body-color, chartreuse) !important`, `text-shadow: 0 0 2px chartreuse`,
`--x: chartreuse` and `caret-color: light-dark(chartreuse, papayawhip)` each returned **zero
offences**. Make the unparseable branch reject, treat every un-excepted custom property as
in-scope, and enumerate the bypasses by running them rather than by reasoning about coverage.
Related: **do not describe a guard as a whitelist when one of its axes is a blacklist.** That
file's doc comment claimed a "whitelist on both axes"; the value axis is a named-colour blacklist
and can never be complete. Claiming a guarantee the code does not provide is the prose-only
assurance this file warns about. (Reference: #168 round 2.)

**Verify claims about a pattern by executing it, not by reading it.** #127's plan review
produced a confident, wrong claim that `\[`/`\]` form a character class; a three-line Ruby
script refuted it in seconds. The same script found two real defects reading had missed.

This is the spec-level twin of `.claude/rules/frontend.md`'s "prove a new build guard by
breaking it" (#136) and its "verify a contrast rule against an external oracle, never against
itself" (#130). Same failure, four layers: a check that grades its own homework, a check that
never fails, a claim nobody executed, and — the one that hides best — a check that never runs at
all, because it lives in prose.

### A check written in documentation is still a check

Execute it before you publish it. The doctrine above is usually applied to specs, but a guard
does not stop being a guard because it is written in a PR body, a runbook, or a comment. Those
are the guards least likely to be run, because no suite ever touches them.

#148's release PR documented a fail-closed tagging procedure whose CI gate read:

```bash
# NOT A GATE — reads as obviously correct, and is not.
echo "$CONCLUSIONS" | grep -qv '^success$' && { echo "ABORT"; exit 1; }
```

Left to right that says "if any conclusion is not success, abort." Run it and both
`success/failure` and `success/skipped` reach PROCEED: BSD `grep -qv` returns 1 on macOS even
when a non-matching line is present. The gate could not fail — and nothing would ever have
caught it, because it was a shell snippet in a PR description, destined to be run once by a
human against a release tag that is awkward to retract.

```bash
# REAL — verified against success/success, success/failure, success/skipped, cancelled, and empty.
[ -n "$CONCLUSIONS" ] || { echo "ABORT: no CI runs"; exit 1; }
[ "$(printf '%s\n' "$CONCLUSIONS" | sort -u)" = "success" ] \
  || { echo "ABORT: CI not all green -> $CONCLUSIONS"; exit 1; }
```

The method is the same as for a spec: paste the snippet into a shell, feed it the **failure**
case, and watch it abort. A gate verified only on the happy path is indistinguishable from one
that always passes. This applies with most force to anything gating an irreversible step —
a tag push, a deploy, a destructive migration.

**Verify every snippet, not just the one you distrust.** The same #157 procedure carried a
second prose guard that was never run, and it was broken too:

```bash
git show "$MERGE_SHA:lib/mpi_design_system/version.rb" | grep -q '"0.7.0"'   # dies under zsh
git show "${MERGE_SHA}:lib/mpi_design_system/version.rb" | grep -q '"0.7.0"' # correct
```

`:l` is zsh's lowercase parameter modifier, so `"$MERGE_SHA:lib/…"` expands to `<sha>ib/…` and
the command dies on an ambiguous argument — note this repo's shell is zsh. That one happens to
fail *closed*, which is luck rather than design. The instructive part is the selection error:
the author executed the gate whose logic he doubted and skipped the line that looked obvious,
so the doubted line got fixed and the obvious one shipped broken. Run all of them.

**Verifying the gate is not verifying the value it reads.** #163 documented a release runbook whose
CI-green gate was the exact `sort -u` form above — already verified against
`success`/`failure`/`skipped`/`cancelled`/`empty`. It still shipped **fail-open**, because the bug
was in the command that *produces* `$CONCLUSIONS`, not in the gate. Two `gh` traps, both reproduced
by execution:

```bash
# FAIL-OPEN — a still-running check has conclusion null, which gh renders as a BLANK line, and $()
# strips a trailing blank, so [success, <pending>] collapses to "success" and the gate proceeds.
CONCLUSIONS=$(gh api "$url" --jq '.check_runs[].conclusion')

# CLOSED — map null to a non-success token so a pending check can't vanish; --paginate past the
# 30-results-per-page default; and || abort, because gh streams pages and a mid-pagination failure
# otherwise leaves a partial, green-looking list in the variable (VAR=$(cmd) ignores cmd's status).
CONCLUSIONS=$(gh api --paginate "$url" --jq '.check_runs[] | .conclusion // "pending"') \
  || { echo "ABORT: could not read CI checks"; exit 1; }
```

The bug the author cannot see is the one in the input, not the assertion. #163 shipped that
fail-open plus a `git tag` that ran before the `git push` it should have gated — and the *first
round of fixes* introduced two more (a substring `grep` version check that also matched
`OLD_VERSION =` and treated `.` as a wildcard; `--paginate` swallowing a failed read). Every one
was caught by an **independent model told to break the runbook**, across two rounds — none by the
author's own failure-case tests, which were real but tested the cases the author already imagined.
For a step awkward to retract, that second adversary is not optional polish; it is the layer that
catches the fail-open you wrote and therefore cannot see. (The hardened block lives in
`CONTRIBUTING.md` § Release.)

## Anti-Patterns

- Never assert only that a component "renders without error" — that is a false green
- Never assert a value the implementation could produce by another path, and never leave a
  `not_to have_css` unpaired with a positive assertion — see **Two False Greens** above
- Never describe part of an assertion as load-bearing without a test that reddens when it is
  removed, and never pin a literal that the artifact under test retains forever (a version, a
  date, an id) — see **A Guard Is Not Real Until You Have Watched It Fail** above
- Never publish a command, gate, or runbook step you have not executed against its failure
  case — a check in prose is still a check, and it is the kind no suite will ever run for you
  — see **A check written in documentation is still a check** above
- Never assume that verifying a gate covers the command that produces its input — in #163 the
  `sort -u` CI gate was sound while the `gh` producer feeding it silently dropped a still-running
  check; the fail-open lived in the producer, and only an independent adversary caught it — see
  **A check written in documentation is still a check** above
- Never treat a red suite as proof that a *specific* rule is load-bearing when a second check
  catches the same mutation — assert which one fired — see **A red suite is not a red rule** above
- Never let a guard pass input it could not parse; "don't know" must route to reject, and never
  call a guard a whitelist when one of its axes is an unclosable blacklist — see **A guard must
  fail closed** above
- Never loop a many-to-one mapping by its distinct outputs — loop the keys, or the keys sharing an
  output ship untested — see **when the mapping is many-to-one** above
- Never test private methods — test through the rendered output
- Never reference models, the database, or request specs — the engine has none (browser
  feature specs exist, but only for genuine JS behavior — see Stack; default to `render_inline`)
- Never claim a behavior "needs manual testing" without first attempting it with
  `render_inline` and Capybara matchers
- Never skip edge cases because "they're unlikely"
