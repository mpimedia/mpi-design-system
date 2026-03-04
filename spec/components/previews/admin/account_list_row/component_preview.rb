# frozen_string_literal: true

class Admin::AccountListRow::ComponentPreview < ApplicationComponentPreview
  # @label Default
  def default
    render_with_template(
      template: "admin/account_list_row/component_preview/default"
    )
  end

  # @label Minimal
  def minimal
    render_with_template(
      template: "admin/account_list_row/component_preview/minimal"
    )
  end

  # @label Cold Health
  def cold_health
    render_with_template(
      template: "admin/account_list_row/component_preview/cold_health"
    )
  end
end
