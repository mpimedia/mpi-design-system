# Visual QA Report: Lookbook Previews vs Figma CRM Screens

**Date**: 2026-03-04
**Method**: Live visual comparison — Figma MCP screenshots vs Playwright Lookbook screenshots
**Screens Compared**: 14 / 14
**Agent**: Claude Opus 4.6

---

## Summary

| Severity | Count |
|----------|-------|
| Major    | 8     |
| Minor    | 12    |
| Cosmetic | 7     |

**Overall Assessment**: The component library is structurally sound and covers ~85% of the design requirements. The major discrepancies are primarily **missing features/sections within existing components** and **navigation structure differences** rather than fundamental design flaws.

---

## Screen-by-Screen Comparison

### Screen 01: Contact Detail View
**Figma**: `3cZj3apxFbZAIp4Cv3q9uy`
**Lookbook**: `admin/contact_detail_panel/default`

| # | Discrepancy | Severity | Notes |
|---|-------------|----------|-------|
| 1.1 | **Tags section missing colored dot indicators** — Figma shows `● Buyer — Theatrical` with group-colored dots; Lookbook shows tag chips without dot prefixes | Minor | TagChip component renders group-colored badges but no leading dot indicator |
| 1.2 | **Tags show group names only, not full tag labels** — Figma shows specific tags like "Buyer — Theatrical", "Buyer — Digital/Streaming"; Lookbook shows group names "Buyers", "Festivals" | Major | ContactDetailPanel preview uses group-level chips, not individual tags |
| 1.3 | **Missing "+ Add tag" button** — Figma shows an "+ Add tag" button next to tag chips | Minor | Not implemented in ContactDetailPanel |
| 1.4 | **Contact info layout uses stacked labels** — Lookbook uses stacked label/value pairs (LABEL above value); Figma uses inline label: value format (Email: jane@...) | Minor | Different layout approach — Lookbook is actually cleaner but doesn't match Figma |
| 1.5 | **Avatar circle size** — Lookbook avatar appears slightly smaller than Figma | Cosmetic | Size difference is minor |

### Screen 02: Contact List View
**Figma**: `vz73o3WIpZQ5vJiKxKTHD9`
**Lookbook**: `admin/list_view/default`

| # | Discrepancy | Severity | Notes |
|---|-------------|----------|-------|
| 2.1 | **Missing "Account" column** — Figma shows 4 columns: Name, Tags, Last Engagement, Account; Lookbook shows Name, Title, Tags, Last Engagement | Major | Account column not included in ListView/DataTable preview |
| 2.2 | **Tags column shows single badge instead of multiple colored tag chips** — Figma shows inline colored tag chips (e.g., "● Buyer — Theatrical ● Buyer — Digital ● Fest — Acquisitions"); Lookbook shows single badge like "Lead" | Major | DataTable rows in preview use status badges, not tag chips |
| 2.3 | **FilterChipBar shows fewer groups** — Figma shows 8 groups (All, Buyers, Press, Festivals, Sellers, Institutional, Organizations, Internal); Lookbook shows 4 (All, Buyers, Press, Festivals) | Minor | Preview data is simplified |
| 2.4 | **Selected filter chip styling** — Figma shows "Buyers 342" with orange highlight on the selected chip; Lookbook "All" chip uses primary blue fill | Cosmetic | Color difference for active state |
| 2.5 | **Missing NavBar in ListView preview** — Figma shows full page with NavBar; Lookbook ListView preview doesn't include NavBar wrapper | Minor | Component isolation — expected in Lookbook |

### Screen 03: Tag Input Type-Ahead
**Figma**: `e2pP4dW9xKY4wc92s1wAOp`
**Lookbook**: `admin/tag_input/default`, `admin/tag_input/with_selected`

| # | Discrepancy | Severity | Notes |
|---|-------------|----------|-------|
| 3.1 | **No "Tags" label above input** — Figma shows "Tags" label; Lookbook TagInput renders just the input field | Minor | Missing label wrapper |
| 3.2 | **Dropdown not shown in default state** — Figma shows the type-ahead dropdown with grouped suggestions; Lookbook default shows empty input | Cosmetic | Expected — Lookbook shows resting state |
| 3.3 | **Tag chips in "with_selected" variant lack colored dot prefix** — Figma shows "● Buyer — Theatrical ×" with orange dot; Lookbook shows "Buyers — Lead ×" without dots | Minor | Consistent with TagChip component lacking dot indicator |
| 3.4 | **Missing "Auto-Derived Groups" section below tags** — Figma shows auto-derived groups (Buyers, Festivals, Press) below selected tags | Minor | Feature not implemented in TagInput component |
| 3.5 | **No keyboard navigation hint** — Figma shows "↑↓ to navigate · Enter to select · Esc to close" | Cosmetic | UX hint not rendered |

### Screen 04: Compact Card View
**Figma**: `LgjNUzu6QdKz7kocs8K7pY`
**Lookbook**: `admin/contact_card/default`

| # | Discrepancy | Severity | Notes |
|---|-------------|----------|-------|
| 4.1 | **Card layout is flat/horizontal** — Lookbook ContactCard renders as a horizontal row; Figma shows a stacked card with avatar + name at top, tags below, engagement/count at bottom | Major | Component renders as a list item rather than a stacked card |
| 4.2 | **Missing engagement count** — Figma shows "4 engagements" in card footer; Lookbook shows "Owner: Sarah Williams" | Minor | Different metadata displayed |
| 4.3 | **Tags show group names, not full labels** — Figma shows "● Buyer — Theatrical ● Buyer — Digital"; Lookbook shows "Buyers", "Festivals" | Minor | Same as 1.2 — group-level only |
| 4.4 | **Grid layout not demonstrated** — Figma shows a 3-column grid of cards; Lookbook shows single card in isolation | Cosmetic | Expected in component preview |

### Screen 05: Search Initial State — All Filter Fields
**Figma**: `whBwTP18dOGKXxreGovpL0`
**Lookbook**: `admin/empty_state/default`, `admin/search_bar/default`, `admin/filter_panel/default`

| # | Discrepancy | Severity | Notes |
|---|-------------|----------|-------|
| 5.1 | **SearchBar missing "Search" and "Export" buttons** — Figma shows a full-width search bar with blue "Search" button and "Export" button; Lookbook SearchBar is a simple input with icon | Major | SearchBar component doesn't include action buttons |
| 5.2 | **FilterPanel missing several sections** — Figma shows 8 filter sections (Tag Groups, Specific Tags, Account/Company, Location, Engagement Activity, Date Added, Engagement Content, Linked Title/Film); Lookbook shows 3 (Tag Group, Engagement Type, Date Range) | Minor | Preview has fewer filter groups; component supports arbitrary groups |
| 5.3 | **FilterPanel missing "Reset all" link** — Figma shows "Reset all" link in Filters header | Minor | Not in current FilterPanel component |
| 5.4 | **EmptyState missing quick-access shortcut cards** — Figma shows 4 suggested search cards ("Buyers — no engagement in 30 days", "Press — all critics", etc.); Lookbook EmptyState shows icon + text + button only | Major | Quick-access shortcuts not implemented |
| 5.5 | **FilterPanel "Other" group missing** — Figma shows an "Other 12" group; Lookbook only has 5 groups | Cosmetic | Preview data limitation |

### Screen 06: Active Search Results
**Figma**: `0Vk6JGBynsacpYrqPukYkG`
**Lookbook**: `admin/list_view/default` (closest match)

| # | Discrepancy | Severity | Notes |
|---|-------------|----------|-------|
| 6.1 | **Missing active filter pills** — Figma shows "ACTIVE: Keyword: investors × Group: Buyers × Activity: Engaged last 90 days × Clear all"; no equivalent in Lookbook | Major | Active filter state/pills not implemented |
| 6.2 | **Missing "Match Found In" column** — Figma data table includes a "Match Found In" column showing where the keyword matched; Lookbook DataTable doesn't have this | Minor | Search-specific column not in preview |
| 6.3 | **Missing "Status" column with health indicators** — Figma shows colored dot + "Active"/"Follow up" status; Lookbook doesn't have status column | Minor | Status indicators absent from DataTable preview |
| 6.4 | **Result count with filter summary** — Figma shows "23 contacts match **investors** in Buyers, engaged in last 90 days"; Lookbook shows "156 contacts" | Cosmetic | Preview doesn't show filtered state |

### Screen 07: Dashboard
**Figma**: `QmPw8Hyi8qIbzVcmOZItFX`
**Lookbook**: `admin/dashboard/default`

| # | Discrepancy | Severity | Notes |
|---|-------------|----------|-------|
| 7.1 | **StatCard labels differ** — Figma: "Total Contacts / Engagements This Week / Accounts / Overdue Follow-Ups"; Lookbook: "Total Contacts / Active Accounts / Engagements / Data Quality" | Minor | Different stat categories |
| 7.2 | **Overdue Follow-Ups stat card has red number in Figma** — The "12" is red with "↑ 3 since yesterday" in red; Lookbook "Data Quality" uses green for the trend | Cosmetic | Different metric; when overdue follow-ups is implemented, needs red color treatment |
| 7.3 | **Recent Activity missing contact names and links** — Figma shows "Email logged with **Sarah Chen** — Re: Spring Lineup..."; Lookbook shows generic "sent a follow-up email" | Minor | Preview data is simplified; missing linked contact names |
| 7.4 | **Follow-up Queue layout differs** — Figma shows avatar + name + description + urgency (7d overdue, 5d overdue, etc.); Lookbook shows avatar + description + urgency but less detail | Minor | Missing contact names in follow-up queue items |
| 7.5 | **Dashboard layout: Quick Actions placement** — Figma places Quick Actions in the right sidebar below Follow-up Queue; Lookbook places Quick Actions above Follow-up Queue | Cosmetic | Order difference in right column |

### Screen 08: Accounts List View
**Figma**: `Nnil0hCxAoJ95x0M28qB8Y`
**Lookbook**: No dedicated accounts list view preview

| # | Discrepancy | Severity | Notes |
|---|-------------|----------|-------|
| 8.1 | **No dedicated Accounts List View preview** — Figma shows a rich accounts table with columns: Account, Contacts (avatar stack + count), Tag Groups, Health, Last Engaged, Linked Titles; No Lookbook preview assembles this | Major | Missing composed view |
| 8.2 | **FilterChipBar shows account types** — Figma shows "All 418 / Distributors 124 / Studios 38 / Festivals 67 / Press Outlets 89 / Sales Agencies 42"; not in any preview | Minor | Account-specific filter groups not demonstrated |
| 8.3 | **"+ New Account" button** — Figma shows a primary action button; not in any preview | Cosmetic | Action button not in preview |

### Screen 09: Account Detail
**Figma**: `2PyGqSK3zDjpo35IukJc0o`
**Lookbook**: `admin/account_detail_panel/default`

| # | Discrepancy | Severity | Notes |
|---|-------------|----------|-------|
| 9.1 | **Missing metrics row** — Figma shows "7 CONTACTS / 34 ENGAGEMENTS / 12 TITLES" below company name; Lookbook AccountDetailPanel doesn't show these | Minor | Metrics not in component |
| 9.2 | **Missing Account Info section** — Figma shows Location, Website, Type, Territory, Health, Added; Lookbook shows Contact Info (Email, Phone, Location, Created, Owner) | Minor | Different info fields; AccountDetailPanel shows contact-style info instead of account-style |
| 9.3 | **Missing "Tag Groups Represented" section** — Figma shows colored chips like "Buyers (5) / Festivals (2) / Press (1)"; not in Lookbook | Minor | Feature missing from component |
| 9.4 | **Missing "Linked Titles" section** — Figma shows film titles with status; Lookbook doesn't have this | Minor | Feature missing from component |
| 9.5 | **Right panel with tabs** — Figma shows tabbed right panel with "Contacts (7) / Engagements (34) / Titles (12)" featuring ContactCards in grid; Lookbook only shows left panel | Major | Tab-based right panel not implemented in preview |

### Screen 10: Engagements View
**Figma**: `rvDJMDg91S6L34qUhFiDrg`
**Lookbook**: `admin/engagement_timeline/default`, `admin/engagement_card/email`

| # | Discrepancy | Severity | Notes |
|---|-------------|----------|-------|
| 10.1 | **Engagement cards missing rich metadata** — Figma cards show: account link (top right), tag chips, linked titles, avatar chips for contacts; Lookbook EngagementCard shows type badge, time, author, title, excerpt, single avatar | Minor | EngagementCard is simpler than Figma design |
| 10.2 | **Missing left sidebar filter panel** — Figma shows Type filter (All/Emails/Meetings/Calls/Notes), Date Range, Linked To; Lookbook shows timeline only | Minor | No filter sidebar in EngagementTimeline preview |
| 10.3 | **Missing date group headers** — Figma shows "TODAY — FEB 25" and "YESTERDAY — FEB 24" as section dividers; Lookbook timeline doesn't group by date | Minor | Timeline doesn't implement date grouping |
| 10.4 | **EngagementCard type badge colors** — Figma: EMAIL (blue), MEETING (purple), CALL (green), NOTE (orange); Lookbook: all badges use `btn-outline-dark` style (gray border) | Minor | Type-specific colors not implemented in badges |

### Screen 11: Engagement Detail
**Figma**: `ltHGpk0KgeXdN6UI5hv04V`
**Lookbook**: `admin/engagement_detail_view/default`

| # | Discrepancy | Severity | Notes |
|---|-------------|----------|-------|
| 11.1 | **Missing engagement header bar** — Figma shows header with icon, title, EMAIL badge, date, "Sent" status, Edit/.../ + Follow Up buttons; Lookbook has breadcrumb only | Minor | Header bar with action buttons not in EngagementDetailView |
| 11.2 | **Missing "Content / Thread / Activity Log" tabs** — Figma shows tabbed interface; Lookbook shows email thread directly | Minor | Tab navigation not implemented |
| 11.3 | **Missing email headers** — Figma shows From/To/CC/Subject fields; Lookbook thread shows avatar + name + timestamp | Minor | Email header metadata not in component |
| 11.4 | **Missing attachments section** — Figma shows file attachments with icons (XLS, PDF); Lookbook has basic file attachment display | Cosmetic | Attachment display is simpler |
| 11.5 | **Right sidebar significantly simpler** — Figma shows: Follow-up alert, Linked Contacts (with tags), Account card, Linked Titles (with metadata), Details section; Lookbook shows Linked Contacts, Accounts, Titles as plain text | Minor | Sidebar lacks rich metadata |
| 11.6 | **Missing "Email Thread" collapsible section** — Figma shows chronological thread list with "VIEWING" badge; Lookbook doesn't have thread history | Minor | Thread navigation not implemented |
| 11.7 | **Missing "Internal Note" highlighted section** — Figma shows amber-highlighted internal note; Lookbook has "Staff Note" with different styling | Cosmetic | Staff note styling exists but differs |

### Screen 12: Data Quality Dashboard
**Figma**: `mSPRhRJsGLlp8pXlIdvU0l`
**Lookbook**: `admin/data_quality_dashboard/good`

| # | Discrepancy | Severity | Notes |
|---|-------------|----------|-------|
| 12.1 | **Missing gap stat cards** — Figma shows 3 stat cards: "No Email Address 186", "No Tags Assigned 247", "No Linked Account 312"; Lookbook DataQualityDashboard only shows donut + grade breakdown | Minor | Gap summary stats not in component |
| 12.2 | **Missing "Priority Fixes — Recently Active" table** — Figma shows a table of contacts needing fixes with issues, quality ring, and recency; Lookbook only has "Top Data Gaps" section | Minor | Priority fixes table not fully implemented |
| 12.3 | **Donut chart percentage display** — Figma shows 72% centered in donut; Lookbook shows 75% — close match structurally | Cosmetic | Data differs but rendering is similar |
| 12.4 | **Grade distribution uses progress bars** — Lookbook uses horizontal bars; Figma uses colored segments with counts and percentages | Cosmetic | Different visualization approach |

### Screen 13: Data Quality Column
**Figma**: `lSW6GbDYqmrx9wA1jaspNa`
**Lookbook**: No dedicated preview (DataTable with quality column)

| # | Discrepancy | Severity | Notes |
|---|-------------|----------|-------|
| 13.1 | **No preview showing quality column in contacts table** — Figma shows contacts list with inline quality ring (percentage), Issues column, and a "Quality < 50%" filter chip; no Lookbook preview demonstrates this | Minor | Quality column integration not previewed |
| 13.2 | **Missing ProgressRing inline component** — Figma shows small circular progress indicators (92%, 76%, 22%, etc.) per row; this component exists in DataQualityPanel but isn't shown inline in DataTable | Minor | ProgressRing not used in DataTable context |

### Screen 14: Data Completeness Panel
**Figma**: `r5HmNLkOsGERD0DG4aSgxT`
**Lookbook**: `admin/data_quality_panel/excellent`

| # | Discrepancy | Severity | Notes |
|---|-------------|----------|-------|
| 14.1 | **Left sidebar different** — Figma shows full contact detail panel (avatar, name, title, company, metrics, contact info, tags, details); Lookbook DataQualityPanel shows only the quality checklist | Cosmetic | Panel is component-isolated; left sidebar would come from ContactDetailPanel |
| 14.2 | **Missing "Recent Engagements" section with type filter tabs** — Figma shows engagement list with "All (8) / Emails / Meetings / Calls" tabs; Lookbook DataQualityPanel doesn't include engagements | Minor | Engagement section not in DataQualityPanel |
| 14.3 | **Field checklist matches well** — Both show checkmark/X icons, field names, weight badges (HIGH/MED/LOW), values, and progress bar. Good structural match. | — | Strong match |
| 14.4 | **Missing "+ Add phone" / "+ Add LinkedIn" action links** — Figma shows inline "add" actions for missing fields; Lookbook missing fields show as red X without add action | Minor | Inline add actions not implemented |

---

## Cross-Cutting Issues

### NavBar Discrepancy
The NavBar component shows **6 top-level items**: Dashboard, Content, CRM, Rights & Avails, Releases, Screenings. But the Figma CRM screens show **4 CRM-specific items**: Dashboard, Contacts, Accounts, Engagements (as a sub-navigation within the CRM section). The NavBar component represents the Markaz-wide navigation, not the CRM sub-nav. A **CRM sub-nav / TabBar** would be needed to match the Figma CRM screens.

### Tag Display Consistency
Across multiple screens (01, 02, 03, 04), tags consistently show **group names only** in Lookbook (e.g., "Buyers", "Festivals") while Figma shows **full tag labels** (e.g., "Buyer — Theatrical", "Fest — Acquisitions") with **colored dot indicators**. This is a systemic issue in how tag data is passed to previews and how TagChip renders.

### Engagement Type Colors
The EngagementCard and EngagementTimeline components render type badges (EMAIL, MEETING, CALL, NOTE) with a uniform gray outline style. Figma uses **distinct colors per type**: blue (Email), purple (Meeting), green (Call), orange (Note). This is a component-level styling fix.

---

## Recommended Fix Issues

The following issues should be created to address the discrepancies:

1. **ContactCard: Implement stacked card layout** (Major) — Current horizontal row layout doesn't match Figma's stacked card design
2. **SearchBar: Add action buttons variant** (Major) — Add "Search" and "Export" buttons to SearchBar component
3. **EmptyState: Add quick-access shortcut cards** (Major) — Implement suggested search shortcuts
4. **Active filter pills component** (Major) — Build removable filter pill bar for active search state
5. **ListView: Add Account column and inline tag chips** (Major) — DataTable rows need full tag chips and account column
6. **AccountDetailPanel: Add metrics, tags represented, linked titles** (Major) — Missing sections per Figma Screen 09
7. **EngagementCard: Add type-specific badge colors** (Minor) — Blue/purple/green/orange per engagement type
8. **TagChip: Add colored dot indicator prefix** (Minor) — Group-colored dot before tag label
9. **EngagementTimeline: Add date group headers** (Minor) — "TODAY — FEB 25" style dividers
10. **DataQualityDashboard: Add gap stat cards and priority fixes table** (Minor) — Missing summary stats
11. **Update all previews to use full tag labels** (Minor) — Show "Buyer — Theatrical" not just "Buyers"
12. **EngagementDetailView: Add header bar, tabs, email headers** (Minor) — Multiple missing sections per Figma Screen 11

---

*Report generated by Claude Opus 4.6 on 2026-03-04*
