# frozen_string_literal: true

module MpiDesignSystem
  module Admin
    module BreadcrumbNav
      class Component < ViewComponent::Base
        # @param back_path [String] URL for the back arrow link
        # @param back_label [String] Text for the back link (e.g., "Engagements")
        # @param current_title [String] Current page title displayed after the separator
        def initialize(back_path:, back_label:, current_title:)
          @back_path = back_path
          @back_label = back_label
          @current_title = current_title
        end
      end
    end
  end
end
