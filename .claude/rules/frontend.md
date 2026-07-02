# Frontend Rules

Applies to: `app/components/**`, `app/javascript/**`, `app/assets/**`

## Framework

- This repo is a Rails engine gem — everything under `app/` ships to every consuming app (Markaz, SFA, Garden, Harvest)
- Hotwire only (Turbo + Stimulus) — never React, Vue, or other JS frameworks
- ViewComponent for all UI components
- Bootstrap 5.3 for all styling — never Tailwind CSS

## ViewComponent Conventions

- Components follow the `Admin::Name::Component` pattern:
  `app/components/admin/<name>/component.rb` + `component.html.erb`
- Components inherit directly from `ViewComponent::Base`. There is **no**
  `ApplicationComponent` base class in this engine — do not reference or invent one
- Every component ships with a spec (`spec/components/admin/<name>/component_spec.rb`)
  and a Lookbook preview (`spec/components/previews/admin/<name>/component_preview.rb`)
- Validate params in the component and fall back to safe defaults (e.g. `Admin::Badge::Component`
  maps an unknown color to `primary`) — never let bad input render broken markup

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
  `registerMpiControllers(application)` (e.g. `application.register("tag-input", TagInputController)`)
  and exported from that file — consuming apps call `registerMpiControllers` to wire up
  all engine controllers at once
- The top-level `app/javascript/mpi_design_system/index.js` re-exports
  `registerMpiControllers` and the individual controllers — keep it in sync when adding one
- No inline JavaScript in ERB templates — attach behavior via `data-controller` attributes

## Accessibility (WCAG 2.1 AA minimum)

- All interactive elements keyboard-accessible
- Appropriate ARIA roles and labels (e.g. Badge adds `aria-label` for its count)
- Contrast: 4.5:1 for normal text, 3:1 for large text — pair light backgrounds with dark
  text classes (e.g. `bg-warning` with `text-dark`)
- Visible focus indicators on every focusable element

## Anti-Patterns

- Never add CSS frameworks beyond Bootstrap 5.3 (no Tailwind)
- Never invent colors, sizes, or spacing outside the tokens and Bootstrap's scale
- Never add a Stimulus controller without registering it in `registerMpiControllers`
- Never subclass a nonexistent `ApplicationComponent`
