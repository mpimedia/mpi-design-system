# frozen_string_literal: true

require "spec_helper"

RSpec.describe MpiDesignSystem::Admin::AvatarStack::Component, type: :component do
  it "renders multiple avatars" do
    render_inline(described_class.new(names: [ "Alice Wong", "Bob Smith", "Carol Davis" ]))

    expect(page).to have_css("span.rounded-circle", count: 3)
  end

  it "shows overflow indicator when names exceed max" do
    names = [ "Alice", "Bob", "Carol", "Dave", "Eve", "Frank" ]
    render_inline(described_class.new(names: names, max: 4))

    expect(page).to have_css("span.rounded-circle", minimum: 4)
    expect(page).to have_text("+2")
  end

  it "does not show overflow when within max" do
    render_inline(described_class.new(names: [ "Alice", "Bob" ]))

    expect(page).not_to have_text("+")
  end

  it "includes aria-label describing the group" do
    names = [ "Alice", "Bob", "Carol", "Dave", "Eve" ]
    render_inline(described_class.new(names: names, max: 3))

    expect(page).to have_css("div[aria-label='5 contacts, plus 2 more']")
  end

  describe "overflow chip boundary" do
    it "shows no chip when names exactly fill max" do
      render_inline(described_class.new(names: [ "Alice", "Bob", "Carol", "Dave" ], max: 4))

      expect(page).not_to have_text("+")
    end

    it "shows a +1 chip at one over max" do
      render_inline(described_class.new(names: [ "Alice", "Bob", "Carol", "Dave", "Eve" ], max: 4))

      expect(page).to have_text("+1")
    end
  end

  # The "+N" chip hand-copied AvatarCircle's markup, including a pinned
  # `color: #fff`, so it would not have inherited #130's fix. It is now derived
  # from the same helper. This pair resolves to white (4.76:1) — unchanged
  # visually, but it now tracks the background instead of assuming it.
  describe "overflow chip contrast (#130)" do
    let(:names) { [ "Alice", "Bob", "Carol", "Dave", "Eve", "Frank" ] }

    it "renders the overflow chip with a derived foreground" do
      render_inline(described_class.new(names: names, max: 4))

      expect(page).to have_css("span[style*='background-color: #64748B'][style*='color: #fff']", text: "+2")
    end

    it "renders a pairing that clears the 4.5:1 AA floor" do
      background = described_class::OVERFLOW_COLOR
      foreground = MpiDesignSystem::ColorContrast.accessible_foreground(background)

      expect(MpiDesignSystem::ColorContrast.ratio(background, foreground)).to be >= 4.5
    end

    it "keeps the white separator border, which is decorative rather than text" do
      render_inline(described_class.new(names: names, max: 4))

      expect(page).to have_css("span[style*='border: 2px solid #fff']", text: "+2")
    end

    it "renders the chip at the small size too" do
      render_inline(described_class.new(names: names, max: 4, size: :sm))

      expect(page).to have_css("span[style*='width: 28px'][style*='color: #fff']", text: "+2")
    end
  end
end
