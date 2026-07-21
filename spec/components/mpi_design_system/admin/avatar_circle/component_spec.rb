# frozen_string_literal: true

require "spec_helper"

# One name per palette index, so all 10 colors are exercised — asserted by the
# coverage example rather than assumed. Plain locals, not constants: a constant
# declared inside an RSpec block lands on Object and leaks across the suite.
names_by_palette_index = {
  0 => "Jane Cooper",
  1 => "Sarah Williams",
  2 => "Tom Wilson",
  3 => "Lisa Park",
  4 => "Dana Reyes",
  5 => "Robert Fox",
  6 => "Emily Chen",
  7 => "Mona Habib",
  8 => "Hana Ito",
  9 => "David Kim"
}.freeze

# Frozen from Bootstrap's compiled `color-contrast()` output; re-verified against
# a fresh Bootstrap compile in CI by `bin/verify-contrast-oracle`.
expected_foreground_by_color = {
  "#2E75B6" => "#fff",
  "#8B5CF6" => "#000",
  "#E8733A" => "#000",
  "#2DA67E" => "#000",
  "#D97706" => "#000",
  "#6366F1" => "#000",
  "#DC3545" => "#fff",
  "#4EA8DE" => "#000",
  "#22A06B" => "#000",
  "#64748B" => "#fff"
}.freeze

RSpec.describe MpiDesignSystem::Admin::AvatarCircle::Component, type: :component do
  it "renders initials from a full name" do
    render_inline(described_class.new(name: "John Smith"))

    expect(page).to have_css("span.rounded-circle", text: "JS")
  end

  it "uses deterministic color from name" do
    render_inline(described_class.new(name: "John Smith"))
    first_html = page.native.inner_html

    render_inline(described_class.new(name: "John Smith"))
    second_html = page.native.inner_html

    expect(first_html).to eq(second_html)
  end

  it "produces different colors for different names" do
    render_inline(described_class.new(name: "Alice Wong"))
    alice_html = page.native.inner_html

    render_inline(described_class.new(name: "Bob Johnson"))
    bob_html = page.native.inner_html

    expect(alice_html).not_to eq(bob_html)
  end

  it "renders a placeholder when no name is provided" do
    render_inline(described_class.new)

    expect(page).to have_css("i.bi.bi-person-fill")
    expect(page).to have_css("span[style*='background-color: #6C757D']")
  end

  # The contrast gate for issue #130. Before it, 7 of the 10 palette colors
  # rendered white initials below the 4.5:1 AA floor — #4EA8DE was 2.63:1, and
  # #22A06B was the very 3.33:1 pair issue #128 had just fixed in Badge.
  #
  # These assertions read the ACTUAL RENDERED inline style, so they prove
  # `inline_styles` emits the derived value — not merely that the helper would
  # have returned it. The expected foregrounds are the frozen map in
  # `spec/lib/mpi_design_system/color_contrast_spec.rb`, taken from Bootstrap's
  # compiled `color-contrast()` output and re-verified against a fresh Bootstrap
  # compile in CI by `bin/verify-contrast-oracle`.
  describe "foreground contrast (#130)" do
    it "exercises every palette color, so no entry escapes the gate" do
      hashed = names_by_palette_index.values.map { |name| name.bytes.sum % described_class::COLORS.length }

      expect(hashed).to match_array((0...described_class::COLORS.length).to_a)
      expect(expected_foreground_by_color.keys).to match_array(described_class::COLORS)
    end

    names_by_palette_index.each do |index, name|
      context "for a name hashing to palette index #{index}" do
        let(:background) { described_class::COLORS[index] }
        let(:foreground) { expected_foreground_by_color.fetch(background) }

        it "renders #{name.inspect} with an accessible foreground on its background" do
          render_inline(described_class.new(name: name))

          expect(page).to have_css("span[style*='background-color: #{background}']")
          expect(page).to have_css("span[style*='color: #{foreground}']")
        end

        it "renders a pairing that clears the 4.5:1 AA floor" do
          expect(MpiDesignSystem::ColorContrast.ratio(background, foreground)).to be >= 4.5
        end
      end
    end

    it "no longer pins white on the seven backgrounds where it failed AA" do
      previously_failing = %w[#8B5CF6 #E8733A #2DA67E #D97706 #6366F1 #4EA8DE #22A06B]

      previously_failing.each do |background|
        index = described_class::COLORS.index(background)
        render_inline(described_class.new(name: names_by_palette_index.fetch(index)))

        expect(page).to have_css("span[style*='background-color: #{background}']")
        expect(page).to have_no_css("span[style*='color: #fff']")
      end
    end

    it "keeps white where it was already accessible, changing no more than it must" do
      %w[#2E75B6 #DC3545 #64748B].each do |background|
        index = described_class::COLORS.index(background)
        render_inline(described_class.new(name: names_by_palette_index.fetch(index)))

        expect(page).to have_css("span[style*='color: #fff']")
      end
    end

    it "derives an accessible foreground for the placeholder background too" do
      render_inline(described_class.new)

      expect(page).to have_css("span[style*='background-color: #6C757D']")
      expect(page).to have_css("span[style*='color: #fff']")
      expect(MpiDesignSystem::ColorContrast.ratio(described_class::PLACEHOLDER_COLOR, "#fff")).to be >= 4.5
    end

    it "keeps the foreground accessible at every size" do
      described_class::SIZES.each_key do |size|
        render_inline(described_class.new(name: "Mona Habib", size: size))

        expect(page).to have_css("span[style*='color: #000']")
      end
    end

    it "derives the foreground for links as well as spans" do
      render_inline(described_class.new(name: "Mona Habib", href: "/contacts/1"))

      expect(page).to have_css("a[style*='background-color: #4EA8DE'][style*='color: #000']")
    end
  end

  it "renders as a link when href is provided" do
    render_inline(described_class.new(name: "Jane Doe", href: "/contacts/1"))

    expect(page).to have_css("a.rounded-circle[href='/contacts/1']", text: "JD")
  end

  it "renders at small size" do
    render_inline(described_class.new(name: "Test User", size: :sm))

    expect(page).to have_css("span[style*='width: 28px']")
    expect(page).to have_css("span[style*='font-size: 11px']")
  end

  it "renders at xl size" do
    render_inline(described_class.new(name: "Test User", size: :xl))

    expect(page).to have_css("span[style*='width: 80px']")
    expect(page).to have_css("span[style*='font-size: 28px']")
  end

  it "includes aria-label with the contact name" do
    render_inline(described_class.new(name: "Maria Garcia"))

    expect(page).to have_css("span[aria-label='Maria Garcia']")
  end

  describe "sizes" do
    {
      sm: [ 28, 11 ],
      md: [ 40, 14 ],
      lg: [ 56, 20 ],
      xl: [ 80, 28 ]
    }.each do |size, (dimension, font_size)|
      it "renders #{size} at #{dimension}px with #{font_size}px text" do
        render_inline(described_class.new(name: "Test User", size: size))

        expect(page).to have_css("span[style*='width: #{dimension}px'][style*='height: #{dimension}px']")
        expect(page).to have_css("span[style*='font-size: #{font_size}px']")
      end
    end

    it "falls back to md for an unknown size" do
      render_inline(described_class.new(name: "Test User", size: :enormous))

      expect(page).to have_css("span[style*='width: 40px'][style*='font-size: 14px']")
    end
  end

  describe "name edge cases" do
    it "renders the placeholder for an empty name" do
      render_inline(described_class.new(name: ""))

      expect(page).to have_css("i.bi.bi-person-fill")
    end

    it "renders the placeholder for a whitespace-only name" do
      render_inline(described_class.new(name: "   "))

      expect(page).to have_css("i.bi.bi-person-fill")
    end

    # An empty string is truthy in Ruby, so the previous `@name || "Unknown contact"`
    # emitted `aria-label=""` — an unlabelled control, despite rendering the
    # placeholder icon. (#130)
    [ "", "   ", nil ].each do |blank|
      it "labels a #{blank.inspect} name as Unknown contact rather than emitting an empty label" do
        render_inline(described_class.new(name: blank))

        expect(page).to have_css("span[aria-label='Unknown contact']")
        expect(page).to have_no_css("span[aria-label='']")
      end
    end

    it "derives initials from a single-word name" do
      render_inline(described_class.new(name: "Cher"))

      expect(page).to have_css("span.rounded-circle", text: "CC")
    end

    it "collapses extra whitespace between name parts" do
      render_inline(described_class.new(name: "  Jane   Cooper  "))

      expect(page).to have_css("span.rounded-circle", text: "JC")
    end
  end

  describe "nav variant" do
    it "adds mds-avatar--nav class when variant is :nav" do
      render_inline(described_class.new(name: "Jane Doe", size: :sm, variant: :nav))

      expect(page).to have_css("span.mds-avatar--nav")
    end

    it "does not add nav class for default variant" do
      render_inline(described_class.new(name: "Jane Doe", size: :sm))

      expect(page).not_to have_css("span.mds-avatar--nav")
    end

    it "does not add nav class when variant is explicitly :default" do
      render_inline(described_class.new(name: "Jane Doe", size: :sm, variant: :default))

      expect(page).not_to have_css("span.mds-avatar--nav")
    end

    it "falls back to default for invalid variant" do
      render_inline(described_class.new(name: "Jane Doe", variant: :invalid))

      expect(page).not_to have_css("span.mds-avatar--nav")
    end
  end
end
