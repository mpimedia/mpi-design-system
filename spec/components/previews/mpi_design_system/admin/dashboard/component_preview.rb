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
  # caller-supplied `group_data[:color]` stays a fixed hex — the documented passthrough
  # deferred to the #153 follow-up.
  def dark_mode
    render_with_template
  end
end
