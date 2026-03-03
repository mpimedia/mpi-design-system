# Colors

Design tokens for the MPI color palette.

> **Status:** Confirmed — values finalized by Badie (2026-03-02, Q&A Session 001).

## Brand Colors

| Token | Value | Usage |
|---|---|---|
| `$mpi-primary` | `#2E75B6` | Primary actions, buttons, links, active nav states |
| `$mpi-brand-navy` | `#1B2A4A` | Logo dark backgrounds, headings, body text |
| `$mpi-brand-accent` | `#4EA8DE` | Nexus diamond, brand accent highlights |

## Semantic Colors

| Token | Value | Usage |
|---|---|---|
| `$mpi-success` | `#22A06B` | Positive actions, confirmations (confirmed Issue #5) |
| `$mpi-warning` | `#D4772C` | Caution states, pending actions (confirmed Issue #5) |
| `$mpi-danger` | `#DC3545` | Destructive actions, errors (Bootstrap default) |
| `$mpi-info` | `#2E75B6` | Informational messages (same as primary) |

## Neutral Colors

| Token | Value | Usage |
|---|---|---|
| `$mpi-text` | `#1B2A4A` | Primary text (brand navy) |
| `$mpi-text-muted` | `#6C757D` | Secondary text, captions (Bootstrap default) |
| `$mpi-border` | `#DEE2E6` | Default borders (Bootstrap default) |
| `$mpi-background` | `#F5F7FA` | Page background |
| `$mpi-surface` | `#FFFFFF` | Card/panel backgrounds |

## Tag Group Colors (CRM)

Each tag group has a primary color for text/icons and a light background for chips.

| Group | Primary | Background | Usage |
|---|---|---|---|
| Buyers | `#E8733A` | `#FEF3EC` | Buyer contacts and accounts |
| Press | `#2DA67E` | `#ECF8F4` | Press/media contacts |
| Festivals | `#2E75B6` | `#EBF3FB` | Festival contacts |
| Sellers | `#8B5CF6` | `#F3EFFE` | Seller contacts |
| Institutional | `#D97706` | `#FEF9EC` | Institutional contacts |
| Organizations | `#6366F1` | `#EEEFFE` | Organization contacts |
| Internal | `#64748B` | `#F1F5F9` | Internal contacts |

## Engagement Type Colors (CRM)

| Type | Color | Usage |
|---|---|---|
| Email | `#2E75B6` | Email engagement icons and accents |
| Meeting | `#8B5CF6` | Meeting engagement icons and accents |
| Call | `#16A34A` | Call engagement icons and accents |
| Note | `#E8913A` | Note engagement icons and accents |

## Bootstrap 5 Mapping

These tokens map to Bootstrap's color system via SCSS variable overrides:

```scss
// In _mpi_overrides.scss
$primary: #2E75B6;
$success: #22A06B;
$warning: #D4772C;
$danger: #DC3545;  // Bootstrap default, no override needed
$info: #2E75B6;
```

## App-Specific Overrides

Individual apps may extend the palette for app-specific needs, but should never redefine the core tokens above. Document app-specific colors in the app's own codebase.

## Legacy Reference

These values exist in current apps but are being replaced by the tokens above:

| App | Variable | Value | Notes |
|---|---|---|---|
| SFA | `$primary-blue` | `#1C75BC` | Replaced by `$mpi-primary` (`#2E75B6`) |
| SFA | `$dark-blue` | `#00447A` | Replaced by `$mpi-brand-navy` (`#1B2A4A`) |
| SFA | `$turqoise` | `#00776d` | Deprecated |
| SFA | `$gold` | `#afa54b` | Deprecated |
| SFA | `$purple` | `#612574` | Deprecated |
| SFA | `$faint-gray` | `#f7f7f7` | Replaced by `$mpi-background` (`#F5F7FA`) |
| avails_server | `$link-color` | `#0a3d7e` | Replaced by `$mpi-primary` (`#2E75B6`) |
| markaz-crm | `.bg-custom-light-gray` | `#c2c2c2` | Deprecated |
