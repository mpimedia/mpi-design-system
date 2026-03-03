# ContactListRow

**Category:** Component
**Issue:** #22
**Status:** Approved

## Description

Table row component for the CRM contacts list view. Displays a contact's avatar with initials, full name and title, tags in dot format, last engagement time, and linked account. Also supports a search result variant with additional "Match Found In" and "Status" columns.

## Design Decisions

- **Avatar:** 36px circle with deterministic color from contact name hash, white initials (2 chars)
- **Name column:** Bold name (`#1B2A4A`, 14px, 600 weight) + smaller gray title below (12px, `#6C757D`)
- **Tag format:** Colored dot (6px circle) + "Group -- Role" text (13px, 500 weight). Uses tag group primary colors for dots
- **Last Engagement:** Relative time format ("2 days ago", "1 week ago") in muted gray (13px, `#6C757D`)
- **Account:** Blue link (`#2E75B6`, 13px) to the account detail page
- **Search variant:** Adds "Match Found In" column (with bold keyword highlight) and "Status" column (dot + "Active" in success green)
- **Column headers:** 11px, uppercase, `letter-spacing: 0.06em`, muted gray (`#6C757D`)

## Variants

| Variant | Description |
|---|---|
| **Default** | Standard 4-column row: Name, Tags, Last Engagement, Account |
| **Search Result** | Extended 5-column row: Name, Tags, Match Found In, Last Engaged, Status. Keyword matches bolded in name subtitle and match column |

## States

| State | Description |
|---|---|
| Default | Standard row styling |
| Hover | Bootstrap `table-hover` highlight |
| Selected | Future: row selection for bulk actions (not yet designed) |

## Props / API

```ruby
# Admin::ContactListRow::Component
class Admin::ContactListRow::Component < ViewComponent::Base
  # @param contact [Contact] Contact record
  # @param avatar_color [String] Hex color from deterministic hash
  # @param initials [String] Two-character initials
  # @param name [String] Full name
  # @param title [String] Job title
  # @param tags [Array<Hash>] Each: { group: String, role: String, color: String }
  # @param last_engagement [String] Relative time string
  # @param account_name [String] Linked account name
  # @param account_path [String] URL to account detail
  # @param variant [Symbol] :default (default), :search_result
  # @param match_text [String] Optional search match context (search variant only)
  # @param status [Symbol] Optional :active, :inactive (search variant only)
end
```

## Bootstrap Classes

- `table`, `table-hover` -- table base with hover rows
- `d-flex`, `align-items-center`, `gap-2` -- avatar + name layout within cell
- `d-flex`, `flex-wrap`, `gap-2` -- tag list wrapping
- `align-middle` -- vertical alignment in table cells
- Custom `.avatar-md` (36px), `.tag-dot` (6px), `.contact-name`, `.contact-title`, `.account-link`, `.meta-text`

## Accessibility

- Table rows are standard `<tr>` elements within a `<table>` for screen reader compatibility
- Account links have descriptive text (account name)
- Avatar is decorative (no `aria-label` needed since name is in adjacent text)
- Search result keyword highlights use `<strong>` (not just visual bold) for screen readers
- Tag dots are decorative; group name is in the adjacent text

## Usage Guidelines

- **Use** as the row component inside the CRM contacts list view
- **Use** the search variant when rendering search results with match context
- **Do not** use outside a `<table>` context -- this is a table row, not a card
- Tags wrap naturally when a contact has many tags; keep tag text concise
- The search variant should only appear in search result contexts, never in the default contact list
