# frozen_string_literal: true

module MpiDesignSystem
  module Admin
    module BatchActionButton
      # A direct-submit batch action button for MpiDesignSystem::Admin::TableForIndex.
      #
      # Rendered inside the table's batch_action_buttons slot. The consuming app wraps the
      # table in a <form> (data-controller="mpi--batch-actions"); this button submits that
      # form with the selected ids[]. The +action+ becomes the submit button's +name+, so the
      # app controller dispatches on its presence (params.key?("archive")).
      class Component < ViewComponent::Base
        # @param action [String, Symbol] submit button name — the app controller keys on it.
        # @param label [String] visible button text.
        def initialize(action, label:)
          @action = action
          @label = label
        end
      end
    end
  end
end
