# frozen_string_literal: true

module Admin
  module QuickActionBar
    class Component < ViewComponent::Base
      SIZES = %i[sm lg].freeze
      VARIANTS = %i[outline filled].freeze

      # @param buttons [Array<Hash>] Each: { label: String, path: String, icon: String (optional) }
      # @param size [Symbol] :sm, :lg, or nil (default — Bootstrap's standard btn size)
      # @param variant [Symbol] :outline (default) or :filled
      def initialize(buttons:, size: nil, variant: :outline)
        @buttons = buttons || []
        @size = SIZES.include?(size) ? size : nil
        @variant = VARIANTS.include?(variant) ? variant : :outline
      end

      def render?
        @buttons.any?
      end

      private

      def button_class
        variant_class = @variant == :filled ? "btn-primary" : "btn-outline-primary"
        classes = [ "btn", variant_class ]
        classes << "btn-#{@size}" if @size
        classes.join(" ")
      end
    end
  end
end
