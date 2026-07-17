# frozen_string_literal: true

module MpiDesignSystem
  module Admin
    module BatchActionModalButton
      # A modal-gated batch action button for MpiDesignSystem::Admin::TableForIndex.
      #
      # Rendered inside the table's batch_action_modal_buttons slot. The trigger opens a
      # Bootstrap modal whose body is the component's content slot (extra fields the operator
      # fills in); the modal footer's submit button carries the same +action+ name and posts
      # the wrapping app <form> with the selected ids[]. Modals are not reparented in Bootstrap
      # 5, so the submit stays inside the app form.
      class Component < ViewComponent::Base
        # @param action [String, Symbol] submit button name — the app controller keys on it.
        # @param label [String] visible trigger + modal title + submit text.
        def initialize(action, label:)
          @action = action
          @label = label
        end
      end
    end
  end
end
