# NavBar

**Category:** Component
**Issue:** #15
**Status:** Approved

## Description

Two-level horizontal navigation used as the primary app shell navigation across all MPI apps. Level 1 shows Markaz-wide sections (always visible). Level 2 shows section-specific sub-navigation that appears below when a section is active.

## Design Decisions

- **Brand mark:** Nexus SVG diamond logo (navy `#1B2A4A` arms + primary blue `#2E75B6` center diamond) — NOT "X MARKAZ" text logo
- **MARKAZ text:** `font-weight: 300`, `letter-spacing: 0.12em`, color `#1B2A4A`
- **White background:** Both bars use white background with bottom border (`#DEE2E6`)
- **Active state:** Primary blue text (`#2E75B6`) + 2px blue bottom border + `font-weight: 600`
- **Inactive state:** Muted gray text (`#6C757D`), `font-weight: 500`
- **Top bar height:** 52px
- **Sub-nav height:** 42px
- **Right side:** Global search input + user avatar (AvatarCircle component)

## Navigation Structure

### Level 1 — Markaz Top Bar (Always Visible)

| Position | Label | Notes |
|---|---|---|
| 1 | Dashboard | App-wide overview |
| 2 | Content | Includes Assets (formerly separate) |
| 3 | CRM | Customer relationship management |
| 4 | Rights & Avails | Combined (formerly separate sections) |
| 5 | Releases | Standalone section |
| 6 | Screenings | Standalone section |

### Level 2 — CRM Sub-Nav

| Position | Label |
|---|---|
| 1 | Dashboard |
| 2 | Contacts |
| 3 | Accounts |
| 4 | Engagements |

Other section sub-navs will be documented as their designs are finalized.

## Variants

| Variant | Description |
|---|---|
| **Level 1 only** | Top bar with no sub-nav (e.g., Dashboard section) |
| **Level 1 + Level 2** | Top bar + section sub-nav (e.g., CRM with Contacts active) |

## States

| State | Element | Description |
|---|---|---|
| Default | Nav item | Gray text (`#6C757D`), no underline |
| Hover | Nav item | Primary blue text (`#2E75B6`) |
| Active | Nav item | Primary blue text + bold (600) + 2px blue bottom border |
| Active | Sub-nav item | Same as nav item active state |

## Props / API

```ruby
# Admin::NavBar::Component
class Admin::NavBar::Component < ViewComponent::Base
  # @param current_section [Symbol] :dashboard, :content, :crm, :rights_avails, :releases, :screenings
  # @param current_subsection [Symbol] Section-specific (e.g., :contacts, :accounts for CRM)
  # @param user_name [String] Current user name (for avatar)
  # @param search_url [String] Global search action URL
end
```

## Bootstrap Classes

- `navbar` — could be used as base, but preview uses custom flexbox layout
- `nav-link` — individual nav items
- `d-flex`, `align-items-center` — top bar and sub-nav layout
- `border-bottom` — separator between bars
- `position-relative` — search input icon positioning
- Custom `.topbar`, `.subnav`, `.nav-item`, `.subnav-item` classes

## Key Styles

```css
.topbar { background: #fff; border-bottom: 1px solid #DEE2E6; height: 52px; }
.subnav { background: #fff; border-bottom: 1px solid #DEE2E6; height: 42px; }
.nav-item { font-size: 14px; padding: 14px 12px; border-bottom: 2px solid transparent; }
.nav-item.active { color: #2E75B6; border-bottom-color: #2E75B6; font-weight: 600; }
.logo-text { font-weight: 300; letter-spacing: 0.12em; color: #1B2A4A; font-size: 14px; }
```

## Accessibility

- Nav bars use `<nav>` element with `aria-label="Main navigation"` and `aria-label="Section navigation"`
- Active item uses `aria-current="page"`
- Keyboard navigation: Tab through items, Enter/Space to activate
- Mobile: Collapse into hamburger menu (Bootstrap `navbar-toggler`)
- Search input has `aria-label="Search"`

## Usage Guidelines

- **Use** on every page of every MPI app as the primary navigation
- **Use** Level 1 only for sections without sub-navigation
- **Use** Level 1 + Level 2 for sections with sub-pages (CRM, Content, etc.)
- **Do not** add items to Level 1 without updating `tokens/navigation.md`
- **Do not** use a sidebar for primary navigation — this is a top-bar-only pattern
- The Nexus SVG brand mark must link to the app's root/dashboard
- Search input placeholder should be contextual to the current section
