# frozen_string_literal: true

class Admin::Dashboard::ComponentPreview < ApplicationComponentPreview
  # @label Default
  def default
    render_with_template
  end

  # @label Empty State
  def empty
    render_with_template
  end
end
