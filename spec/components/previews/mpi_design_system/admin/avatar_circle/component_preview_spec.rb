# frozen_string_literal: true

require "spec_helper"

# The engine-wide sweep in `spec/components/previews/preview_rendering_spec.rb`
# only proves a preview does not raise. That is not enough for the Color Variety
# scenario, whose whole job is to make every palette color — and the foreground
# derived for it — visible to a reviewer in Lookbook. Before #130 its eight names
# hashed onto only seven distinct colors, silently omitting #4EA8DE, which was
# the worst contrast failure in the palette. This spec pins the coverage.
RSpec.describe MpiDesignSystem::Admin::AvatarCircle::ComponentPreview, type: :component do
  let(:component) { MpiDesignSystem::Admin::AvatarCircle::Component }

  describe "#color_variety" do
    it "renders every color in the palette exactly once" do
      render_preview(:color_variety, from: described_class)
      html = page.native.to_html

      # Counted, not merely detected. Each name hashes to its palette index, so the
      # swatch paints `var(--mds-avatar-<index>, <hex>)`; a preview that rendered one
      # colour ten times (close to the pre-#130 bug, where eight names covered only
      # seven distinct colours) would not show all ten distinct tokens.
      occurrences = component::COLORS.each_with_index.to_h do |color, index|
        [ color, html.scan("var(--mds-avatar-#{index}, #{color})").length ]
      end

      expect(occurrences.values).to all(eq(1)),
        "expected one swatch per palette colour, got #{occurrences.reject { |_, n| n == 1 }.inspect}"
    end

    it "shows the accessible foreground derived for each background" do
      render_preview(:color_variety, from: described_class)

      component::COLORS.each_with_index do |background, index|
        foreground = MpiDesignSystem::ColorContrast.accessible_foreground(background)

        expect(page).to have_css(
          "span[style*='background-color: var(--mds-avatar-#{index}, #{background})']" \
          "[style*='color: var(--mds-avatar-#{index}-fg, #{foreground})']"
        )
      end
    end

    it "demonstrates both derived fallback foregrounds, not just one" do
      render_preview(:color_variety, from: described_class)

      expect(page).to have_css("span[style*='-fg, #000)']")
      expect(page).to have_css("span[style*='-fg, #fff)']")
    end
  end
end
