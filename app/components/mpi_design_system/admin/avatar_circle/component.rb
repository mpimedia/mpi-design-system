# frozen_string_literal: true

module MpiDesignSystem
  module Admin
    module AvatarCircle
      class Component < ViewComponent::Base
        SIZES = {
          sm: { dimension: 28, font_size: 11 },
          md: { dimension: 40, font_size: 14 },
          lg: { dimension: 56, font_size: 20 },
          xl: { dimension: 80, font_size: 28 }
        }.freeze

        COLORS = %w[#2E75B6 #8B5CF6 #E8733A #2DA67E #D97706 #6366F1 #DC3545 #4EA8DE #22A06B #64748B].freeze

        PLACEHOLDER_COLOR = "#6C757D"

        VARIANTS = %i[default nav].freeze

        # @param name [String] Contact's full name (used for initials + color hash)
        # @param size [Symbol] :sm, :md (default), :lg, :xl
        # @param href [String] Optional link URL
        # @param variant [Symbol] :default or :nav (nav-specific compact styling)
        def initialize(name: nil, size: :md, href: nil, variant: :default)
          @name = name
          @size = SIZES.key?(size) ? size : :md
          @href = href
          @variant = VARIANTS.include?(variant) ? variant : :default
        end

        def call
          tag = @href ? :a : :span
          content_tag(tag, inner_content, **tag_attributes)
        end

        private

        def tag_attributes
          attrs = {
            class: css_classes,
            style: inline_styles,
            # Keyed off `placeholder?`, not `@name || …`: an empty or whitespace
            # name is truthy in Ruby, so the fallback never fired and the avatar
            # rendered `aria-label=""` — an unlabelled control for a screen reader,
            # even though it visibly shows the placeholder icon. (#130)
            aria: { label: placeholder? ? "Unknown contact" : @name }
          }
          attrs[:href] = @href if @href
          attrs
        end

        def css_classes
          classes = "d-inline-flex align-items-center justify-content-center rounded-circle fw-semibold"
          classes += " mds-avatar--nav" if @variant == :nav
          classes
        end

        def inner_content
          if placeholder?
            content_tag(:i, "", class: "bi bi-person-fill", aria: { hidden: true })
          else
            initials
          end
        end

        def inline_styles
          size = SIZES[@size]
          [
            "width: #{size[:dimension]}px",
            "height: #{size[:dimension]}px",
            "font-size: #{size[:font_size]}px",
            "background-color: #{background_value}",
            "color: #{foreground_value}",
            "text-decoration: none",
            "line-height: 1"
          ].join("; ")
        end

        # The colour is a runtime custom property so a consuming app can re-brand it
        # (and dark mode can adapt) once `_avatar.scss` is imported — the token wins
        # over the fallback. The inline literal is the fallback that keeps existing
        # installs, which do not import that partial, painting today's palette: the
        # change is non-breaking. (#169)
        def background_value
          "var(--mds-avatar-#{color_key}, #{fallback_background})"
        end

        # Paired with the background as a runtime custom property; the fallback is the
        # derived foreground (below), so it stays AA-accessible against the fallback
        # background even with the partial absent. (#169)
        def foreground_value
          "var(--mds-avatar-#{color_key}-fg, #{fallback_foreground})"
        end

        # `placeholder` for the missing-name case, otherwise the 0-based hash bucket —
        # the suffix of the `--mds-avatar-*` custom property this avatar paints.
        def color_key
          placeholder? ? "placeholder" : (@name.to_s.bytes.sum % COLORS.length)
        end

        def fallback_background
          placeholder? ? PLACEHOLDER_COLOR : COLORS[@name.to_s.bytes.sum % COLORS.length]
        end

        # Derived rather than pinned. `COLORS` mixes brand, semantic and tag-group
        # tokens with a wide luminance spread, so no single foreground is accessible
        # against all of them: white fails 7 of the 10, black fails the other 3.
        # Deriving per background keeps the fallback at AA, and keeps it there if the
        # palette ever changes. (#130, still the render-time source for the #169 fallback)
        def fallback_foreground
          MpiDesignSystem::ColorContrast.accessible_foreground(fallback_background)
        end

        def initials
          parts = @name.to_s.strip.split
          return "?" if parts.empty?
          "#{parts.first[0]}#{parts.last[0]}".upcase
        end

        def placeholder?
          @name.nil? || @name.to_s.strip.empty?
        end
      end
    end
  end
end
