# frozen_string_literal: true

module Admin
  module QuickActionBar
    class Component < ViewComponent::Base
      SIZES = %i[sm md].freeze
      VARIANTS = %i[outline filled].freeze

      # @param buttons [Array<Hash>] Each: { label: String, path: String, icon: String (optional) }
      # @param size [Symbol] :sm or :md (default)
      # @param variant [Symbol] :outline (default) or :filled
      def initialize(buttons:, size: :md, variant: :outline)
        @buttons = buttons || []
        @size = SIZES.include?(size) ? size : :md
        @variant = VARIANTS.include?(variant) ? variant : :outline
      end

      def render?
        @buttons.any?
      end

      private

      def button_class
        variant_class = @variant == :filled ? "btn-primary" : "btn-outline-primary"
        size_class = "btn-#{@size}"
        "btn #{variant_class} #{size_class}"
      end
    end
  end
end
