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

  describe "edge cases" do
    it "renders nothing but the group wrapper for an empty name list" do
      render_inline(described_class.new(names: []))

      expect(page).to have_css("div[role='group']")
      expect(page).to have_no_css("span.rounded-circle")
    end

    it "labels an empty stack without raising" do
      render_inline(described_class.new(names: []))

      expect(page).to have_css("div[aria-label='0 contacts']")
    end

    it "falls back to md for an unknown size" do
      render_inline(described_class.new(names: [ "Alice", "Bob", "Carol", "Dave", "Eve" ], max: 4, size: :enormous))

      expect(page).to have_css("span[style*='width: 40px']", text: "+1")
    end

    it "renders every avatar when max exceeds the list length" do
      render_inline(described_class.new(names: [ "Alice", "Bob" ], max: 10))

      expect(page).to have_css("span.rounded-circle", count: 2)
      expect(page).to have_no_text("+")
    end
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
  # `color: #fff`, so it would not have inherited #130's fix. Its foreground is now
  # derived from the same helper (resolves to white, 4.76:1 — visually unchanged).
  # #150 additionally converts the separator ring from a pinned `#fff` to
  # `var(--bs-body-bg)` so it tracks the surface in either colour mode.
  describe "overflow chip (#130 contrast + #150 adaptive ring)" do
    let(:names) { [ "Alice", "Bob", "Carol", "Dave", "Eve", "Frank" ] }

    # Matches 3-, 4-, 6- and 8-digit CSS hex; trailing (?!\h) stops over-matching.
    let(:hex_literal) { /#(?:\h{8}|\h{6}|\h{4}|\h{3})(?!\h)/ }

    it "renders the overflow chip with the neutral background and derived foreground" do
      render_inline(described_class.new(names: names, max: 4))

      expect(page).to have_css("span[style*='background-color: #64748B'][style*='color: #fff']", text: "+2")
    end

    it "renders a pairing that clears the 4.5:1 AA floor" do
      background = described_class::OVERFLOW_COLOR
      foreground = MpiDesignSystem::ColorContrast.accessible_foreground(background)

      expect(MpiDesignSystem::ColorContrast.ratio(background, foreground)).to be >= 4.5
    end

    # #150: the separator ring was `2px solid #fff` — a pinned light colour that stayed
    # white in dark mode. It now tracks `var(--bs-body-bg)`, so the ring is the surface
    # colour in either mode. The positive pin proves the var survived render_inline;
    # the two absence guards pin the specific regression it replaces.
    it "tracks the body background for the separator ring instead of pinning white" do
      render_inline(described_class.new(names: names, max: 4))

      expect(page).to have_css("span[style*='border: 2px solid var(--bs-body-bg)']", text: "+2")
      expect(page).to have_no_css("span[style*='solid #fff']")
      expect(page).to have_no_css("span[style*='solid #ffffff']")
    end

    it "renders the chip at the small size too" do
      render_inline(described_class.new(names: names, max: 4, size: :sm))

      expect(page).to have_css("span[style*='width: 28px'][style*='color: #fff']", text: "+2")
    end

    # AvatarStack's own only hex is the chip's background/foreground pair — its visible
    # avatars are AvatarCircle sub-renders, whose palette is swept by AvatarCircle's own
    # spec, so an unscoped rendered_content sweep would red on them.
    #
    # A global gsub of the two allowed hex strings is a false green: it deletes those
    # values from ANY property, so a NEW `outline: 1px solid #64748B` (a hex re-introduced
    # in a different declaration) would be gsubbed away and escape detection. Instead,
    # parse the style into `property: value` declarations and assert EXACTLY the two
    # permitted declarations carry a hex — any hex in a third declaration reddens here.
    # (The `solid #fff`/`solid #ffffff` ring guards above stay: a re-pinned white ring
    # is a hex in the derived-foreground's own value, which this pair-level check allows.)
    it "permits hex in exactly the two intentional chip declarations and nowhere else" do
      render_inline(described_class.new(names: names, max: 4))

      chip = page.find("span[aria-hidden='true']")
      expect(chip.text.strip).to eq("+2")

      background = described_class::OVERFLOW_COLOR
      foreground = MpiDesignSystem::ColorContrast.accessible_foreground(background)

      declarations = chip[:style].split(";").map(&:strip).reject(&:empty?)
      hex_bearing = declarations.select { |declaration| declaration.match?(hex_literal) }

      expect(hex_bearing).to contain_exactly(
        "background-color: #{background}",
        "color: #{foreground}"
      )
    end
  end
end
