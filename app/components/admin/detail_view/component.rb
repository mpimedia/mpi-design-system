# frozen_string_literal: true

module Admin
  module DetailView
    class Component < ViewComponent::Base
      renders_one :profile_panel
      renders_one :activity_panel

      VARIANTS = %i[contact account].freeze

      # @param variant [Symbol] :contact (default), :account
      def initialize(variant: :contact)
        @variant = VARIANTS.include?(variant) ? variant : :contact
      end

      private

      def container_styles
        "display: flex; gap: 24px;"
      end

      def profile_panel_styles
        [
          "width: 33.333%",
          "min-width: 0"
        ].join("; ")
      end

      def activity_panel_styles
        [
          "width: 66.666%",
          "min-width: 0"
        ].join("; ")
      end

      def contact?
        @variant == :contact
      end

      def account?
        @variant == :account
      end
    end
  end
end
