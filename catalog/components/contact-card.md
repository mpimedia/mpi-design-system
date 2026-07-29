# ContactCard

**Category:** Component
**Issue:** #23
**Status:** Approved

## Description

Compact card for the grid/card view of contacts. Used as an alternative to the list table (ContactListRow) when the user toggles to card view via ListCardToggle. Shows avatar, name, company, colored pill tags, last engagement date, and internal owner.

Displayed in a responsive grid: 3 columns on desktop, 2 on tablet, 1 on mobile.

## Design Decisions

- **Pill tags** — Tags use colored pill badges matching their group color pair (not dot-format, not blue text). Group name is implied by color; only the sub-category is shown (e.g., "Theatrical" not "Acquisitions")
- **Tag redundancy** — When a contact has multiple tags from the same group, each shows as a separate pill but the group prefix is omitted since color encodes the group
- **Tag wrapping** — Tags wrap to multiple lines when there are many (no truncation)
- **Owner field** — Bottom-right shows "Owner: Name" (internal contact owner), replacing the former engagement count
- **Left alignment** — Avatar left-aligned with name/company to the right (not centered)
- **Reduced density** — Minimal text, only name is bold. Company in gray. Metadata line in light gray (`#ADB5BD`, 11px)
- **Hover state** — Blue border (`#2E75B6`) on hover with `transition: border-color 0.15s ease`
- **Responsive grid** — Uses `col-lg-4 col-md-6 col-12`

## Variants

| Variant | Description |
|---|---|
| **Default** | Standard card with avatar, name, company, tags, metadata |
| **Hover** | Blue border highlight on mouse hover |
| **Many tags** | Tags wrap to additional lines |
| **Single tag** | Minimal card with one tag pill |

## States

| State | Description |
|---|---|
| Default | White card, gray border (`#DEE2E6`) |
| Hover | Blue border (`#2E75B6`) |

## Props / API

```ruby
# MpiDesignSystem::Admin::ContactCard::Component
class MpiDesignSystem::Admin::ContactCard::Component < ViewComponent::Base
  # @param name [String] Contact full name
  # @param initials [String] Two-letter initials for avatar
  # @param avatar_color [String] Hex color for avatar background (deterministic from name hash)
  # @param company [String] Company/organization name
  # @param tags [Array<Hash>] Each: { label: String, color: String, bg_color: String }
  #   label = sub-category only (e.g., "Theatrical"), color = text color, bg_color = background
  # @param last_engaged [String] Relative time (e.g., "2 days ago")
  # @param owner_name [String] Internal owner display name (e.g., "J. Smith")
  # @param path [String] URL to contact detail page
end
```

## Tag Group Color Pairs

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

> **Naming note.** This table previously listed the groups as Buyers / Press / Festivals /
> Sellers / Institutional / Organizations — a legacy vocabulary that no component has ever
> accepted, and which contradicted `badge.md` and `tag-chip.md`. The keys above are the ones
> `GROUP_VARIANTS` actually validates. The legacy names still appear in the unused
> `$mpi-tag-*` SCSS tokens and `tokens/colors.md`; reconciling those is tracked in ISS#181.

## Bootstrap Classes

- `row`, `g-3`, `col-lg-4`, `col-md-6`, `col-12` — responsive grid
- `d-flex`, `align-items-center`, `gap-2` — avatar + name row
- `d-flex`, `flex-wrap`, `gap-1` — tag pills row
- `d-flex`, `justify-content-between` — metadata row
- Custom: `.contact-card`, `.avatar`, `.avatar-md`, `.card-name`, `.card-company`, `.tag-pill`, `.card-meta`

## Key Styles

```css
.contact-card { background: #fff; border: 1px solid #DEE2E6; border-radius: 8px; padding: 16px; }
.contact-card:hover { border-color: #2E75B6; }
.tag-pill { display: inline-block; padding: 2px 8px; border-radius: 999px; font-size: 11px; font-weight: 500; }
.card-meta { font-size: 11px; color: #ADB5BD; }
```

## Accessibility

- Entire card is a clickable link (`<a>`) — ensure focus ring is visible
- Avatar foregrounds are derived per background by `MpiDesignSystem::ColorContrast`,
  so each meets WCAG AA. (The earlier "white text on all backgrounds" claim was false —
  7 of 10 palette colours measured below the floor; fixed in #130.)
- Tag pills render `bg-{semantic}-subtle` + `text-{semantic}-emphasis` from the shared
  `GROUP_VARIANTS` map, which Bootstrap derives AA-clean in both colour modes. The
  earlier claim that the *hex* pairs "all meet WCAG AA contrast" was false — every one
  measured 2.77:1–4.34:1 (ISS#142 §1), including the no-group default at 4.34:1 (#168)
- A tag carrying caller-supplied `color:`/`bg_color:` is a deliberate passthrough and is
  the **caller's** contrast responsibility
- Metadata text in `#ADB5BD` is supplementary (not critical info), but consider `#6C757D` if contrast is borderline

## Usage Guidelines

- **Use** in the card grid view toggled via ListCardToggle (#27)
- **Do not** use in the list/table view — use ContactListRow (#22) instead
- **Do not** show the group prefix in tag pills — color encodes the group
- The Owner field is critical for CRM workflows — always show it
- Card grid is the secondary view; list is the default
