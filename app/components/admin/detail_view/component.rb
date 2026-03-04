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
    end
  end
end
