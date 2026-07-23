# frozen_string_literal: true

class MpiDesignSystem::Admin::Dashboard::ComponentPreview < ApplicationComponentPreview
  # @label Default
  def default
    render_with_template
  end

  # @label Empty State
  def empty
    render_with_template
  end

  # @label Dark Mode
  # The same populated Dashboard rendered inside a `data-bs-theme="dark"` scope, so the
  # converted `bg-body` / `text-body` / `-subtle` / `-emphasis` utilities resolve to their
  # dark values (the precedent in pagination / data_table / filter_chip_bar). The chart's
  # caller-supplied `group_data[:color]` stays a fixed hex — the deliberate consumer-owned
  # passthrough (decided #172).
  def dark_mode
    render_with_template
  end
end
