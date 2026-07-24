# AvatarCircle

**Category:** Element
**Issue:** #11
**Status:** Approved

## Description

Circular avatar displaying a contact's initials on a deterministic background color. Used in contact lists, table rows, detail headers, and avatar stacks throughout the CRM and other MPI apps.

## Design Decisions

- **Color assignment:** Deterministic — derived from the contact's full name using a hash function. The same name always produces the same color, no manual assignment or database storage needed
- **Palette:** Draws from a fixed set of colors including MPI primary, tag group primaries, and brand colors
- **Initials:** First letter of first name + first letter of last name (uppercase)
- **Placeholder:** When no name is available, show `bi-person-fill` icon on gray (`#6C757D`) background
- **Color is a runtime token with a fallback (#169):** the component emits
  `background-color: var(--mds-avatar-<index>, <hex>); color: var(--mds-avatar-<index>-fg, <hex>)`.
  The optional `_avatar.scss` partial defines those custom properties in a light `:root`
  block and a `[data-bs-theme="dark"]` override, so avatars are **theme-adaptive** and
  **re-brandable**. Without the partial, the inline hex fallback paints today's palette —
  so upgrading is non-breaking. Re-brand by overriding the `--mds-avatar-N` /
  `--mds-avatar-N-fg` **pair** in your own CSS (they must be changed together; the engine
  cannot re-derive a foreground for a value you override at runtime)
- **Text color: Derived per background, not fixed.** The initials take whichever of `#000` /
  `#fff` clears WCAG AA against that avatar's background. In light mode the fallback is
  derived at render time by `MpiDesignSystem::ColorContrast` (the Ruby counterpart of
  Bootstrap's `color-contrast()`); the token foregrounds (`fg` / `fg-dark`) are declared in
  the `$mpi-avatar-palette` source map and **verified at build time** against Bootstrap's own
  `color-contrast()` for **both** modes by `bin/verify-contrast-oracle`. Do not hardcode a
  single foreground here — the palette spans too wide a luminance range for one to be
  accessible (see the tables below)

### Derived foreground per palette color — light mode (the fallback)

This catalog previously claimed white text was accessible on every palette color. It was not: **7 of the 10 failed WCAG AA**, some badly. Issue #130 replaced the pinned foreground with a derived one; #169 keeps that derived foreground as the light-mode fallback and adds the adaptive tokens.

| Background | Token | White | Black | Derived |
|---|---|---:|---:|---|
| `#2E75B6` | `$mpi-primary` | **4.84** ✅ | 4.34 | `#fff` |
| `#8B5CF6` | `$mpi-tag-sellers` | 4.23 ❌ | **4.96** | `#000` |
| `#E8733A` | `$mpi-tag-buyers` | 3.02 ❌ | **6.94** | `#000` |
| `#2DA67E` | `$mpi-tag-press` | 3.06 ❌ | **6.87** | `#000` |
| `#D97706` | `$mpi-tag-institutional` | 3.19 ❌ | **6.59** | `#000` |
| `#6366F1` | `$mpi-tag-organizations` | 4.47 ❌ | **4.70** | `#000` |
| `#DC3545` | Bootstrap `$danger` | **4.53** ✅ | 4.64 | `#fff` |
| `#4EA8DE` | `$mpi-brand-accent` | 2.63 ❌ | **7.98** | `#000` |
| `#22A06B` | `$mpi-success` | 3.33 ❌ | **6.31** | `#000` |
| `#64748B` | `$mpi-tag-internal` | **4.76** ✅ | 4.41 | `#fff` |
| `#6C757D` (placeholder) | `$mpi-text-muted` | **4.69** ✅ | 4.48 | `#fff` |

Following Bootstrap, the light foreground is preferred whenever it clears 4.5:1 — which is why `#DC3545` keeps white at 4.53 rather than taking black's marginally higher 4.64.

### Dark-mode palette (#169)

The engine's **first hand-authored dark palette**. Each name keeps its hue but takes a
softened tone tuned for the dark surface (preserve hue, reduce saturation ~20%, lift
lightness toward the mid), with a foreground re-derived for that dark tone. Every pairing
clears WCAG AA; six of the eleven foregrounds flip relative to light mode, which is why the
`--mds-avatar-N-fg` tokens are paired per mode. `bin/verify-contrast-oracle` proves each
declared foreground equals Bootstrap's `color-contrast()` of its dark background.

| Index | Dark background | Derived foreground |
|---|---|---|
| 0 | `#4280B9` | `#000` |
| 1 | `#8459E4` | `#fff` |
| 2 | `#D6784A` | `#000` |
| 3 | `#41B08B` | `#000` |
| 4 | `#DA831E` | `#000` |
| 5 | `#5F62DF` | `#fff` |
| 6 | `#CC4A56` | `#000` |
| 7 | `#58A2CE` | `#000` |
| 8 | `#37AF7D` | `#000` |
| 9 | `#707E91` | `#000` |
| placeholder | `#787F86` | `#000` |
| overflow (+N) | `#707E91` | `#000` |

## Variants

| Variant | Description |
|---|---|
| **Default** | Single avatar circle with initials |
| **Placeholder** | Generic person icon when name is missing |
| **Avatar Stack** | Overlapping group with "+N" overflow indicator |

## Sizes

| Size | Dimensions | Font Size | Use Case |
|---|---|---|---|
| Small (`sm`) | 28×28px | 11px | Compact table rows, inline references |
| Default (`md`) | 40×40px | 14px | Standard list rows, cards |
| Large (`lg`) | 56×56px | 20px | Detail page headers |
| XL (`xl`) | 80×80px | 28px | Profile pages, modal headers |

## Avatar Stack

- Avatars overlap with `margin-left: -8px` (first child has no negative margin)
- The overflow "+N" chip carries a `2px solid var(--bs-body-bg)` border for visual separation, so the ring tracks the surface in either colour mode. (The individual avatars do not — this doc previously claimed they did.)
- Overflow shows "+N" in a gray (`#64748B`) circle with smaller font size (11px). Since #169 the chip paints the shared `--mds-avatar-overflow` / `--mds-avatar-overflow-fg` tokens (fallback `#64748B` / derived `#fff`, 4.76:1), so it re-brands and adapts to dark mode with the rest of the palette
- Stack is read left-to-right; earlier avatars render on top

## States

| State | Description |
|---|---|
| Default | Initials on deterministic background color |
| Placeholder | `bi-person-fill` icon on `#6C757D` background |

## Props / API

```ruby
# MpiDesignSystem::Admin::AvatarCircle::Component
class MpiDesignSystem::Admin::AvatarCircle::Component < ViewComponent::Base
  # @param name [String] Contact's full name (used for initials + color hash)
  # @param size [Symbol] :sm, :md (default), :lg, :xl
  # @param href [String] Optional link URL
  # @param variant [Symbol] :default or :nav (nav-specific compact styling)
end

# MpiDesignSystem::Admin::AvatarStack::Component
class MpiDesignSystem::Admin::AvatarStack::Component < ViewComponent::Base
  # @param names [Array<String>] List of contact names
  # @param max [Integer] Maximum visible avatars before "+N" (default: 4)
  # @param size [Symbol] :sm, :md (default)
end
```

## Bootstrap Classes

- Custom CSS required (no Bootstrap avatar component); colour ships as the optional `_avatar.scss` custom-property partial
- `d-inline-flex`, `align-items-center`, `justify-content-center` — centering
- `rounded-circle` — could replace custom `border-radius: 50%`
- Font weight: `fw-semibold` (600)

## Implementation Notes

```ruby
# Deterministic color INDEX from the name hash; the colour itself is a runtime token.
AVATAR_COLORS = %w[#2E75B6 #8B5CF6 #E8733A #2DA67E #D97706 #6366F1 #DC3545 #4EA8DE #22A06B #64748B].freeze

def color_index(name)
  name.to_s.bytes.sum % AVATAR_COLORS.length
end

# Emitted inline: the runtime token with the palette hex as a non-breaking fallback (#169).
# The fallback foreground is still DERIVED, never pinned (#130).
def background_value(name)
  "var(--mds-avatar-#{color_index(name)}, #{AVATAR_COLORS[color_index(name)]})"
end

def foreground_value(name)
  fallback = MpiDesignSystem::ColorContrast.accessible_foreground(AVATAR_COLORS[color_index(name)])
  "var(--mds-avatar-#{color_index(name)}-fg, #{fallback})"
end

def initials(name)
  parts = name.to_s.strip.split
  return "?" if parts.empty?
  "#{parts.first[0]}#{parts.last[0]}".upcase
end
```

## Accessibility

- The foreground is derived per background — at render time for the light fallback, and as an oracle-verified declared token for both colour modes — so every avatar meets WCAG AA 4.5:1 regardless of which palette color a name hashes to, in light **and** dark mode. The worst resulting pairing is 4.53:1
- Never pin a single foreground here. `spec/fixtures/scss/avatar_contrast_oracle.scss` compiles Bootstrap's own `color-contrast()` over the palette in both modes and `bin/verify-contrast-oracle` fails CI if a declared foreground and Bootstrap ever disagree; `bin/verify-avatar-adaptive` proves `_avatar.scss` emits every role in both mode blocks; and `spec/features/contrast_spec.rb` measures the painted colour per mode in a real browser
- Include `aria-label` with the full contact name (e.g., `aria-label="John Smith"`)
- Avatar stacks should include `aria-label` describing the group (e.g., "4 contacts, plus 3 more")
- Decorative avatars next to visible name text can use `aria-hidden="true"`

## Usage Guidelines

- **Use** in contact list rows, table cells, card headers, and anywhere a contact is referenced
- **Use** avatar stacks for showing multiple contacts (e.g., engagement participants)
- **Do not** allow manual color assignment — always use the deterministic hash
- **Do not** pin a fixed text color. It is derived from the background (the token foregrounds are oracle-verified, the fallback is render-time derived); hardcoding it is the defect #130 fixed
- **Re-brand** by overriding a `--mds-avatar-N` / `--mds-avatar-N-fg` pair together, never the background alone
- **Do not** use avatars without a nearby name label (screen readers need context)
- The XL size is reserved for primary profile views — do not use in lists or tables
