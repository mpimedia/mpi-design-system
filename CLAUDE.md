# MPI Design System — Claude Context

This file provides context for Claude when working on design tasks for MPI Media. Paste or attach this at the start of any design session to anchor the conversation to MPI's shared design language.

## What You Are Designing For

MPI Media operates these Ruby on Rails applications:

- **Markaz** — Content management and distribution platform
- **SFA** — Video clip hosting and search
- **Garden** — Static site generator
- **Harvest** — Ecommerce platform
- **Markaz CRM** — Customer relationship management

All apps share a common visual language defined by this design system.

## Technology Constraints

When generating design artifacts (HTML previews, component mockups):

- **Use Bootstrap 5** — All MPI apps use Bootstrap 5 via the `bootstrap` gem
- **Use standard Bootstrap classes** — Prefer Bootstrap's built-in utilities and components over custom CSS
- **Produce HTML/CSS** — Your artifacts should be valid HTML that maps directly to Rails ERB templates
- **No JavaScript frameworks** — MPI uses Stimulus.js for interactivity, not React/Vue/Angular
- **Responsive by default** — Use Bootstrap's grid system and responsive utilities

## Design Tokens

Reference these tokens when choosing values. Do not invent arbitrary colors, sizes, or spacing.

### Colors

> Token values are being established. Use Bootstrap 5 defaults until custom values are documented in `tokens/colors.md`.

- Use semantic color classes (`btn-primary`, `text-danger`, `bg-success`) rather than custom hex values
- Maintain consistent color usage: primary for key actions, danger for destructive actions, etc.

### Typography

> Token values are being established. Use Bootstrap 5 defaults until custom values are documented in `tokens/typography.md`.

- Use Bootstrap's heading classes (`h1`–`h6`) and text utilities (`fs-1`–`fs-6`)
- Use the default font stack unless the app specifies otherwise

### Spacing

- Use Bootstrap's spacing utilities (`p-3`, `mb-4`, `gap-2`)
- Follow the spacing scale: 0, 0.25rem, 0.5rem, 1rem, 1.5rem, 3rem
- Be consistent — similar elements should have similar spacing

## Component Catalog

Before designing a new component, check if one already exists in the catalog:

- `catalog/elements/` — Buttons, inputs, badges, icons, links (Atoms)
- `catalog/components/` — Cards, modals, navbars, tables, alerts (Molecules)
- `catalog/patterns/` — Forms, search bars, filters, data entry (Organisms)
- `catalog/layouts/` — Dashboards, detail pages, list views (Templates)

If a component exists, use it or extend it. Do not reinvent.

## Naming Conventions

- Use **plain language names** for components (e.g., "Video Card" not "MediaMolecule")
- When referencing Bootstrap components, use their official names (e.g., "Modal", "Dropdown")
- When referencing Atomic Design levels, note the cross-reference but keep the plain name primary

## How to Produce Design Artifacts

When creating a design:

1. **Generate an HTML artifact** using Bootstrap 5 classes
2. **Include all states** — default, hover, active, disabled, loading, error, empty (as applicable)
3. **Show variants** — sizes, colors, orientations if the component has multiple forms
4. **Make it responsive** — show how the component behaves at different breakpoints
5. **Include markup comments** — annotate the HTML to explain which Bootstrap classes are used and why

### Artifact Format

```html
<!-- Component: [Name] -->
<!-- Variant: [Default/Primary/etc.] -->
<!-- State: [Default/Hover/etc.] -->

<div class="card">
  <div class="card-body">
    <h5 class="card-title">Title</h5>
    <p class="card-text">Description</p>
    <a href="#" class="btn btn-primary">Action</a>
  </div>
</div>
```

## What NOT to Do

- **Do not use arbitrary hex colors** — Use Bootstrap color classes or documented tokens
- **Do not use Tailwind CSS** — MPI uses Bootstrap 5
- **Do not create overly complex components** — Keep it simple, composable, and maintainable
- **Do not ignore accessibility** — Include ARIA attributes, ensure contrast, support keyboard nav
- **Do not forget mobile** — Every component should work on small screens
- **Do not reinvent existing components** — Check the catalog first

## Accessibility Requirements

- WCAG 2.1 AA compliance minimum
- All interactive elements must be keyboard-accessible
- Include appropriate ARIA roles and labels
- Maintain 4.5:1 contrast ratio for normal text, 3:1 for large text
- Provide visible focus indicators

## After Designing

1. Export the artifact as PDF or PNG
2. Post it to the relevant GitHub issue in the `mpi-design-system` repo
3. The design will be reviewed against the review checklist
4. Once approved, the component spec is added to the catalog

## Rails Implementation Notes

When the design is approved and ready for implementation:

- Components are built as **ViewComponents** (`app/components/`)
- Interactive behavior uses **Stimulus controllers** (`app/javascript/controllers/`)
- Styles use **Bootstrap 5 classes** with minimal custom SCSS
- Templates are **ERB** (not Haml, Slim, or JSX)

## Attribution

All AI-generated work must include attribution per MPI org standards:

```
Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>
```
