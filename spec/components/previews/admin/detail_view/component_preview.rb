# frozen_string_literal: true

class Admin::DetailView::ComponentPreview < ApplicationComponentPreview
  # @label Contact Detail
  def contact
    render_with_template
  end

  # @label Account Detail
  def account
    render_with_template
  end
end
