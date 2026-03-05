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
| **Filled** | Solid background with white text. Used for status indicators (Active, Overdue) |
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
| Secondary | Bootstrap default | `#6C757D` | Neutral, muted |

### Tag Group Colors

| Group | Text | Background |
|---|---|---|
| Distribution | `#E8733A` | `#FEF3EC` |
| Outreach | `#2DA67E` | `#ECF8F4` |
| Press/Festival | `#2E75B6` | `#EBF3FB` |
| Vendors | `#8B5CF6` | `#F3EFFE` |
| Finance | `#D97706` | `#FEF9EC` |
| Production | `#6366F1` | `#EEEFFE` |
| Internal | `#64748B` | `#F1F5F9` |

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
# Admin::Badge::Component
class Admin::Badge::Component < ViewComponent::Base
  # @param label [String] Badge text
  # @param color [Symbol] :primary, :success, :danger, :warning, :secondary
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
- `bg-primary`, `bg-success`, `bg-danger`, `bg-warning`, `bg-secondary` — filled variants
- `border` — outline variant base
- Custom inline styles for tag group color pairs

## Accessibility

- Ensure 4.5:1 contrast ratio on all text/background combinations
- All tag group color pairs have been verified for WCAG AA compliance
- Use `aria-label` when badge text alone is insufficient context (e.g., a count badge)

## Usage Guidelines

- **Use** for status indicators, counts, and classification labels
- **Use** tag group variant for CRM contact/account type labels
- **Do not** use badges for interactive elements — use buttons or chips instead
- **Do not** invent new badge colors — use semantic or tag group colors only
- Badges wrap naturally in flex containers on small screens
