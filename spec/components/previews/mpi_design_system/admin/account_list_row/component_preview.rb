# frozen_string_literal: true

class MpiDesignSystem::Admin::AccountListRow::ComponentPreview < ApplicationComponentPreview
  # @label Default
  def default
    render_with_template
  end

  # @label Minimal
  def minimal
    render_with_template
  end

  # @label Cold Health
  def cold_health
    render_with_template
  end
end
