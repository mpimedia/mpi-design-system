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
- **Text color:** Always white (`#fff`) on all background colors — all palette colors are dark enough for WCAG AA

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
- Each avatar has a `2px solid #fff` border to create visual separation
- Overflow shows "+N" in a gray (`#64748B`) circle with smaller font size (11px)
- Stack is read left-to-right; earlier avatars render on top

## States

| State | Description |
|---|---|
| Default | Initials on deterministic background color |
| Placeholder | `bi-person-fill` icon on `#6C757D` background |

## Props / API

```ruby
# Admin::AvatarCircle::Component
class Admin::AvatarCircle::Component < ViewComponent::Base
  # @param name [String] Contact's full name (used for initials + color hash)
  # @param size [Symbol] :sm, :md (default), :lg, :xl
  # @param href [String] Optional link URL
end

# Admin::AvatarStack::Component
class Admin::AvatarStack::Component < ViewComponent::Base
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

def initials(name)
  parts = name.to_s.strip.split
  return "?" if parts.empty?
  "#{parts.first[0]}#{parts.last[0]}".upcase
end
```

## Accessibility

- White text on all background colors meets WCAG AA 4.5:1 contrast
- Include `aria-label` with the full contact name (e.g., `aria-label="John Smith"`)
- Avatar stacks should include `aria-label` describing the group (e.g., "4 contacts, plus 3 more")
- Decorative avatars next to visible name text can use `aria-hidden="true"`

## Usage Guidelines

- **Use** in contact list rows, table cells, card headers, and anywhere a contact is referenced
- **Use** avatar stacks for showing multiple contacts (e.g., engagement participants)
- **Do not** allow manual color assignment — always use the deterministic hash
- **Do not** use avatars without a nearby name label (screen readers need context)
- The XL size is reserved for primary profile views — do not use in lists or tables
