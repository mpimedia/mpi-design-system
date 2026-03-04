# frozen_string_literal: true

class Admin::ListView::ComponentPreview < ApplicationComponentPreview
  # @label Default (Contacts)
  def default
    render_with_template
  end

  # @label Card View Mode
  def card_view
    render_with_template
  end

  # @label With Search
  def with_search
    render_with_template
  end
end
