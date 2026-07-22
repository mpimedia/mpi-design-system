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

## Semantic Mapping (`GROUP_VARIANTS`, #151)

`GROUPS` above is the frozen brand-hex palette. `GROUP_VARIANTS` is a parallel map from
each tag group onto a **Bootstrap semantic colour**, so consumers that need a
theme-adaptive chip resolve colour from `--bs-*` (which follows `data-bs-theme`) instead of
the frozen hex. `FilterChipBar` (selected chip) and `DataTable` (tag dots) consume it; the
TagChip component itself still renders the hex pairs this phase.

| Group | Semantic | Renders as |
|---|---|---|
| Press/Festival | `primary` | blue |
| Production | `primary` | blue |
| Vendors | `primary` | blue |
| Outreach | `success` | green |
| Finance | `warning` | amber |
| Distribution | `danger` | red |
| Internal | `secondary` | grey |

MPI maps `$info` → `$primary` (`_tokens_values.scss`), so the palette offers **five**
distinct adaptive hues, not seven: the three cool categories (Press/Festival, Production,
Vendors) collapse onto `primary` (blue), and Distribution's warm orange approximates to
`danger` (red). This is an accepted trade of the #151 conversion — the tag's always-present
**text label** carries the category identity, so the hue is reinforcement, not the sole
signal. Distinguishing all seven hues adaptively would require new brand tokens, deferred to
the tag-palette follow-up.

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
# MpiDesignSystem::Admin::TagChip::Component
class MpiDesignSystem::Admin::TagChip::Component < ViewComponent::Base
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

- **The 7 hex color pairs do NOT meet WCAG AA for normal text.** Re-derived contrast ratios
  range **2.77:1 to 4.34:1** (coloured text on its light background), all below the 4.5:1 AA
  floor — the earlier "all verified for AA" claim was false (#130). The colour is reinforced
  by the leading dot and the always-present text label, but the pairs should not be relied on
  as the sole carrier of meaning. Fixing the pairs means changing shared brand tokens — a
  designer-led decision tracked in the tag-palette follow-up, not silently absorbed here
- Consumers that need an AA-clean, theme-adaptive chip should use `GROUP_VARIANTS` (above)
  rather than these pairs — `FilterChipBar`'s selected chip renders `bg-#{sem}-subtle` +
  `text-#{sem}-emphasis`, which Bootstrap derives to clear AA in both colour modes (#151)
- Removable chips: `×` button must have `aria-label="Remove [tag name]"`
- Group of chips should be wrapped in a list (`<ul>`) or described with `aria-label`
- Focus indicator on remove button for keyboard navigation

## Usage Guidelines

- **Use** on contact cards, contact list rows, and filter bars to show group/tag classification
- **Use** removable variant in edit forms and active filter displays
- **Two colour systems, bridged by `GROUP_VARIANTS`.** The chip's own rendering uses the
  brand-hex pairs; do not hand-swap those for Bootstrap's `text-bg-*` badge utilities on the
  TagChip itself. But the group→semantic bridge IS intentional for *list-view consumers*
  (`FilterChipBar`, `DataTable`), which render the adaptive semantics via `GROUP_VARIANTS` so
  they track `data-bs-theme` (#151). Prefer that bridge over inventing a new mapping
- **Do not** create new color pairs without adding them to `tokens/colors.md` — and add the
  matching `GROUP_VARIANTS` entry so converted consumers don't fall back to `secondary`
- Tags always inherit their parent group's color — never assign colors to individual tags
