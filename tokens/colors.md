# Colors

Design tokens for the MPI color palette.

> **Status:** Pending — values will be derived from approved designs during Q&A review sessions.

## How This File Gets Populated

1. Badie provides new designs (Figma, HTML artifacts, screenshots)
2. AC + HC conduct a Q&A session to break down colors used in the designs
3. Values are recorded here as the canonical palette
4. Apps adopt these values via `_mpi_overrides.scss`

## Brand Colors

| Token | Value | Usage |
|---|---|---|
| `$mpi-primary` | _from designs_ | Primary actions, key UI elements |
| `$mpi-secondary` | _from designs_ | Secondary actions, supporting elements |
| `$mpi-accent` | _from designs_ | Highlights, active states |

## Semantic Colors

| Token | Value | Usage |
|---|---|---|
| `$mpi-success` | _from designs_ | Positive actions, confirmations |
| `$mpi-warning` | _from designs_ | Caution states, pending actions |
| `$mpi-danger` | _from designs_ | Destructive actions, errors |
| `$mpi-info` | _from designs_ | Informational messages |

## Neutral Colors

| Token | Value | Usage |
|---|---|---|
| `$mpi-text` | _from designs_ | Primary text |
| `$mpi-text-muted` | _from designs_ | Secondary text, captions |
| `$mpi-border` | _from designs_ | Default borders |
| `$mpi-background` | _from designs_ | Page background |
| `$mpi-surface` | _from designs_ | Card/panel backgrounds |

## Bootstrap 5 Mapping

These tokens map to Bootstrap's color system via SCSS variable overrides:

```scss
// In each app's Bootstrap override file
$primary: $mpi-primary;
$secondary: $mpi-secondary;
$success: $mpi-success;
$warning: $mpi-warning;
$danger: $mpi-danger;
$info: $mpi-info;
```

## App-Specific Overrides

Individual apps may extend the palette for app-specific needs, but should never redefine the core tokens above. Document app-specific colors in the app's own codebase.

## Legacy Reference

These values exist in current apps but may not carry forward. Included for migration context only:

| App | Variable | Value | Notes |
|---|---|---|---|
| SFA | `$primary-blue` | `#1C75BC` | Currently used as Bootstrap `$primary` |
| SFA | `$dark-blue` | `#00447A` | |
| SFA | `$turqoise` | `#00776d` | |
| SFA | `$gold` | `#afa54b` | |
| SFA | `$purple` | `#612574` | |
| SFA | `$faint-gray` | `#f7f7f7` | |
| avails_server | `$link-color` | `#0a3d7e` | |
| markaz-crm | `.bg-custom-light-gray` | `#c2c2c2` | |
