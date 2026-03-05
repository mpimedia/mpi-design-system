# TagChip

**Category:** Element
**Issue:** #12
**Status:** Approved

## Description

Color-coded tag chips for CRM contact and account classification. Each of the 7 tag groups has a designated primary color + light background pair. Specific tags (e.g., "MIPCOM 2025") inherit their parent group's color.

## Design Decisions

- **Shape:** Pill (`border-radius: 999px`) — consistent with all badges in the system
- **Color inheritance:** Specific tags inherit their parent group's color pair (e.g., "MIPCOM 2025" under Distribution gets orange)
- **7 color pairs:** Fixed and extensible — new groups get new color pairs from the design token system
- **Remove button:** `×` button for removable variant, opacity increases on hover
- **Font size:** 13px default, 12px when used inline on cards

## Color Pairs

| Group | Text Color | Background Color |
|---|---|---|
| Distribution | `#E8733A` | `#FEF3EC` |
| Outreach | `#2DA67E` | `#ECF8F4` |
| Press/Festival | `#2E75B6` | `#EBF3FB` |
| Vendors | `#8B5CF6` | `#F3EFFE` |
| Finance | `#D97706` | `#FEF9EC` |
| Production | `#6366F1` | `#EEEFFE` |
| Internal | `#64748B` | `#F1F5F9` |

## Variants

| Variant | Description |
|---|---|
| **Default** | Read-only chip showing group or tag name |
| **Removable** | Includes `×` button for removal (used in edit forms, filter bars) |
| **Specific tag** | Named tag within a group — inherits group color (e.g., "MIPCOM 2025" = Distribution orange) |

## States

| State | Description |
|---|---|
| Default | Colored text on light background |
| Hover (removable) | `×` button opacity increases from 0.6 to 1.0 |
| Disabled | Muted opacity, no interaction |

## Props / API

```ruby
# Admin::TagChip::Component
class Admin::TagChip::Component < ViewComponent::Base
  # @param label [String] Tag display text (group name or specific tag name)
  # @param group [Symbol] :distribution, :outreach, :press_festival, :vendors,
  #   :finance, :production, :internal
  # @param removable [Boolean] Show × remove button (default: false)
  # @param size [Symbol] :sm (12px, for cards), :md (13px, default)
  # @param remove_url [String] URL for Turbo Stream removal (when removable)
end
```

## Bootstrap Classes

- Custom CSS for the chip (no direct Bootstrap chip component)
- `d-inline-flex`, `align-items-center`, `gap-1` — layout
- `rounded-pill` — pill shape
- Button remove: custom `.btn-remove` with `border-radius: 50%`, 18×18px

## Accessibility

- All 7 color pairs verified for WCAG AA contrast (colored text on light background)
- Removable chips: `×` button must have `aria-label="Remove [tag name]"`
- Group of chips should be wrapped in a list (`<ul>`) or described with `aria-label`
- Focus indicator on remove button for keyboard navigation

## Usage Guidelines

- **Use** on contact cards, contact list rows, and filter bars to show group/tag classification
- **Use** removable variant in edit forms and active filter displays
- **Do not** mix tag chip colors with badge semantic colors — they are separate systems
- **Do not** create new color pairs without adding them to `tokens/colors.md`
- Tags always inherit their parent group's color — never assign colors to individual tags
