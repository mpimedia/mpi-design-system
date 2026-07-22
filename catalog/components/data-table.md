# DataTable

**Category:** Component
**Issue:** #17
**Status:** Approved

## Description

Sortable data table for CRM list views. Used for contacts, search results, and other record listings. Features avatar + name cells, tag dot indicators, relative timestamps, and linked account names.

## Design Decisions

- **Row structure:** Avatar + Name/Title in first column, Tags with colored dots, Last Engagement as relative time, Account as an adaptive link
- **Tag format:** Semantic dot (`bg-#{sem}` via `GROUP_VARIANTS`) + "Group — Role" text (e.g., `● Acquisitions`), not pill badges in table rows
- **Status format:** Semantic dot (`bg-#{sem}` via `STATUS_VARIANTS`) + text (e.g., `● Active`, `● Follow up`)
- **Search results variant:** Adds "Match Found In" and "Status" columns with keyword highlighting (`<strong>`)
- **Account names:** Links in Bootstrap's default adaptive colour (`--bs-link-color`; `#2E75B6`
  in light, `#82ACD3` in dark) with their natural underline, navigating to account detail (#151)
- **Header style:** ALL-CAPS, 11px, `font-weight: 600`, `letter-spacing: 0.06em`, muted via
  `text-body-secondary`; the 2px separator is the `border-bottom` utility with an inline
  `--bs-border-width: 2px` (bottom edge only — `border-2` would box all four sides of a `.table th`) (#151)
- **Row hover:** Uses Bootstrap `table-hover` for subtle row highlighting
- **Theme-adaptive:** Every colour resolves from a Bootstrap utility (`--bs-*`), so the table
  follows `data-bs-theme`. The one exception is the decorative tag/status **dots**, which keep a
  fixed identity hue across colour modes (see Accessibility) (#151)

## Variants

| Variant | Columns | Source |
|---|---|---|
| **Contacts** | Name, Tags, Last Engagement, Account | Screen 2 |
| **Search Results** | Name, Tags, Match Found In, Last Engaged, Status | Screen 6 |

## Column Specifications

### Contacts Table (Screen 2)

| Column | Content | Width |
|---|---|---|
| Name | AvatarCircle (36px) + Name (bold, `text-body`) + Title (`text-body-secondary`, 12px) | ~30% |
| Tags | Semantic dots with "Group — Role" text, wrapping | ~30% |
| Last Engagement | Relative time ("2 days ago", "1 week ago"), `text-body-secondary` 13px | ~20% |
| Account | Adaptive link (`--bs-link-color`) to account | ~20% |

### Search Results Table (Screen 6)

| Column | Content |
|---|---|
| Name | Same as contacts + keyword highlighting in title |
| Tags | Same as contacts |
| Match Found In | Source description with keyword `<strong>` highlighting |
| Last Engaged | Relative time |
| Status | Colored dot + status text (Active/Follow up) |

## Tag & Status Dot Colors

Dots are `bg-#{sem}` where `#{sem}` comes from `GROUP_VARIANTS` (tags) / `STATUS_VARIANTS`
(status) — see `catalog/elements/tag-chip.md` § Semantic Mapping. `bg-*` reads
`--bs-#{sem}-rgb`, a fixed hue across colour modes (decorative identity; the label carries the
meaning). An unknown group or status falls back to `secondary` (#151).

| Group / Status | Semantic | Dot |
|---|---|---|
| Distribution | `danger` | `bg-danger` (red) |
| Outreach | `success` | `bg-success` (green) |
| Finance | `warning` | `bg-warning` (amber) |
| Press/Festival · Production · Vendors | `primary` | `bg-primary` (blue) |
| Internal | `secondary` | `bg-secondary` (grey) |
| Status: Active | `success` | `bg-success` |
| Status: Follow up | `warning` | `bg-warning` |
| Status: Inactive | `secondary` | `bg-secondary` |

## States

| State | Description |
|---|---|
| Default | Normal row display |
| Hover | Subtle background highlight (Bootstrap `table-hover`) |
| Selected | TBD — bulk selection pattern not yet designed |
| Empty | Renders the `<thead>` with an **empty `<tbody>`** — the component does not render an EmptyState (the consumer is responsible for an empty-state message around the table) |
| Loading | Skeleton placeholder rows or spinner |

## Props / API

```ruby
# MpiDesignSystem::Admin::DataTable::Component
class MpiDesignSystem::Admin::DataTable::Component < ViewComponent::Base
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

After #151 every colour comes from a Bootstrap utility; only geometry is declared inline
(classes shown in comments, not the pinned hex they replaced):

```css
/* th: classes `text-body-secondary border-bottom`; inline `--bs-border-width: 2px` widens
   the border-bottom to 2px on the bottom edge only. */
th            { font-size: 11px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.06em; }
/* .contact-name: class `text-body` (div) + anchor `text-body text-decoration-none` */
.contact-name { font-weight: 600; font-size: 14px; }
/* .contact-title, .meta-text: class `text-body-secondary` */
.contact-title { font-size: 12px; }
.meta-text     { font-size: 13px; }
/* .tag-dot: class `d-inline-block bg-#{sem}` (fill), geometry only inline */
.tag-dot      { width: 6px; height: 6px; border-radius: 50%; }
/* .account-link: NO colour class — paints --bs-link-color and keeps its underline */
.account-link { font-size: 13px; }
/* td: class `align-middle` */
```

## Accessibility

- Use `<table>`, `<thead>`, `<tbody>`, `<th>`, `<td>` — proper semantic table markup
- Sortable columns: `<th>` with `aria-sort="ascending|descending|none"`
- Account links must be focusable and have descriptive text; they keep their underline as the
  navigation affordance and paint the adaptive `--bs-link-color` (AA in both colour modes)
- Tag/status dots are **decorative** — the meaning is conveyed by the adjacent text label, so
  the dots keep a **fixed identity hue across colour modes** (an intentional exception to the
  table's otherwise theme-adaptive palette, mirroring the nav env-bar's fixed status hues).
  Each dot is browser-proven ≥3:1 against **both** the light and dark row backdrops (#151)
- Row selection (future): use `<input type="checkbox">` with `aria-label`

## Usage Guidelines

- **Use** contacts variant for the main contact list view (CRM > Contacts)
- **Use** search results variant when showing filtered/searched results with match context
- **Do not** show more than 5-6 columns — table becomes unreadable
- **Do not** use tag chips (pill badges) in table rows — use dot + text format instead
- Combine with Pagination component below the table
- Combine with FilterChipBar above the table
- Sorting triggers a Turbo Frame reload of the table body
