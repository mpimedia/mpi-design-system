# Bootstrap 5 Overrides

MPI-specific customizations to Bootstrap 5 defaults.

> **Status:** In progress — core color overrides confirmed (2026-03-02). Component overrides being finalized.

## Philosophy

Start from Bootstrap 5 defaults. Only override when the approved designs explicitly require it. Every override must trace back to a design decision, not a developer preference.

## How Overrides Work

Each MPI Rails app uses Bootstrap 5 via the `bootstrap` gem. Customizations are applied by overriding Bootstrap SCSS variables **before** importing Bootstrap:

```scss
// app/assets/stylesheets/application.scss

// 1. MPI overrides (from design system tokens)
@use "mpi_overrides";

// 2. Bootstrap
@use "bootstrap/scss/bootstrap";

// 3. App-specific styles
@use "custom";
```

## Shared Override File

The goal is a single `_mpi_overrides.scss` partial maintained in this repo and distributed to each app via a shared gem. This file will be generated from the token values once designs are approved.

## Override Categories

### Colors

See [colors.md](colors.md) for full palette. Confirmed overrides:

```scss
$primary: #2E75B6;
$success: #22A06B;
$warning: #D4772C;
// $danger: #DC3545;  — Bootstrap default, no override needed
$info: #2E75B6;
```

### Typography

See [typography.md](typography.md). Overrides to be determined from designs:

```scss
// $font-family-base: $mpi-font-primary;
```

### Component Overrides

Confirmed from Q&A Session 001:

```scss
// Badges — pill shape across the board
$badge-border-radius: 999px;
```

Remaining questions from legacy apps (still need design confirmation):

| Question | Legacy Context | Status |
|---|---|---|
| Button border-radius | SFA uses `3.125rem` (pill buttons). Other apps use Bootstrap default. | Pending — badge is pill, button TBD |
| Button padding | SFA has custom padding values. Other apps use Bootstrap default. | Pending |
| Link color | avails_server uses `#0a3d7e`. Others use Bootstrap default. | **Resolved** — use `$mpi-primary` (`#2E75B6`) |
| Card border-radius | Unknown — pending designs. | Pending |
| Navbar style | V2 (white topbar) confirmed as canonical direction in Issue #5. | **Confirmed** |

## Legacy Reference

Current override files in each app (for migration planning):

| App | File | Scope |
|---|---|---|
| SFA | `app/assets/stylesheets/overrides/_variables.scss` | Extensive: 13 custom colors, pill buttons, accordion, carousel, form overrides |
| SFA | `app/assets/stylesheets/overrides/_theme_colors.scss` | Merges 11 custom colors into Bootstrap theme map |
| avails_server | `app/assets/stylesheets/customizations/admin.scss` | Moderate: link color, heading sizes, font family, table styling, accordion levels |
| markaz-crm | `app/assets/stylesheets/admin.scss` | Minimal: one custom background color, readonly input styling, table headers, mobile responsive |
| garden | `app/assets/stylesheets/admin.scss` | Minimal (similar to markaz-crm) |
| harvest | `app/assets/stylesheets/admin.scss` | Minimal (similar to markaz-crm) |
