# App Shell

**Category:** Layout
**Issue:** #28
**Status:** Approved

## Description

Global application frame used on every page of every MPI app. Provides the Nexus brand mark, Level 1 navigation (6 Markaz-wide sections), global search, user avatar, and optional Level 2 sub-navigation. Some sections also include a content sidebar browser. This is the outermost layout wrapper -- all page content renders inside it.

## Design Decisions

- **Brand mark:** Nexus SVG diamond logo (navy `#1B2A4A` arms + primary blue `#2E75B6` center diamond) + "MARKAZ" text (`font-weight: 300`, `letter-spacing: 0.12em`, `color: #1B2A4A`). NOT "X MARKAZ" text -- corrected after design review
- **White background:** Canonical style (V2). Both top bar and sub-nav use white background with bottom border (`#DEE2E6`)
- **Top bar height:** 52px. Sub-nav height: 42px
- **Level 1 nav:** 6 items -- Dashboard, Content, CRM, Rights & Avails, Releases, Screenings
- **Level 2 nav:** Section-specific. CRM: Dashboard, Contacts, Accounts, Engagements. Other sections TBD
- **Global search:** Right-aligned input with search icon, contextual placeholder based on current section. 240px wide, `background: #F5F7FA`, `border-radius: 6px`
- **User avatar:** 32px AvatarCircle component with user initials, primary blue (`#2E75B6`), right of search
- **Content sidebar:** Section-specific (confirmed `tokens/components.md`). Content section gets a title list sidebar with Titles/Library tabs, search, label filter chips, and a scrollable title list with metadata scores. Other sections do not have a sidebar by default
- **Content area:** `background: #F5F7FA`, `padding: 24px`. All page content renders here
- **Content Dashboard question:** Open -- Badie wants content search easily accessible. May get a dedicated Content Dashboard or the global Dashboard may default to showing title search. This is a product decision to be resolved separately

## Variants

| Variant | Description |
|---|---|
| **Level 1 only** | Top bar with no sub-nav (e.g., Dashboard section). Content renders directly below |
| **Level 1 + Level 2** | Top bar + section-specific sub-nav (e.g., CRM with Contacts active) |
| **Level 1 + Sidebar** | Top bar + content sidebar browser (e.g., Content section). No sub-nav bar, sidebar on left with content detail on right |

## Zones

```
+--------------------------------------------------------------+
|  [Nexus]  MARKAZ  | Nav Items...           | [Search] [Avatar]|  <- Top Bar (52px)
+--------------------------------------------------------------+
|  Sub-nav items...                                             |  <- Sub-Nav (42px, optional)
+--------------------------------------------------------------+
|          |                                                    |
| Sidebar  |               Page Content                         |  <- Content Area
| (optional)|                                                   |
+----------+----------------------------------------------------+
```

## Props / API

```ruby
# Admin::AppShell::Component
class Admin::AppShell::Component < ViewComponent::Base
  # @param current_section [Symbol] :dashboard, :content, :crm, :rights_avails, :releases, :screenings
  # @param current_subsection [Symbol] Section-specific (e.g., :contacts, :accounts for CRM)
  # @param user_name [String] Current user name (for avatar)
  # @param user_initials [String] Two-character initials (for avatar)
  # @param search_url [String] Global search action URL
  # @param search_placeholder [String] Contextual placeholder text
  # @param show_sidebar [Boolean] Whether to show the content sidebar (default: false)
  #
  # Renders content via a block/slot:
  # renders_one :sidebar  # Optional sidebar slot
  # renders_one :content  # Main content area
end
```

## Bootstrap Classes

- `d-flex`, `align-items-center` -- top bar and sub-nav layout
- `border-bottom` -- separator between bars
- `position-relative` -- search input icon positioning
- `flex-grow-1` -- content area fill
- Custom `.topbar` (52px), `.subnav` (42px), `.logo`, `.logo-mark`, `.logo-text`, `.nav-item`, `.subnav-item`, `.nav-search`, `.avatar-nav`, `.sidebar`

## Key Styles

```css
.topbar { background: #fff; border-bottom: 1px solid #DEE2E6; height: 52px; padding: 0 24px; }
.subnav { background: #fff; border-bottom: 1px solid #DEE2E6; height: 42px; padding: 0 24px; }
.nav-item { color: #6C757D; padding: 14px 12px; font-size: 14px; font-weight: 500; }
.nav-item.active { color: #2E75B6; border-bottom: 2px solid #2E75B6; font-weight: 600; }
.sidebar { width: 180px; border-right: 1px solid #DEE2E6; background: #fff; padding: 16px; }
.content-area { padding: 24px; background: #F5F7FA; }
```

## Accessibility

- Top bar uses `<nav>` with `aria-label="Main navigation"`
- Sub-nav uses `<nav>` with `aria-label="Section navigation"`
- Active nav item uses `aria-current="page"`
- Search input has `aria-label="Search"` with contextual placeholder
- Brand mark link returns to root/dashboard
- Mobile: top bar collapses into hamburger menu (Bootstrap `navbar-toggler`)
- Keyboard: Tab through nav items, Enter/Space to activate
- Sidebar is a complementary landmark when present

## Usage Guidelines

- **Use** on every page of every MPI app as the outermost layout wrapper
- **Do not** nest App Shell components -- there is exactly one per page
- **Do not** add items to Level 1 nav without updating `tokens/navigation.md`
- **Do not** use a sidebar for primary navigation -- this is a top-bar-only pattern
- The Nexus brand mark must always link to the app's root/dashboard
- Search placeholder should be contextual: "Search contacts..." in CRM, "Search titles..." in Content, etc.
- The sidebar is only used in the Content section -- do not force a sidebar on other sections
- All apps share this shell; app-specific differences should be limited to which sections appear and their sub-nav items
