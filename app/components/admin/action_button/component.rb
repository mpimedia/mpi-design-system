# frozen_string_literal: true

module Admin
  module ActionButton
    class Component < ViewComponent::Base
      COLORS = %i[primary success danger warning secondary].freeze
      VARIANTS = %i[filled outline].freeze
      SIZES = %i[sm md lg].freeze

      # @param label [String] Button text
      # @param color [Symbol] :primary (default), :success, :danger, :warning, :secondary
      # @param variant [Symbol] :filled (default), :outline
      # @param size [Symbol] :sm, :md (default), :lg
      # @param icon [String] Bootstrap Icon class (e.g., "bi-plus-lg")
      # @param icon_only [Boolean] Hide label, show only icon (default: false)
      # @param disabled [Boolean] Disable the button (default: false)
      # @param href [String] Optional — renders as <a> instead of <button>
      # @param method [Symbol] HTTP method for Turbo (:post, :patch, :delete)
      # @param data [Hash] data-* attributes (Turbo/Stimulus)
      def initialize(label:, color: :primary, variant: :filled, size: :md, icon: nil,
                     icon_only: false, disabled: false, href: nil, method: nil, data: {})
        @label = label
        @color = COLORS.include?(color) ? color : :primary
        @variant = VARIANTS.include?(variant) ? variant : :filled
        @size = SIZES.include?(size) ? size : :md
        @icon = icon
        @icon_only = icon_only
        @disabled = disabled
        @href = href
        @method = method
        @data = data
      end

      def call
        if @href
          link_to(@href, **tag_attributes) { inner_content }
        else
          content_tag(:button, inner_content, **tag_attributes)
        end
      end

      private

      def tag_attributes
        attrs = { class: css_classes, data: turbo_data }
        attrs[:disabled] = "disabled" if @disabled
        attrs[:aria] = { label: @label } if @icon_only
        attrs[:aria] = (attrs[:aria] || {}).merge(disabled: true) if @disabled
        attrs
      end

      def css_classes
        classes = ["btn", btn_color_class]
        classes << "btn-#{@size}" unless @size == :md
        classes.join(" ")
      end

      def btn_color_class
        if @variant == :outline
          "btn-outline-#{@color}"
        else
          "btn-#{@color}"
        end
      end

      def turbo_data
        d = @data.dup
        d[:turbo_method] = @method if @method
        d
      end

      def inner_content
        parts = []
        parts << content_tag(:i, "", class: "#{@icon} #{'me-1' unless @icon_only}", aria: { hidden: true }) if @icon
        parts << @label unless @icon_only
        safe_join(parts)
      end
    end
  end
end
