# frozen_string_literal: true

# Renders the NavBar and AppShell inside data-bs-theme="light" and ="dark"
# wrappers on a real page, against the real compiled Bootstrap bundle, so the
# browser-level feature spec (spec/features/nav_bar_theme_spec.rb) can read
# COMPUTED styles.
#
# `render_inline` proves the ERB emits the right `.mds-*` class names, but the
# #154 conversion changed only CSS *rules* in `_nav_bar.scss` — the emitted markup
# is byte-identical before and after. The proof therefore has to live where the
# change lives: the painted pixels. Only a browser resolves `var(--bs-*)` under
# each `data-bs-theme`, so this host page exists to be measured. (#154)
class NavThemeDemoController < ApplicationController
  def show; end
end
