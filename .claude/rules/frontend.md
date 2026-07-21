# Frontend Rules

Applies to: `app/components/**`, `app/javascript/**`, `app/assets/**`

## Framework

- This repo is a Rails engine gem — everything under `app/` ships to every consuming app (Markaz, SFA, Garden, Harvest)
- Hotwire only (Turbo + Stimulus) — never React, Vue, or other JS frameworks
- ViewComponent for all UI components
- Bootstrap 5.3 for all styling — never Tailwind CSS

## ViewComponent Conventions

- Components follow the `MpiDesignSystem::Admin::Name::Component` pattern:
  `app/components/mpi_design_system/admin/<name>/component.rb` + `component.html.erb`
- Components inherit directly from `ViewComponent::Base`. There is **no**
  `ApplicationComponent` base class in this engine — do not reference or invent one
- Every component ships with a spec (`spec/components/mpi_design_system/admin/<name>/component_spec.rb`)
  and a Lookbook preview (`spec/components/previews/mpi_design_system/admin/<name>/component_preview.rb`)
- Validate params in the component and fall back to safe defaults (e.g. `MpiDesignSystem::Admin::Badge::Component`
  maps an unknown color to `primary`) — never let bad input render broken markup

## Renaming a Component, Namespace, or Styling Convention

A component/namespace rename — or a change to a styling convention (e.g. a Bootstrap class
pattern) — is not finished when the constants resolve or the component renders. Blind spots
routinely survive a narrow sweep and ship green:

- **Path strings, not just constants.** Old paths also live in lowercase string literals a
  `grep 'Admin::'` never sees: `render_with_template(template: "…")`, `render partial: "…"`,
  Lookbook `@display`/template annotations, and asset paths. After renaming, grep the old
  *path fragment* (e.g. `admin/`) separately from the old *constant*, and confirm with a full
  preview render sweep (see `.claude/rules/testing.md`). Zeitwerk rewires constant→path but
  will not flag a hard-coded template string pointing at the moved directory.
- **The repo's own docs, not just code.** Sweep `CLAUDE.md`, `AGENTS.md`, `.claude/rules/**`,
  `catalog/**`, `references/**`, and `docs/standards/**` for the old token too — leaving the
  convention documented one way while the code does another tells the next agent to re-create
  the old pattern. (Reference: #103 renamed `Admin::` → `MpiDesignSystem::Admin::`; the catalog
  and standards docs had to be swept in the same change.)
- **A styling-convention change is a rename too — grep the pattern, not the lines you know.**
  When you change a Bootstrap class convention (e.g. `bg-#{color}` + `text-white`/`text-dark`
  → `text-bg-#{color}`), `git grep` the *old class pattern* across the whole repo — specs,
  `catalog/**`, and `.claude/rules/**` included — rather than editing a known list of line
  numbers; a line-scoped sweep misses second occurrences in the same file. (Reference: #128
  tokenized Badge's filled contrast; the external review caught a retired `bg-warning` +
  `text-dark` example still in `.claude/rules/testing.md` that a line-scoped sweep skipped.)

## Component Catalog First

Before creating a new component, check the catalog for an existing spec:

- `catalog/elements/` — buttons, badges, inputs, chips (Atoms)
- `catalog/components/` — cards, tables, pagination, navbars (Molecules)
- `catalog/patterns/` — forms, search, filters (Organisms)
- `catalog/layouts/` — app shell, dashboard, detail/list views (Templates)

If a catalog entry exists, implement to that spec. If not, raise it with the HC before building.

## Styling and Tokens

- Use Bootstrap utility and component classes — no arbitrary hex values, sizes, or spacing
- Design tokens live in `app/assets/stylesheets/mpi_design_system/_tokens.scss` and override
  Bootstrap variables before Bootstrap is imported (`$mpi-primary: #2E75B6`,
  `$mpi-brand-navy: #1B2A4A`, `$mpi-brand-accent: #4EA8DE`)
- Token documentation lives in `tokens/*.md` (colors, typography, spacing, components,
  navigation, bootstrap-overrides) — consult it before choosing values
- Custom SCSS only when Bootstrap genuinely cannot express the design; keep it in a
  dedicated partial under `app/assets/stylesheets/mpi_design_system/` (existing example:
  `_nav_bar.scss`) and import it from `application.scss`

## Stimulus Controllers

- Controllers live in `app/javascript/mpi_design_system/controllers/`
- Every controller must be registered in `controllers/index.js` inside
  `registerMpiControllers(application)` (e.g. `application.register("mpi--tag-input", TagInputController)`)
  and exported from that file — consuming apps call `registerMpiControllers` to wire up
  all engine controllers at once
- The top-level `app/javascript/mpi_design_system/index.js` re-exports
  `registerMpiControllers` and the individual controllers — keep it in sync when adding one
- No inline JavaScript in ERB templates — attach behavior via `data-controller` attributes

## Accessibility (WCAG 2.1 AA minimum)

- All interactive elements keyboard-accessible
- Appropriate ARIA roles and labels (e.g. Badge adds `aria-label` for its count)
- Contrast: 4.5:1 for normal text, 3:1 for large text — prefer Bootstrap's `text-bg-*`
  utilities, which derive an accessible foreground automatically (e.g. `text-bg-warning`
  yields dark text), rather than hand-pairing a background with a `text-*` class
- **Never hardcode a foreground next to a variable background.** Where a component must emit
  colour in an *inline style* and `text-bg-*` cannot reach, derive it with
  `MpiDesignSystem::ColorContrast.accessible_foreground(background)` — the Ruby counterpart of
  Bootstrap's `color-contrast()`. Pinning `color: #fff` beside a dynamic
  `background-color` is the exact defect #130 fixed in `AvatarCircle`, where 7 of 10 palette
  colours shipped below the AA floor (`#4EA8DE` at 2.63:1). Where the background *is* a theme
  colour, use `text-bg-*` and let Bootstrap derive it — do not reach for the Ruby helper
- **Audit `opacity`, not just `color:`.** A declared pair can be AA-clean and still fail once
  faded: `ActiveFilterBar`'s remove button paired white with `opacity: 0.8`, compositing to an
  effective `#D5E3F0` at 3.71:1. A sweep that reads only `color:` declarations will not see it
- **Verify a contrast rule against an external oracle, never against itself.** A spec asserting
  `ratio(bg, accessible_foreground(bg)) >= 4.5` calls the code under test on both sides — wrong
  luminance math agrees with itself and still ships a failure. `bin/verify-contrast-oracle`
  compiles Bootstrap's own `color-contrast()` over the palette in CI for exactly this reason
- Visible focus indicators on every focusable element

## Anti-Patterns

- Never add CSS frameworks beyond Bootstrap 5.3 (no Tailwind)
- Never invent colors, sizes, or spacing outside the tokens and Bootstrap's scale
- Never add a Stimulus controller without registering it in `registerMpiControllers`
- Never subclass a nonexistent `ApplicationComponent`
