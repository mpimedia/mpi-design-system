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
# Admin::ContactCard::Component
class Admin::ContactCard::Component < ViewComponent::Base
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

| Group | Text Color | Background |
|---|---|---|
| Buyers | `#E8733A` | `#FEF3EC` |
| Press | `#2DA67E` | `#ECF8F4` |
| Festivals | `#2E75B6` | `#EBF3FB` |
| Sellers | `#8B5CF6` | `#F3EFFE` |
| Institutional | `#D97706` | `#FEF9EC` |
| Organizations | `#6366F1` | `#EEEFFE` |
| Internal | `#64748B` | `#F1F5F9` |

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
- Avatar colors meet WCAG AA for white text
- Tag pill text/background pairs all meet WCAG AA contrast
- Metadata text in `#ADB5BD` is supplementary (not critical info), but consider `#6C757D` if contrast is borderline

## Usage Guidelines

- **Use** in the card grid view toggled via ListCardToggle (#27)
- **Do not** use in the list/table view — use ContactListRow (#22) instead
- **Do not** show the group prefix in tag pills — color encodes the group
- The Owner field is critical for CRM workflows — always show it
- Card grid is the secondary view; list is the default
