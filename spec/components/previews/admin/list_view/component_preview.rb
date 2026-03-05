# frozen_string_literal: true

class Admin::ListView::ComponentPreview < ApplicationComponentPreview
  # @label Default
  def default
    render_with_template
  end

  # @label Card View
  def card_view
    render_with_template
  end

  # @label With Search
  def with_search
    render_with_template
  end

  # @label Accounts List
  def accounts
    render_with_template
  end
end
