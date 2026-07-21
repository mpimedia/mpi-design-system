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
- **Text color:** **Derived per background, not fixed.** The initials use whichever of `#000` / `#fff` clears WCAG AA against that avatar's background, computed by `MpiDesignSystem::ColorContrast.accessible_foreground` (the Ruby counterpart of Bootstrap's `color-contrast()`). Do not hardcode a foreground here — the palette spans too wide a luminance range for any single one to be accessible (see the table below)

### Derived foreground per palette color

This catalog previously claimed white text was accessible on every palette color. It was not: **7 of the 10 failed WCAG AA**, some badly. Issue #130 replaced the pinned foreground with a derived one.

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
- The overflow "+N" chip carries a `2px solid #fff` border for visual separation. (The individual avatars do not — this doc previously claimed they did.)
- Overflow shows "+N" in a gray (`#64748B`) circle with smaller font size (11px), foreground derived the same way as the avatars (resolves to `#fff`, 4.76:1)
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

- Custom CSS required (no Bootstrap avatar component)
- `d-inline-flex`, `align-items-center`, `justify-content-center` — centering
- `rounded-circle` — could replace custom `border-radius: 50%`
- Font weight: `fw-semibold` (600)

## Implementation Notes

```ruby
# Deterministic color from name hash
AVATAR_COLORS = %w[#2E75B6 #8B5CF6 #E8733A #2DA67E #D97706 #6366F1 #DC3545 #4EA8DE #22A06B #64748B].freeze

def avatar_color(name)
  AVATAR_COLORS[name.to_s.bytes.sum % AVATAR_COLORS.length]
end

# Foreground is derived, never pinned (#130)
def avatar_foreground(name)
  MpiDesignSystem::ColorContrast.accessible_foreground(avatar_color(name))
end

def initials(name)
  parts = name.to_s.strip.split
  return "?" if parts.empty?
  "#{parts.first[0]}#{parts.last[0]}".upcase
end
```

## Accessibility

- The foreground is derived per background, so every avatar meets WCAG AA 4.5:1 regardless of which palette color a name hashes to. The worst resulting pairing is 4.53:1
- Never reintroduce a fixed `color:` here. `spec/fixtures/scss/avatar_contrast_oracle.scss` compiles Bootstrap's own `color-contrast()` over the palette and `bin/verify-contrast-oracle` fails CI if the Ruby helper and Bootstrap ever disagree
- Include `aria-label` with the full contact name (e.g., `aria-label="John Smith"`)
- Avatar stacks should include `aria-label` describing the group (e.g., "4 contacts, plus 3 more")
- Decorative avatars next to visible name text can use `aria-hidden="true"`

## Usage Guidelines

- **Use** in contact list rows, table cells, card headers, and anywhere a contact is referenced
- **Use** avatar stacks for showing multiple contacts (e.g., engagement participants)
- **Do not** allow manual color assignment — always use the deterministic hash
- **Do not** pin the text color. It is derived from the background; hardcoding it is the defect #130 fixed
- **Do not** use avatars without a nearby name label (screen readers need context)
- The XL size is reserved for primary profile views — do not use in lists or tables
