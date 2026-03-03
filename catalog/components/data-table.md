# DataTable

**Category:** Component
**Issue:** #17
**Status:** Approved

## Description

Sortable data table for CRM list views. Used for contacts, search results, and other record listings. Features avatar + name cells, tag dot indicators, relative timestamps, and linked account names.

## Design Decisions

- **Row structure:** Avatar + Name/Title in first column, Tags with colored dots, Last Engagement as relative time, Account as blue link
- **Tag format:** Colored dot + "Group — Role" text (e.g., `● Buyer — Theatrical`), not pill badges in table rows
- **Status format:** Colored dot + text (e.g., `● Active`, `● Follow up`)
- **Search results variant:** Adds "Match Found In" and "Status" columns with keyword highlighting (`<strong>`)
- **Account names:** Blue links (`#2E75B6`) that navigate to account detail
- **Header style:** ALL-CAPS, 11px, `font-weight: 600`, `letter-spacing: 0.06em`, color `#6C757D`
- **Row hover:** Uses Bootstrap `table-hover` for subtle row highlighting

## Variants

| Variant | Columns | Source |
|---|---|---|
| **Contacts** | Name, Tags, Last Engagement, Account | Screen 2 |
| **Search Results** | Name, Tags, Match Found In, Last Engaged, Status | Screen 6 |

## Column Specifications

### Contacts Table (Screen 2)

| Column | Content | Width |
|---|---|---|
| Name | AvatarCircle (36px) + Name (bold, `#1B2A4A`) + Title (muted, 12px) | ~30% |
| Tags | Colored dots with "Group — Role" text, wrapping | ~30% |
| Last Engagement | Relative time ("2 days ago", "1 week ago"), muted 13px | ~20% |
| Account | Blue link to account | ~20% |

### Search Results Table (Screen 6)

| Column | Content |
|---|---|
| Name | Same as contacts + keyword highlighting in title |
| Tags | Same as contacts |
| Match Found In | Source description with keyword `<strong>` highlighting |
| Last Engaged | Relative time |
| Status | Colored dot + status text (Active/Follow up) |

## Tag Dot Colors

Dots use the tag group primary colors from `tokens/colors.md`:

| Group | Dot Color |
|---|---|
| Buyers | `#E8733A` |
| Press | `#2DA67E` |
| Festivals | `#2E75B6` |
| Sellers | `#8B5CF6` |
| Internal | `#64748B` |

## States

| State | Description |
|---|---|
| Default | Normal row display |
| Hover | Subtle background highlight (Bootstrap `table-hover`) |
| Selected | TBD — bulk selection pattern not yet designed |
| Empty | Shows EmptyState component |
| Loading | Skeleton placeholder rows or spinner |

## Props / API

```ruby
# Admin::DataTable::Component
class Admin::DataTable::Component < ViewComponent::Base
  # @param columns [Array<Hash>] Column definitions:
  #   [{ key: :name, label: "Name", sortable: true },
  #    { key: :tags, label: "Tags" },
  #    { key: :last_engagement, label: "Last Engagement", sortable: true },
  #    { key: :account, label: "Account" }]
  # @param rows [Array<Hash>] Row data
  # @param sort_by [Symbol] Current sort column
  # @param sort_dir [Symbol] :asc or :desc
  # @param variant [Symbol] :contacts (default), :search_results
end
```

## Bootstrap Classes

- `table` — base table
- `table-hover` — row hover effect
- Custom header styles (ALL-CAPS, small font)
- `d-flex`, `align-items-center`, `gap-2` — name cell layout
- `flex-wrap` — tag wrapping in tag cells
- `align-middle` — vertical centering in cells

## Key Styles

```css
th { font-size: 11px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.06em; color: #6C757D; }
.contact-name { font-weight: 600; color: #1B2A4A; font-size: 14px; }
.contact-title { font-size: 12px; color: #6C757D; }
.tag-dot { width: 6px; height: 6px; border-radius: 50%; }
.account-link { color: #2E75B6; font-size: 13px; }
.meta-text { font-size: 13px; color: #6C757D; }
```

## Accessibility

- Use `<table>`, `<thead>`, `<tbody>`, `<th>`, `<td>` — proper semantic table markup
- Sortable columns: `<th>` with `aria-sort="ascending|descending|none"`
- Account links must be focusable and have descriptive text
- Tag dots are decorative — the color meaning is conveyed by the text label
- Row selection (future): use `<input type="checkbox">` with `aria-label`

## Usage Guidelines

- **Use** contacts variant for the main contact list view (CRM > Contacts)
- **Use** search results variant when showing filtered/searched results with match context
- **Do not** show more than 5-6 columns — table becomes unreadable
- **Do not** use tag chips (pill badges) in table rows — use dot + text format instead
- Combine with Pagination component below the table
- Combine with FilterChipBar above the table
- Sorting triggers a Turbo Frame reload of the table body
