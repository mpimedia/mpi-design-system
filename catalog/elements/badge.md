# Badge

**Category:** Element
**Issue:** #10
**Status:** Approved

## Description

Pill-shaped badges used for status indicators, counts, and labels across all MPI apps. Used in table rows, contact cards, navigation, and anywhere a compact label is needed.

## Design Decisions

- **Shape:** Pill (`border-radius: 999px`) for all badges — confirmed in Q&A Session 001
- **Colors:** Use MPI semantic palette, not arbitrary hex values
- **Tag group badges:** Use dedicated color pairs (colored text on light background) — see Tag Group Colors below
- **Global override:** `$badge-border-radius: 999px` in SCSS overrides ensures all Bootstrap badges are pill-shaped

## Variants

| Variant | Description |
|---|---|
| **Filled** | Solid background with a Bootstrap-computed foreground (light or dark, whichever meets WCAG-AA contrast — not always white). Used for status indicators (Active, Overdue) |
| **Outline** | Transparent background with colored border and text. Used for secondary emphasis |
| **Tag Group** | Colored text on light background. Used for CRM tag group labels (Buyer, Press, etc.) |
| **With Count** | Filled badge with an inline number (e.g., "Contacts 24") |

### Semantic Colors

| Color | Token | Hex | Usage |
|---|---|---|---|
| Primary | `$mpi-primary` | `#2E75B6` | Default, informational |
| Success | `$mpi-success` | `#22A06B` | Active status, positive |
| Danger | `$mpi-danger` | `#DC3545` | Overdue, errors |
| Warning | `$mpi-warning` | `#D4772C` | Pending, caution |
| Info | `$info` (aliased to `$mpi-primary`) | `#2E75B6` | Informational, advisory |
| Secondary | Bootstrap default | `#6C757D` | Neutral, muted |

### Tag Group Colors

| Group | Semantic | Rendered classes |
|---|---|---|
| Press/Festival | `primary` | `bg-primary-subtle text-primary-emphasis` |
| Production | `primary` | `bg-primary-subtle text-primary-emphasis` |
| Vendors | `primary` | `bg-primary-subtle text-primary-emphasis` |
| Outreach | `success` | `bg-success-subtle text-success-emphasis` |
| Finance | `warning` | `bg-warning-subtle text-warning-emphasis` |
| Distribution | `danger` | `bg-danger-subtle text-danger-emphasis` |
| Internal | `secondary` | `bg-secondary-subtle text-secondary-emphasis` |

Colour resolves from `TagChip::Component::GROUP_VARIANTS` and follows `data-bs-theme`.
Because MPI maps `$info` → `$primary`, the seven categories collapse onto **five** distinct
hues; the always-present text label carries the identity. See `catalog/elements/tag-chip.md`
for the full mapping rationale and the per-surface treatment table. (#168)

## Sizes

| Size | Font Size | Padding |
|---|---|---|
| Small | `0.65em` | Default Bootstrap |
| Default | Bootstrap default | Default Bootstrap |
| Large | `1em` | `0.5em 1em` |

## States

| State | Description |
|---|---|
| Default | Normal display |
| Disabled | Muted opacity, used when the associated item is inactive |

## Props / API

```ruby
# MpiDesignSystem::Admin::Badge::Component
class MpiDesignSystem::Admin::Badge::Component < ViewComponent::Base
  # @param label [String] Badge text
  # @param color [Symbol] :primary, :success, :danger, :warning, :info, :secondary
  # @param variant [Symbol] :filled (default), :outline, :tag_group
  # @param size [Symbol] :sm, :md (default), :lg
  # @param tag_group [Symbol] Optional — :distribution, :outreach, :press_festival, :vendors,
  #   :finance, :production, :internal
  # @param count [Integer] Optional inline count
end
```

## Bootstrap Classes

- `badge` — base class
- `rounded-pill` — pill shape (or global override)
- `text-bg-primary`, `text-bg-success`, `text-bg-danger`, `text-bg-warning`, `text-bg-info`, `text-bg-secondary` — filled variants (each pairs the background with a Bootstrap-computed accessible foreground)
- `border` — outline variant base
- Custom inline styles for tag group color pairs

## Accessibility

- Ensure 4.5:1 contrast ratio on all text/background combinations
- Filled badges derive their foreground via Bootstrap's `text-bg-*` utilities, so every
  semantic color meets WCAG AA automatically (previously `success` paired a hardcoded
  `text-white` for only 3.33:1 — see #128)
- The `tag_group` variant renders `bg-{semantic}-subtle` + `text-{semantic}-emphasis`
  from the shared `TagChip::Component::GROUP_VARIANTS` map, so Bootstrap derives an
  AA-clean pair per colour mode — browser-measured 9.34:1–10.52:1 light and
  7.15:1–8.61:1 dark. This replaced Badge's own `TAG_GROUPS` hex duplicate, whose
  seven pairs all measured **below** the 4.5:1 floor (2.77:1–4.34:1, ISS#142 §1) —
  the earlier "all verified for WCAG AA" claim here was false (#168)
- An unknown `tag_group:` renders an unstyled badge rather than guessing a colour
- Use `aria-label` when badge text alone is insufficient context (e.g., a count badge)

## Usage Guidelines

- **Use** for status indicators, counts, and classification labels
- **Use** tag group variant for CRM contact/account type labels
- **Do not** use badges for interactive elements — use buttons or chips instead
- **Do not** invent new badge colors — use semantic or tag group colors only
- Badges wrap naturally in flex containers on small screens
