# Cross-App Component Audit

> **Date:** 2026-03-02
> **Purpose:** Inventory of existing UI components across MPI apps. Used for migration planning, not as the basis for the design system.

## Component Counts

| Repo | ViewComponents | Stimulus Controllers | Custom SCSS |
|---|---|---|---|
| markaz-crm | 38 | 0 | Minimal |
| avails_server | 24 | 45 | Moderate |
| wpa_film_library (SFA) | 20 | 29 | Heavy (28+ files) |
| garden | 31 | 0 | Minimal |
| harvest | 31 | 0 | Minimal |

## Naming Conventions (Current State)

| Pattern | Repos |
|---|---|
| `Admin::Name::Component` (folder-based) | markaz-crm, garden, harvest |
| Flat (no namespace) | avails_server |
| `Admin::NameComponent` (class-based) | wpa_film_library |

**Target:** All apps will adopt `Admin::Name::Component` (folder-based) via shared gem.

## Shared Admin Components

These 28 components exist in markaz-crm, garden, and harvest with identical implementations (same file SHAs). avails_server and SFA have equivalents with different names.

| Component | markaz-crm | avails_server | SFA | garden | harvest |
|---|---|---|---|---|---|
| ActionButton | `Admin::ActionButton` | `ActionButton` | — | `Admin::ActionButton` | `Admin::ActionButton` |
| ArchivedBadge | `Admin::ArchivedBadge` | `ArchivedFlag` | — | `Admin::ArchivedBadge` | `Admin::ArchivedBadge` |
| BatchActionButton | `Admin::BatchActionButton` | — | `Admin::BatchActionButtonComponent` | `Admin::BatchActionButton` | `Admin::BatchActionButton` |
| BatchActionModalButton | `Admin::BatchActionModalButton` | — | `Admin::BatchActionModalButtonComponent` | `Admin::BatchActionModalButton` | `Admin::BatchActionModalButton` |
| Brand | `Admin::Brand` | `Brand` | — | `Admin::Brand` | `Admin::Brand` |
| DashboardCard | `Admin::DashboardCard` | — | `Admin::DashboardCardComponent` | `Admin::DashboardCard` | `Admin::DashboardCard` |
| DashboardCardLink | `Admin::DashboardCardLink` | — | — | `Admin::DashboardCardLink` | `Admin::DashboardCardLink` |
| DashboardContainer | `Admin::DashboardContainer` | — | — | `Admin::DashboardContainer` | `Admin::DashboardContainer` |
| DashboardHeader | `Admin::DashboardHeader` | — | — | `Admin::DashboardHeader` | `Admin::DashboardHeader` |
| DashboardHeaderLink | `Admin::DashboardHeaderLink` | — | — | `Admin::DashboardHeaderLink` | `Admin::DashboardHeaderLink` |
| FilterCard | `Admin::FilterCard` | — | `Admin::FilterCardComponent` | `Admin::FilterCard` | `Admin::FilterCard` |
| FormButton | `Admin::FormButton` | — | — | `Admin::FormButton` | `Admin::FormButton` |
| HeaderForEdit | `Admin::HeaderForEdit` | `HeaderForEdit` | `Admin::HeaderComponent` | `Admin::HeaderForEdit` | `Admin::HeaderForEdit` |
| HeaderForIndex | `Admin::HeaderForIndex` | `HeaderForIndex` | `Admin::HeaderComponent` | `Admin::HeaderForIndex` | `Admin::HeaderForIndex` |
| HeaderForNew | `Admin::HeaderForNew` | `HeaderForNew` | `Admin::HeaderComponent` | `Admin::HeaderForNew` | `Admin::HeaderForNew` |
| HeaderForShow | `Admin::HeaderForShow` | `HeaderForShow` | `Admin::HeaderComponent` | `Admin::HeaderForShow` | `Admin::HeaderForShow` |
| HeaderForUpload | `Admin::HeaderForUpload` | `HeaderForUpload` | — | `Admin::HeaderForUpload` | `Admin::HeaderForUpload` |
| IndexPager | `Admin::IndexPager` | `IndexPager` | — | `Admin::IndexPager` | `Admin::IndexPager` |
| InterfaceNotification | `Admin::InterfaceNotification` | `InterfaceNotification` | — | `Admin::InterfaceNotification` | `Admin::InterfaceNotification` |
| LinkButton | `Admin::LinkButton` | — | — | `Admin::LinkButton` | `Admin::LinkButton` |
| NavBar | `Admin::NavBar` | `NavBar` | `Admin::NavBarComponent` | `Admin::NavBar` | `Admin::NavBar` |
| NavDropdownItem | `Admin::NavDropdownItem` | `NavDropdownItem` | `Admin::NavDropdownItemComponent` | `Admin::NavDropdownItem` | `Admin::NavDropdownItem` |
| NavItem | `Admin::NavItem` | `NavItem` | `Admin::NavItemComponent` | `Admin::NavItem` | `Admin::NavItem` |
| PageContainer | `Admin::PageContainer` | `PageWrapper` | `Admin::ContainerComponent` | `Admin::PageContainer` | `Admin::PageContainer` |
| TableForAssociations | `Admin::TableForAssociations` | (shared partials) | — | `Admin::TableForAssociations` | `Admin::TableForAssociations` |
| TableForIndex | `Admin::TableForIndex` | (shared partials) | `Admin::TableComponent` | `Admin::TableForIndex` | `Admin::TableForIndex` |
| TableForIndexColumn | `Admin::TableForIndexColumn` | — | — | `Admin::TableForIndexColumn` | `Admin::TableForIndexColumn` |
| TableForShow | `Admin::TableForShow` | `ShowTable` | `Admin::TwoColumnTableComponent` | `Admin::TableForShow` | `Admin::TableForShow` |
| TableForShowRow | `Admin::TableForShowRow` | — | — | `Admin::TableForShowRow` | `Admin::TableForShowRow` |
| UserLogin | `Admin::UserLogin` | `UserLogin` | — | `Admin::UserLogin` | `Admin::UserLogin` |

## App-Specific Components

| App | Component | Purpose |
|---|---|---|
| markaz-crm | `Admin::DashboardActiveEngagements` | CRM active engagements widget |
| markaz-crm | `Admin::DashboardFollowUps` | CRM follow-up reminders widget |
| markaz-crm | `Admin::DashboardQuickActions` | CRM quick action buttons |
| markaz-crm | `Admin::DashboardQuickStats` | CRM statistics widget |
| markaz-crm | `Admin::DashboardRecentlyAdded` | CRM recent additions widget |
| markaz-crm | `Admin::SavedFilterControls` | Saved filter management |
| markaz-crm | `Favicon` | Favicon meta tags |
| avails_server | `BooleanFlag` | Boolean status indicator |
| avails_server | `CamaFlag` | CAMA status flag |
| avails_server | `ExpiredFlag` | Expired status flag |
| avails_server | `LabelFlag` | Label/tag flag |
| avails_server | `PublicBrand` | Public-facing branding |
| avails_server | `ScreenerRequestFormLink` | Screener request link |
| avails_server | `AssociationsTable` | Associated records table |
| SFA | `Clip::CardComponent` | Video clip card |
| SFA | `Clip::DetailsComponent` | Clip details panel |
| SFA | `Clipbin::CardComponent` | Clipbin collection card |
| SFA | `Exhibit::CoverComponent` | Exhibit cover display |
| SFA | `Exhibit::PageHeaderComponent` | Exhibit page header |
| SFA | `HeroImageComponent` | Hero image banner |
| SFA | `WelcomeHeaderComponent` | Welcome/landing header |
| SFA | `Accordion::ItemComponent` | Accordion panel item |
| garden | `Admin::PreviewBanner` | Content preview banner |
| harvest | `StripeHeadTag` | Stripe payment meta tag |
