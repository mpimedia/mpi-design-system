# frozen_string_literal: true

# Renders the four components fixed by issue #130 on a real page, against the real
# compiled Bootstrap bundle, so the browser-level feature spec can read COMPUTED
# styles.
#
# `render_inline` proves the ERB emits the right class and style attributes, but it
# applies no stylesheet — it cannot prove `.text-bg-primary` actually wins over the
# inline `style` attribute, nor that `color: inherit` on the remove `<a>` resolves to
# the pill's derived foreground rather than Bootstrap's `--bs-link-color`. Only a
# browser resolves the cascade. (#130)
class ContrastDemoController < ApplicationController
  def show; end
end
