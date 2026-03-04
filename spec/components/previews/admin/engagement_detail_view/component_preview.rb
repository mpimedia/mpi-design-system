# frozen_string_literal: true

class Admin::EngagementDetailView::ComponentPreview < ApplicationComponentPreview
  # @label Default (Email)
  def default
    render_with_template(
      template: "admin/engagement_detail_view/component_preview/default"
    )
  end

  # @label Main Content Only
  def main_only
    render_with_template(
      template: "admin/engagement_detail_view/component_preview/main_only"
    )
  end
end
