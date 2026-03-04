# frozen_string_literal: true

class Admin::EngagementDetailView::ComponentPreview < ApplicationComponentPreview
  # @label Default (Email)
  def default
    render_with_template
  end

  # @label With Header and Tabs
  def with_header_and_tabs
    render_with_template
  end

  # @label Meeting
  def meeting
    render_with_template
  end
end
