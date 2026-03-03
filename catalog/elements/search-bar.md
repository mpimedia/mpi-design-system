# SearchBar

**Category:** Element
**Issue:** #14
**Status:** Approved

## Description

Search input with icon prefix, used for filtering lists, contacts, and content throughout all MPI apps. Most implementations use search-as-you-type; an explicit search button variant is available for cases that require server-side search.

## Design Decisions

- **Icon:** Bootstrap Icons `bi-search` in a prepended `input-group-text`
- **Focus color:** Primary blue `#2E75B6` ring (`box-shadow: 0 0 0 0.2rem rgba(46, 117, 182, 0.25)`)
- **Clear button:** `×` button appears when value is present (uses `bi-x-lg`)
- **Search-as-you-type:** Primary interaction pattern — most list pages use client-side or Turbo Frame filtering
- **Button variant:** Optional explicit "Search" button kept for pages requiring server-side search
- **Placeholder:** Contextual (e.g., "Search contacts...", "Search titles...")

## Variants

| Variant | Description |
|---|---|
| **Default** | Icon + input + placeholder text |
| **With Value** | Icon + input with text + clear button |
| **With Search Button** | Icon + input + explicit "Search" button (primary) |
| **Full Width** | Large input (`form-control-lg`) for page-level search |

## States

| State | Description |
|---|---|
| Empty | Placeholder visible, no clear button |
| Focused | Primary blue focus ring |
| With Value | Clear button (`×`) appears on the right |
| Disabled | Muted, no interaction |

## Props / API

```ruby
# Admin::SearchBar::Component
class Admin::SearchBar::Component < ViewComponent::Base
  # @param placeholder [String] Placeholder text (default: "Search...")
  # @param value [String] Current search value
  # @param name [String] Input name attribute (default: "q")
  # @param size [Symbol] :md (default), :lg (full-width variant)
  # @param show_button [Boolean] Show explicit "Search" button (default: false)
  # @param url [String] Form action URL (for server-side search)
  # @param turbo_frame [String] Turbo Frame target for search results
  # @param data [Hash] data-* attributes for Stimulus controllers
end
```

## Bootstrap Classes

- `input-group` — wrapper for icon + input + button
- `input-group-text` — search icon container (with `bg-white`)
- `form-control` — text input
- `form-control-lg` — large variant
- `btn btn-outline-secondary` — clear button
- `btn btn-primary` — search button (when shown)
- `bi-search` — search icon
- `bi-x-lg` — clear icon

## SCSS Override

```scss
.form-control:focus {
  border-color: #2E75B6;
  box-shadow: 0 0 0 0.2rem rgba(46, 117, 182, 0.25);
}
```

## Accessibility

- Input must have `aria-label="Search"` (or a visible `<label>`)
- Clear button must have `aria-label="Clear search"`
- Search button (when present) is the form submit — keyboard Enter works in either case
- Use `role="search"` on the containing `<form>` element
- Announce result count changes to screen readers with `aria-live="polite"` on the results container

## Usage Guidelines

- **Use** search-as-you-type for CRM list filtering (contacts, accounts, engagements)
- **Use** button variant only when server-side search is required (e.g., full-text content search)
- **Use** full-width (`lg`) variant for page-level search (Screen 5 initial state)
- **Do not** use both search-as-you-type and a search button on the same input
- Composes naturally with FilterChipBar — search bar above, active filter pills below
- Wrap in a `<form>` with `data-turbo-frame` for Turbo-powered search
