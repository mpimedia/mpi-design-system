# Typography

Design tokens for MPI typography.

> **Status:** Pending — values will be derived from approved designs during Q&A review sessions.

## Confirmed Decisions

These decisions were confirmed in [Issue #5](https://github.com/mpimedia/mpi-design-system/issues/5):

- **Font family:** Bootstrap default system font stack (not DM Sans)
- **Custom CSS:** Convert designs to use Bootstrap standards, only customize when needed

## Font Families

| Token | Value | Usage |
|---|---|---|
| `$mpi-font-primary` | _Bootstrap default_ | Body text, general UI |
| `$mpi-font-heading` | _from designs_ | Headings (may be same as primary) |
| `$mpi-font-mono` | _Bootstrap default_ | Code, data tables, technical content |

## Type Scale

| Token | Size | Weight | Line Height | Usage |
|---|---|---|---|---|
| `$mpi-text-xs` | _from designs_ | _from designs_ | _from designs_ | Fine print, labels |
| `$mpi-text-sm` | _from designs_ | _from designs_ | _from designs_ | Secondary text, captions |
| `$mpi-text-base` | _from designs_ | _from designs_ | _from designs_ | Body text |
| `$mpi-text-lg` | _from designs_ | _from designs_ | _from designs_ | Lead paragraphs |
| `$mpi-text-xl` | _from designs_ | _from designs_ | _from designs_ | Section headers |

## Headings

| Token | Size | Weight | Usage |
|---|---|---|---|
| `$mpi-h1` | _from designs_ | _from designs_ | Page titles |
| `$mpi-h2` | _from designs_ | _from designs_ | Section headings |
| `$mpi-h3` | _from designs_ | _from designs_ | Subsection headings |
| `$mpi-h4` | _from designs_ | _from designs_ | Card titles, group labels |
| `$mpi-h5` | _from designs_ | _from designs_ | Small headings |
| `$mpi-h6` | _from designs_ | _from designs_ | Overlines, labels |

## Bootstrap 5 Mapping

```scss
$font-family-base: $mpi-font-primary;
$headings-font-family: $mpi-font-heading;
$font-family-monospace: $mpi-font-mono;
$font-size-base: $mpi-text-base;
```

## Legacy Reference

These values exist in current apps but may not carry forward:

| App | Override | Notes |
|---|---|---|
| avails_server | `font-family: "Helvetica Neue", Helvetica, Arial, sans-serif` | Admin section only — diverges from Bootstrap default |
| SFA | No font override | Uses Bootstrap default |
| markaz-crm | No font override | Uses Bootstrap default |
| garden | No font override | Uses Bootstrap default |
| harvest | No font override | Uses Bootstrap default |
