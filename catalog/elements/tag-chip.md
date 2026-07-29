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

## Color Pairs (historical reference — NOT rendered, #168)

`GROUPS` still exists as the canonical group **key set** and as a record of the original
brand hex, but **nothing renders from it**. Every tag renderer in the engine now resolves
colour through `GROUP_VARIANTS` below.

| Group | Text Color | Background Color | Measured contrast |
|---|---|---|---|
| Distribution | `#E8733A` | `#FEF3EC` | 2.77:1 ❌ |
| Outreach | `#2DA67E` | `#ECF8F4` | 2.81:1 ❌ |
| Press/Festival | `#2E75B6` | `#EBF3FB` | 4.32:1 ❌ |
| Vendors | `#8B5CF6` | `#F3EFFE` | 3.75:1 ❌ |
| Finance | `#D97706` | `#FEF9EC` | 3.03:1 ❌ |
| Production | `#6366F1` | `#EEEFFE` | 3.92:1 ❌ |
| Internal | `#64748B` | `#F1F5F9` | 4.34:1 ❌ |

Every pair is below the 4.5:1 AA floor (ISS#142 §1). That is why they were retired as a
colour source — do not reintroduce them.

## Semantic Mapping (`GROUP_VARIANTS`)

`GROUP_VARIANTS` maps each tag group onto a **Bootstrap semantic colour**, so a chip
resolves colour from `--bs-*` (which follows `data-bs-theme`) instead of frozen hex. Since
#168 it is the single source of truth for **every** tag-group renderer in the engine:
`TagChip` itself, `Badge`'s `tag_group` variant, `ContactCard`, `EngagementCard`, both list
rows, both detail panels, `TagInput` (server render *and* its Stimulus controller),
`FilterChipBar` and `DataTable`.

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

### How each surface renders it

| Surface | Treatment | Why |
|---|---|---|
| Chip / pill body | `bg-{sem}-subtle` + `text-{sem}-emphasis` | Bootstrap derives an AA-clean pair per colour mode — browser-measured 9.34:1–10.52:1 light, 7.15:1–8.61:1 dark |
| Dot **inside** a chip | `background-color: currentColor` | Inherits the chip's `-emphasis` foreground. A solid `bg-{sem}` here measures **2.62:1–2.67:1** on its own `-subtle` surface — below the 3:1 decorative floor |
| Dot on a **card/row** surface | `bg-{sem}` (solid, fixed hue) | The documented decorative exception; ≥3:1 on both resting backdrops, meaning carried by the adjacent label (WCAG 2.1 SC 1.4.11) |
| Remove control | `text-reset bg-transparent border-0` | Inherits the chip foreground; pins no colour and **no `opacity`** |

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

- **The chip renders an AA-clean, theme-adaptive pair.** `bg-{sem}-subtle` +
  `text-{sem}-emphasis` is browser-measured at 9.34:1–10.52:1 in light mode and
  7.15:1–8.61:1 in dark, for all five distinct hues (`spec/features/contrast_spec.rb`).
  The remove control inherits that foreground and is not faded — the retired `opacity: 0.6`
  composited it well below the floor.
- **Historical:** the retired hex pairs did NOT meet WCAG AA. Re-derived contrast ratios
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
- **One colour system, `GROUP_VARIANTS` (#168).** Every tag-group renderer resolves through
  the shared mapping, so a category renders the same adaptive hue everywhere. This reverses
  the #151-era guidance that the chip's own rendering should stay on brand hex: that split
  existed only to keep #151's blast radius small, and it shipped a cross-consumer
  inconsistency plus seven sub-AA pairs. Do not reintroduce a second colour path — and in
  particular do not pair a `-subtle` surface with a solid `bg-{sem}` dot, which fails the
  decorative 3:1 floor
- **Do not** create new color pairs without adding them to `tokens/colors.md` — and add the
  matching `GROUP_VARIANTS` entry so converted consumers don't fall back to `secondary`
- Tags always inherit their parent group's color — never assign colors to individual tags
