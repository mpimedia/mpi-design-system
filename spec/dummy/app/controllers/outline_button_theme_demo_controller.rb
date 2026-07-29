# frozen_string_literal: true

# Renders every `ActionButton` outline variant inside data-bs-theme="light" and ="dark"
# wrappers on a real page, against the real compiled Bootstrap bundle, so the
# browser-level feature spec (spec/features/outline_button_theme_spec.rb) can read
# COMPUTED styles.
#
# The ISS#183 follow-up fix lives entirely in `_buttons.scss` — it re-points
# `--bs-btn-color` at `--bs-#{semantic}-text-emphasis` and changes no markup at all, so
# `render_inline` sees a byte-identical `btn btn-outline-primary` before and after and
# cannot prove anything about it. Only a browser resolves the custom property under each
# `data-bs-theme`, so this host page exists to be measured.
class OutlineButtonThemeDemoController < ApplicationController
  def show; end
end
