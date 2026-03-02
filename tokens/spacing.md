# Spacing

Design tokens for consistent spacing across MPI applications.

> **Status:** Baseline — using Bootstrap 5 defaults. Custom overrides will be derived from approved designs if needed.

## Spacing Scale

MPI uses Bootstrap 5's spacing scale as the foundation. Custom overrides are documented here only if the designs require them.

| Token | Bootstrap Class | Default Value | Usage |
|---|---|---|---|
| `$spacer-0` | `.p-0`, `.m-0` | 0 | No spacing |
| `$spacer-1` | `.p-1`, `.m-1` | 0.25rem (4px) | Tight spacing |
| `$spacer-2` | `.p-2`, `.m-2` | 0.5rem (8px) | Compact spacing |
| `$spacer-3` | `.p-3`, `.m-3` | 1rem (16px) | Default spacing |
| `$spacer-4` | `.p-4`, `.m-4` | 1.5rem (24px) | Comfortable spacing |
| `$spacer-5` | `.p-5`, `.m-5` | 3rem (48px) | Generous spacing |

## Component Spacing Guidelines

| Context | Recommended Spacing |
|---|---|
| Between form fields | `$spacer-3` (16px) |
| Card internal padding | `$spacer-3` to `$spacer-4` |
| Section gaps | `$spacer-4` to `$spacer-5` |
| Inline element gaps | `$spacer-1` to `$spacer-2` |
| Button padding | Bootstrap defaults (`btn` class) |

## Design-Driven Overrides

_To be populated after Q&A review of approved designs. Only add overrides here if Bootstrap defaults are insufficient._

## Bootstrap 5 Mapping

```scss
// Override Bootstrap's spacer only if designs require it
$spacer: 1rem;
$spacers: (
  0: 0,
  1: $spacer * .25,
  2: $spacer * .5,
  3: $spacer,
  4: $spacer * 1.5,
  5: $spacer * 3
);
```
