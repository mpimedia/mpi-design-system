# NavBar

**Category:** Component
**Issue:** #15
**Status:** Approved

## Description

Two-level horizontal navigation used as the primary app shell navigation across all MPI apps. Level 1 shows Markaz-wide sections (always visible). Level 2 shows section-specific sub-navigation that appears below when a section is active.

## Design Decisions

- **Theme-adaptive colours (#154):** every colour in `_nav_bar.scss` resolves from a
  Bootstrap **runtime CSS custom property** (`var(--bs-*)`), not a frozen hex — so the nav
  follows `data-bs-theme`. Under the default (light) MPI configuration the values below still
  resolve, but they are now the consumer's mapped Bootstrap tokens, not hardcoded literals.
- **Brand mark:** Nexus SVG diamond logo — NOT "X MARKAZ" text logo. The default mark's fills are
  **token-sourced**, not hardcoded hex: the arm polygons carry `.mds-navbar__brand-arm` (filled
  from `var(--bs-body-color)`) and the centre polygon carries `.mds-navbar__brand-center` (filled
  from `var(--bs-link-color)`), each with a `fill="currentColor"` fallback in the markup — so the
  mark follows `data-bs-theme`. (Before #154 the arms were a frozen `#1B2A4A`, which paints at
  ~1.09:1 — invisible — on a dark navbar.) A caller can replace the whole mark via `logo_mark:`
  (see Props / API).
- **MARKAZ text:** `font-weight: 300`, `letter-spacing: 0.12em`, colour `var(--bs-body-color)`
  (navy in light, near-white in dark)
- **Surfaces:** the top bar is `var(--bs-body-bg)`, the sub-nav is `var(--bs-tertiary-bg)`; both
  carry a bottom border of `var(--bs-border-color)`
- **Active state:** link-colour text `var(--bs-link-color)` (`#2E75B6` light / `#82ACD3` dark,
  AA-safe in both) + 2px `var(--bs-link-color)` bottom border + `font-weight: 600`
- **Inactive state:** muted text `var(--bs-secondary-color)`, `font-weight: 500`
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
| Default | Nav item | Muted text (`var(--bs-secondary-color)`), no underline |
| Hover | Nav item | Link-colour text (`var(--bs-link-color)`) |
| Active | Nav item | Link-colour text + bold (600) + 2px `var(--bs-link-color)` bottom border |
| Active | Sub-nav item | Same as nav item active state |

## Props / API

```ruby
# MpiDesignSystem::Admin::NavBar::Component
class MpiDesignSystem::Admin::NavBar::Component < ViewComponent::Base
  # @param current_section [Symbol] Active top-level section key (e.g. :dashboard, :crm)
  # @param current_subsection [Symbol] Active subsection key (e.g. :contacts, :accounts for CRM)
  # @param user_name [String] Current user name (for avatar)
  # @param search_url [String] Global search action URL (search bar hidden when nil)
  # @param search_placeholder [String] Placeholder text for search input (default: "Search...")
  # @param sections [Array<Hash>] Custom top-level sections (overrides defaults); each hash supports visible: (default true)
  # @param subsections [Hash{Symbol => Array<Hash>}] Custom subsections (overrides defaults); each hash supports visible: (default true)
  # @param environment [Symbol] :development, :staging, :production (env bar shown for dev/staging)
  # @param system_url [String] URL for system admin gear icon (shown when present)
  # @param sign_out_url [String] URL for sign-out action
  # @param sign_out_method [Symbol] HTTP method for sign-out (default: :delete)
  # @param profile_url [String] Optional URL for user profile link
  # @param logo_text [String] Logo text (default: "MARKAZ")
  # @param logo_href [String] Logo link URL (default: first visible section's href or "/")
  # @param logo_mark [String] Custom logo mark markup (trusted SVG/image); default renders the Markaz diamond
end
```

### Subsection visibility

Each subsection hash supports an optional `visible:` key (default `true`), mirroring the
top-level `sections`. A subsection with `visible: false` is filtered out of the sub-nav; when
every subsection of the active section is hidden, the sub-nav bar is not rendered at all.

### Custom logo mark

`logo_mark:` overrides the default Markaz diamond with caller-supplied markup (an SVG or
`<img>`). It accepts **trusted, developer-authored markup only** — a non-`html_safe` string is
escaped and rendered as text, so pass `.html_safe` markup you control, never user input. A blank
value (`nil` or `""`) falls back to the default mark. Supply your own decorative or labeled
accessibility semantics (e.g. `aria-hidden="true"` for a mark paired with the visible logo text).

## Bootstrap Classes

- `navbar` — could be used as base, but preview uses custom flexbox layout
- `nav-link` — individual nav items
- `d-flex`, `align-items-center` — top bar and sub-nav layout
- `border-bottom` — separator between bars
- `position-relative` — search input icon positioning
- Custom `.topbar`, `.subnav`, `.nav-item`, `.subnav-item` classes

## Key Styles

Colours resolve from Bootstrap runtime custom properties (`var(--bs-*)`), so the same rules
paint both colour modes — see `app/assets/stylesheets/mpi_design_system/_nav_bar.scss` (#154).

```css
.mds-navbar  { background: var(--bs-body-bg); border-bottom: 1px solid var(--bs-border-color); height: 52px; }
.mds-subnav  { background: var(--bs-tertiary-bg); border-bottom: 1px solid var(--bs-border-color); height: 42px; }
.mds-navbar__section-link { font-size: 14px; padding: 14px 12px; border-bottom: 2px solid transparent; color: var(--bs-secondary-color); }
.mds-navbar__section-link--active { color: var(--bs-link-color); border-bottom-color: var(--bs-link-color); font-weight: 600; }
.mds-navbar__brand { font-weight: 300; letter-spacing: 0.12em; color: var(--bs-body-color); font-size: 14px; }
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
