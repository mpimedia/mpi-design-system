# frozen_string_literal: true

module Admin
  module TabBar
    class Component < ViewComponent::Base
      VARIANTS = %i[underline pill].freeze
      SIZES = %i[md sm].freeze

      # @param tabs [Array<Hash>] Tab definitions:
      #   [{ label: "Metadata", href: "#", active: true },
      #    { label: "Archive Files", href: "#", count: 47 },
      #    { label: "Disabled", href: "#", disabled: true }]
      # @param variant [Symbol] :underline (default), :pill
      # @param size [Symbol] :md (default), :sm (for in-panel use)
      def initialize(tabs:, variant: :underline, size: :md)
        @tabs = tabs
        @variant = VARIANTS.include?(variant) ? variant : :underline
        @size = SIZES.include?(size) ? size : :md
      end

      private

      def container_styles
        if @variant == :underline
          "border-bottom: 1px solid #DEE2E6; display: flex; gap: 0;"
        else
          "display: flex; gap: 8px;"
        end
      end

      def tab_styles(tab)
        if @variant == :underline
          underline_tab_styles(tab)
        else
          pill_tab_styles(tab)
        end
      end

      def underline_tab_styles(tab)
        font_size = @size == :sm ? "13px" : "14px"
        padding = @size == :sm ? "8px 12px" : "10px 16px"
        active = tab[:active]
        disabled = tab[:disabled]

        styles = [
          "font-size: #{font_size}",
          "font-weight: #{active ? '600' : '500'}",
          "color: #{tab_color(active, disabled)}",
          "padding: #{padding}",
          "border-bottom: 2px solid #{active ? '#2E75B6' : 'transparent'}",
          "text-decoration: none",
          "cursor: #{disabled ? 'not-allowed' : 'pointer'}"
        ]
        styles.join("; ")
      end

      def pill_tab_styles(tab)
        font_size = @size == :sm ? "12px" : "13px"
        active = tab[:active]
        disabled = tab[:disabled]

        styles = [
          "padding: 6px 16px",
          "border-radius: 999px",
          "font-size: #{font_size}",
          "font-weight: #{active ? '600' : '500'}",
          "text-decoration: none",
          "cursor: #{disabled ? 'not-allowed' : 'pointer'}"
        ]

        if active
          styles.concat(["background: #2E75B6", "color: #fff", "border: 1px solid #2E75B6"])
        else
          styles.concat(["background: #fff", "color: #{tab_color(false, disabled)}", "border: 1px solid #DEE2E6"])
        end

        styles.join("; ")
      end

      def tab_color(active, disabled)
        if disabled
          "#CED4DA"
        elsif active
          "#2E75B6"
        else
          "#6C757D"
        end
      end

      def count_styles
        "font-size: 12px; color: #6C757D; margin-left: 4px;"
      end

      def tab_label(tab)
        if tab[:count]
          "#{tab[:label]} (#{tab[:count]})"
        else
          tab[:label]
        end
      end
    end
  end
end
