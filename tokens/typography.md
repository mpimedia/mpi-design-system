# Typography

Design tokens for MPI typography.

> **Status:** Draft — values to be populated once type scale is confirmed.

## Font Families

| Token | Value | Usage |
|---|---|---|
| `$mpi-font-primary` | TBD | Body text, general UI |
| `$mpi-font-heading` | TBD | Headings (may be same as primary) |
| `$mpi-font-mono` | TBD | Code, data tables, technical content |

## Type Scale

| Token | Size | Weight | Line Height | Usage |
|---|---|---|---|---|
| `$mpi-text-xs` | TBD | 400 | TBD | Fine print, labels |
| `$mpi-text-sm` | TBD | 400 | TBD | Secondary text, captions |
| `$mpi-text-base` | TBD | 400 | TBD | Body text |
| `$mpi-text-lg` | TBD | 400 | TBD | Lead paragraphs |
| `$mpi-text-xl` | TBD | 600 | TBD | Section headers |

## Headings

| Token | Size | Weight | Usage |
|---|---|---|---|
| `$mpi-h1` | TBD | 700 | Page titles |
| `$mpi-h2` | TBD | 700 | Section headings |
| `$mpi-h3` | TBD | 600 | Subsection headings |
| `$mpi-h4` | TBD | 600 | Card titles, group labels |
| `$mpi-h5` | TBD | 600 | Small headings |
| `$mpi-h6` | TBD | 600 | Overlines, labels |

## Bootstrap 5 Mapping

```scss
$font-family-base: $mpi-font-primary;
$headings-font-family: $mpi-font-heading;
$font-family-monospace: $mpi-font-mono;
$font-size-base: $mpi-text-base;
```
