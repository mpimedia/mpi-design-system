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
| **Secondary** | `btn btn-secondary` | Neutral/cancel actions |
| **Outline Primary** | `btn btn-outline-primary` | Secondary actions (Filter, Export) |
| **Outline Secondary** | `btn btn-outline-secondary` | Tertiary actions |
| **Outline Danger** | `btn btn-outline-danger` | Secondary destructive actions |
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
# Admin::ActionButton::Component
class Admin::ActionButton::Component < ViewComponent::Base
  # @param label [String] Button text
  # @param color [Symbol] :primary (default), :success, :danger, :warning, :secondary
  # @param variant [Symbol] :filled (default), :outline
  # @param size [Symbol] :sm, :md (default), :lg
  # @param icon [String] Bootstrap Icon class (e.g., "bi-plus-lg")
  # @param icon_only [Boolean] Hide label, show only icon (default: false)
  # @param disabled [Boolean] Disable the button (default: false)
  # @param href [String] Optional — renders as <a> instead of <button>
  # @param method [Symbol] HTTP method for Turbo (:post, :patch, :delete)
  # @param data [Hash] data-* attributes (Turbo/Stimulus)
end
```

## Bootstrap Classes

- `btn` — base class (required)
- `btn-primary`, `btn-success`, `btn-danger`, `btn-warning`, `btn-secondary` — filled
- `btn-outline-primary`, `btn-outline-secondary`, `btn-outline-danger` — outline
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

- All button colors meet WCAG AA contrast for white text on colored backgrounds
- Focus ring must be visible (do not suppress `:focus-visible` styles)
- Icon-only buttons require `aria-label` describing the action
- Disabled buttons should have `aria-disabled="true"` in addition to the `disabled` attribute
- Loading state should use `aria-busy="true"`

## Usage Guidelines

- **Use** `btn-primary` for the single most important action on a page
- **Use** `btn-outline-primary` for secondary actions in the same context
- **Use** `btn-sm` in page headers, table rows, and toolbars
- **Do not** use more than one primary (filled) button in a button group
- **Do not** use custom colors — only the defined semantic palette
- **Do not** use `btn-link` — use a standard `<a>` tag instead
- In page headers: outline for Filter/Export, primary for Add/Create
