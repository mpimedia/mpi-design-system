# frozen_string_literal: true

class MpiDesignSystem::Admin::TableForIndex::ComponentPreview < ApplicationComponentPreview
  # @label Default
  def default
    render_with_template
  end

  # @label Sortable Headers
  def sortable
    render_with_template
  end

  # @label Batch Actions
  def batch
    render_with_template
  end

  # @label Empty
  def empty
    render_with_template
  end
end
