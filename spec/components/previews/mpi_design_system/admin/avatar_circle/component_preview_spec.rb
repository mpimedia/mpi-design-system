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

      # Counted, not merely detected. A `select` over "does this colour appear"
      # would pass on a preview that rendered one colour ten times and called it
      # variety — which is close to the bug this preview had before #130, where
      # eight names covered only seven distinct colours.
      occurrences = component::COLORS.to_h do |color|
        [ color, html.scan("background-color: #{color}").length ]
      end

      expect(occurrences.values).to all(eq(1)),
        "expected one swatch per palette colour, got #{occurrences.reject { |_, n| n == 1 }.inspect}"
    end

    it "shows the accessible foreground derived for each background" do
      render_preview(:color_variety, from: described_class)

      component::COLORS.each do |background|
        foreground = MpiDesignSystem::ColorContrast.accessible_foreground(background)

        expect(page).to have_css(
          "span[style*='background-color: #{background}'][style*='color: #{foreground}']"
        )
      end
    end

    it "demonstrates both derived foregrounds, not just one" do
      render_preview(:color_variety, from: described_class)

      expect(page).to have_css("span[style*='color: #000']")
      expect(page).to have_css("span[style*='color: #fff']")
    end
  end
end
