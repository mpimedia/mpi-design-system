# Pagination

**Category:** Component
**Issue:** #18
**Status:** Approved

## Description

Page navigation for list views. Shows a "Showing X–Y of Z results" summary on the left and numbered page buttons on the right. Used below DataTable and other paginated lists.

## Design Decisions

- **Layout:** Left-aligned results text + right-aligned page buttons (flexbox `justify-content-between`)
- **Results text:** "Showing X–Y of Z results" in primary blue (`#2E75B6`), 13px
- **Page buttons:** 32×32px, `border-radius: 6px`, border `#DEE2E6`
- **Active page:** Filled primary blue (`#2E75B6`) background with white text
- **Arrow buttons:** `→` and `←` characters (not chevron icons)
- **First page:** No left arrow shown (arrow is absent, not disabled)
- **Last page:** No right arrow shown
- **Separator:** Top border (`#DEE2E6`) above the pagination bar

## Variants

| Variant | Description |
|---|---|
| **Default** | Results text + page numbers + arrows |
| **First page** | Active page 1, right arrow only |
| **Middle page** | Left arrow + pages + right arrow |
| **Last page** | Left arrow + pages, active on last |

## States

| State | Element | Description |
|---|---|---|
| Default | Page button | White background, gray border, dark text |
| Hover | Page button | Blue border (`#2E75B6`), blue text |
| Active | Page button | Filled blue background, white text, blue border |
| Disabled | Arrow button | Light gray text (`#CED4DA`), `cursor: not-allowed` |

## Props / API

```ruby
# Admin::Pagination::Component
class Admin::Pagination::Component < ViewComponent::Base
  # @param current_page [Integer] Current active page (1-based)
  # @param total_pages [Integer] Total number of pages
  # @param total_count [Integer] Total number of records
  # @param per_page [Integer] Records per page (default: 25)
  # @param url_builder [Proc] Lambda that builds page URLs: ->(page) { "?page=#{page}" }
  # @param turbo_frame [String] Turbo Frame target for page loads
end
```

## Bootstrap Classes

- `d-flex`, `align-items-center`, `justify-content-between` — layout
- `gap-1` — spacing between page buttons
- Custom `.page-btn` (32×32px, border-radius 6px)
- `border-top` — separator above pagination

## Key Styles

```css
.showing-text { font-size: 13px; color: #2E75B6; }
.page-btn { width: 32px; height: 32px; border-radius: 6px; border: 1px solid #DEE2E6; font-size: 13px; font-weight: 500; }
.page-btn.active { background: #2E75B6; color: #fff; border-color: #2E75B6; }
.page-btn:hover { border-color: #2E75B6; color: #2E75B6; }
.page-btn.disabled { color: #CED4DA; cursor: not-allowed; }
```

## Accessibility

- Wrap in `<nav aria-label="Pagination">`
- Current page: `aria-current="page"`
- Arrow buttons: `aria-label="Previous page"` / `aria-label="Next page"`
- Disabled arrows: `aria-disabled="true"`
- Page buttons: `aria-label="Page N"`
- Results text provides context for screen readers

## Usage Guidelines

- **Use** below DataTable on all paginated list views
- **Use** Turbo Frame navigation for page changes (no full page reload)
- **Do not** show ellipsis (...) for now — show all page numbers (page counts are typically small in CRM)
- **Do not** add a per-page selector unless explicitly requested
- The results text always shows even on single-page results ("Showing 1–6 of 6 results")
- Page buttons should be links (`<a>`) for proper URL state and back button support
