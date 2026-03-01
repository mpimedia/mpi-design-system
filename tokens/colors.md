# Colors

Design tokens for the MPI color palette.

> **Status:** Draft — values to be populated once brand colors are confirmed.

## Brand Colors

| Token | Value | Usage |
|---|---|---|
| `$mpi-primary` | TBD | Primary actions, key UI elements |
| `$mpi-secondary` | TBD | Secondary actions, supporting elements |
| `$mpi-accent` | TBD | Highlights, active states |

## Semantic Colors

| Token | Value | Usage |
|---|---|---|
| `$mpi-success` | TBD | Positive actions, confirmations |
| `$mpi-warning` | TBD | Caution states, pending actions |
| `$mpi-danger` | TBD | Destructive actions, errors |
| `$mpi-info` | TBD | Informational messages |

## Neutral Colors

| Token | Value | Usage |
|---|---|---|
| `$mpi-text` | TBD | Primary text |
| `$mpi-text-muted` | TBD | Secondary text, captions |
| `$mpi-border` | TBD | Default borders |
| `$mpi-background` | TBD | Page background |
| `$mpi-surface` | TBD | Card/panel backgrounds |

## Bootstrap 5 Mapping

These tokens map to Bootstrap's color system via SCSS variable overrides:

```scss
// In your app's Bootstrap override file
$primary: $mpi-primary;
$secondary: $mpi-secondary;
$success: $mpi-success;
$warning: $mpi-warning;
$danger: $mpi-danger;
$info: $mpi-info;
```

## App-Specific Overrides

Individual apps may extend the palette for app-specific needs, but should never redefine the core tokens above. Document app-specific colors in the app's own codebase.
