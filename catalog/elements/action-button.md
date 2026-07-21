# ActionButton

**Category:** Element
**Issue:** #13
**Status:** Approved

## Description

Standard buttons using MPI's confirmed color palette, built on Bootstrap 5 `.btn` classes with SCSS color overrides. Used for all interactive actions across MPI apps.

## Design Decisions

- **Built on Bootstrap:** Uses Bootstrap `.btn` classes directly — not a custom button system
- **MPI color overrides:** Primary (`#2E75B6`), Success (`#22A06B`), Warning (`#D4772C`), Danger (`#DC3545` — Bootstrap default)
- **Icon set:** Bootstrap Icons (`bi-*`), placed before label text with `me-1` spacing
- **Page header pattern:** Outline buttons for secondary actions (Filter, Export), filled primary for the main CTA (Add Contact)

## Variants

| Variant | Classes | Usage |
|---|---|---|
| **Primary** | `btn btn-primary` | Main actions (Save, Add, Submit) |
| **Success** | `btn btn-success` | Positive confirmations (Approve, Complete) |
| **Danger** | `btn btn-danger` | Destructive actions (Delete, Remove) |
| **Warning** | `btn btn-warning` | Caution actions (Archive, Suspend) |
| **Info** | `btn btn-info` | Informational actions (Details, Preview) |
| **Secondary** | `btn btn-secondary` | Neutral/cancel actions |
| **Outline Primary** | `btn btn-outline-primary` | Secondary actions (Filter, Export) |
| **Outline Secondary** | `btn btn-outline-secondary` | Tertiary actions |
| **Outline Danger** | `btn btn-outline-danger` | Secondary destructive actions |
| **Outline Info** | `btn btn-outline-info` | Secondary informational actions |
| **With Icon** | `btn` + `<i class="bi bi-* me-1">` | Icon + text label |
| **Icon Only** | `btn` (square) | Toolbar actions, compact UI |

## Sizes

| Size | Class | Usage |
|---|---|---|
| Small | `btn-sm` | Table actions, toolbars, page headers |
| Default | (none) | Forms, modals, primary CTA |
| Large | `btn-lg` | Hero actions, onboarding |

## States

| State | Description |
|---|---|
| Default | Normal interactive state |
| Hover | Slightly darker background (Bootstrap default) |
| Active | Pressed state (Bootstrap default) |
| Focus | Visible focus ring for keyboard navigation |
| Disabled | Reduced opacity, `pointer-events: none` |
| Loading | Text replaced with "Saving..." / spinner (disabled) |

## Props / API

```ruby
# MpiDesignSystem::Admin::ActionButton::Component
class MpiDesignSystem::Admin::ActionButton::Component < ViewComponent::Base
  # @param label [String] Button text
  # @param color [Symbol] :primary (default), :success, :danger, :warning, :info, :secondary
  # @param variant [Symbol] :filled (default), :outline
  # @param size [Symbol] :sm, :md (default), :lg
  # @param icon [String] Bootstrap Icon class (e.g., "bi-plus-lg")
  # @param icon_only [Boolean] Hide label, show only icon (default: false)
  # @param disabled [Boolean] Disable the button (default: false)
  # @param href [String] Optional — renders as <a> instead of <button>
  # @param method [Symbol] HTTP method for Turbo (:get, :post, :put, :patch, :delete)
  # @param data [Hash] data-* attributes (Turbo/Stimulus)
  # @param classes_append [String, Array<String>] Extra layout utility classes (e.g. "float-end me-2")
  # @param role [String] Optional ARIA role override (defaults to "button" for non-GET links)
end
```

## Bootstrap Classes

- `btn` — base class (required)
- `btn-primary`, `btn-success`, `btn-danger`, `btn-warning`, `btn-info`, `btn-secondary` — filled
- `btn-outline-primary`, `btn-outline-secondary`, `btn-outline-danger`, `btn-outline-info` — outline
- `btn-sm`, `btn-lg` — sizes
- `me-1` — spacing between icon and label

## SCSS Overrides

```scss
$primary: #2E75B6;
$success: #22A06B;
$warning: #D4772C;
// $danger uses Bootstrap default #DC3545
```

## Accessibility

- Button foregrounds are **derived, not assumed white** — Bootstrap 5.3's `button-variant()`
  mixin computes each `btn-*` foreground via `color-contrast()`, so a light background such as
  `$mpi-success` (`#22A06B`) receives dark text rather than the 3.33:1 white pairing that a
  hand-maintained table produced (see CHANGELOG 0.4.1 / #128). Do not override the foreground
  with a `text-white` / `text-dark` utility — that reintroduces the contrast failure the
  derivation exists to prevent
- Focus ring must be visible (do not suppress `:focus-visible` styles)
- Icon-only buttons require `aria-label` describing the action
- Disabled buttons should have `aria-disabled="true"` in addition to the `disabled` attribute
- Loading state should use `aria-busy="true"`
- A link-styled button that performs a non-GET action (`href:` plus `method: :post`, `:put`,
  `:patch`, or `:delete`) renders `role="button"`, so assistive technology announces it as the
  action it is. A plain navigation link (`href:` with `method: :get` or no method) deliberately
  renders **no** role — it really is a link, and mislabelling it would hide that from screen
  reader users. Pass `role:` explicitly to override, e.g. for an anchor driven only by `data:`
  attributes (`data-bs-toggle`, a Stimulus action) with no HTTP verb

## Usage Guidelines

- **Use** `btn-primary` for the single most important action on a page
- **Use** `btn-outline-primary` for secondary actions in the same context
- **Use** `btn-sm` in page headers, table rows, and toolbars
- **Do not** use more than one primary (filled) button in a button group
- **Do not** use custom colors — only the defined semantic palette
- **Do not** use `btn-link` — use a standard `<a>` tag instead
- **Use** `classes_append` for **layout utilities only** (`float-end`, `me-2`, `w-100`). Never
  pass `btn-*`, color, or size classes through it — those collide with the classes the component
  derives from `color:` / `variant:` / `size:`, and CSS resolves the conflict by stylesheet
  source order, not by the order the classes appear in the attribute, so the winner is not the
  one you appended. Change the color or size via the actual prop instead
- In page headers: outline for Filter/Export, primary for Add/Create
