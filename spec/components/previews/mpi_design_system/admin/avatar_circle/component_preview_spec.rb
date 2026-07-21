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

      rendered_backgrounds = component::COLORS.select do |color|
        page.native.to_html.include?("background-color: #{color}")
      end

      expect(rendered_backgrounds).to match_array(component::COLORS)
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
