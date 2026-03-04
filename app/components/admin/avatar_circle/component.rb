# frozen_string_literal: true

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

      # @param name [String] Contact's full name (used for initials + color hash)
      # @param size [Symbol] :sm, :md (default), :lg, :xl
      # @param href [String] Optional link URL
      def initialize(name: nil, size: :md, href: nil)
        @name = name
        @size = SIZES.key?(size) ? size : :md
        @href = href
      end

      def call
        tag = @href ? :a : :span
        content_tag(tag, inner_content, **tag_attributes)
      end

      private

      def tag_attributes
        attrs = {
          class: "d-inline-flex align-items-center justify-content-center rounded-circle fw-semibold",
          style: inline_styles,
          aria: { label: @name || "Unknown contact" }
        }
        attrs[:href] = @href if @href
        attrs
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
          "background-color: #{background_color}",
          "color: #fff",
          "text-decoration: none",
          "line-height: 1"
        ].join("; ")
      end

      def background_color
        placeholder? ? "#6C757D" : COLORS[@name.to_s.bytes.sum % COLORS.length]
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
