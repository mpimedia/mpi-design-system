# frozen_string_literal: true

require "spec_helper"

RSpec.describe MpiDesignSystem::Admin::Badge::Component, type: :component do
  it "renders a filled badge with default color" do
    render_inline(described_class.new(label: "Active"))

    expect(page).to have_css("span.badge.rounded-pill.text-bg-primary", text: "Active")
  end

  it "renders a filled danger badge" do
    render_inline(described_class.new(label: "Overdue", color: :danger))

    expect(page).to have_css("span.badge.text-bg-danger", text: "Overdue")
  end

  it "renders a filled secondary badge" do
    render_inline(described_class.new(label: "Draft", color: :secondary))

    expect(page).to have_css("span.badge.text-bg-secondary", text: "Draft")
  end

  it "renders a filled success badge with Bootstrap-computed contrast" do
    render_inline(described_class.new(label: "Paid", color: :success))

    # text-bg-success lets Bootstrap derive the foreground (#000 / 6.31:1 against
    # $mpi-success #22A06B) instead of the retired hardcoded text-white (3.33:1).
    expect(page).to have_css("span.badge.text-bg-success", text: "Paid")
    expect(page).to have_no_css("span.badge.bg-success")
    expect(page).to have_no_css("span.badge.text-white")
  end

  it "uses Bootstrap-computed dark text on warning background for accessibility" do
    render_inline(described_class.new(label: "Pending", color: :warning))

    expect(page).to have_css("span.badge.text-bg-warning", text: "Pending")
    expect(page).to have_no_css("span.badge.bg-warning")
    expect(page).to have_no_css("span.badge.text-dark")
  end

  it "renders a filled info badge" do
    render_inline(described_class.new(label: "Note", color: :info))

    expect(page).to have_css("span.badge.text-bg-info", text: "Note")
  end

  it "renders an outline info badge" do
    render_inline(described_class.new(label: "Note", variant: :outline, color: :info))

    expect(page).to have_css("span.badge.border.border-info.text-info")
  end

  it "defaults invalid color to primary" do
    render_inline(described_class.new(label: "Test", color: :invalid))

    expect(page).to have_css("span.badge.text-bg-primary")
  end

  it "renders an outline variant" do
    render_inline(described_class.new(label: "Draft", variant: :outline, color: :secondary))

    expect(page).to have_css("span.badge.border.border-secondary.text-secondary")
  end

  describe "the tag_group variant (#168)" do
    # Plumbing for every group. The mapping itself is pinned once, in the TagChip spec.
    described_class::GROUP_VARIANTS.each do |group, variant|
      it "renders #{group} as the #{variant} subtle/emphasis pair with no inline style" do
        render_inline(described_class.new(label: group.to_s, variant: :tag_group, tag_group: group))

        expect(page).to have_css(
          "span.badge.rounded-pill.bg-#{variant}-subtle.text-#{variant}-emphasis", text: group.to_s
        )
        # The retired `tag_group_styles` was this component's only inline style, so
        # after the conversion the badge emits none at all.
        expect(page).not_to have_css("span.badge[style]")
      end
    end

    # Preserves the retired helper's exact behaviour: it returned nil for an unknown
    # group and the template then omitted the `style` attribute, leaving an unstyled
    # badge. `secondary` would have been a behaviour change, not a colour-source change.
    it "renders an unstyled badge for an unknown tag group" do
      render_inline(described_class.new(label: "Mystery", variant: :tag_group, tag_group: :not_a_group))

      expect(page).to have_css("span.badge.rounded-pill", text: "Mystery")
      expect(page).not_to have_css("span.badge[class*='-subtle']")
      expect(page).not_to have_css("span.badge[class*='-emphasis']")
      expect(page).not_to have_css("span.badge[style]")
    end

    it "renders an unstyled badge when the variant is tag_group but no group is given" do
      render_inline(described_class.new(label: "Plain", variant: :tag_group))

      expect(page).to have_css("span.badge.rounded-pill", text: "Plain")
      expect(page).not_to have_css("span.badge[class*='-subtle']")
    end

    # A tag_group passed to a non-tag_group variant must not leak into the output —
    # `variant_classes` only consults it on the :tag_group branch.
    it "ignores tag_group on the filled variant" do
      render_inline(described_class.new(label: "Active", variant: :filled, color: :success, tag_group: :distribution))

      expect(page).to have_css("span.badge.text-bg-success", text: "Active")
      expect(page).not_to have_css("span.badge[class*='-subtle']")
    end

    it "emits no hex literal for any group" do
      described_class::GROUP_VARIANTS.each_key do |group|
        render_inline(described_class.new(label: group.to_s, variant: :tag_group, tag_group: group))

        expect(page).to have_css("span.badge", text: group.to_s)
        expect(page.native.to_html).not_to match(/#[0-9A-Fa-f]{6}\b/)
      end
    end
  end

  # The fold-in removed Badge's own TAG_GROUPS duplicate; the other two variants must
  # be untouched by it. Looping the constants means a typo in either ships red.
  describe "the other variants are unaffected by the fold-in" do
    described_class::COLORS.each do |color|
      it "still renders the filled #{color} variant via text-bg-*" do
        render_inline(described_class.new(label: color.to_s, variant: :filled, color: color))

        expect(page).to have_css("span.badge.text-bg-#{color}", text: color.to_s)
      end

      it "still renders the outline #{color} variant" do
        render_inline(described_class.new(label: color.to_s, variant: :outline, color: color))

        expect(page).to have_css(
          "span.badge.border.border-#{color}.text-#{color}.bg-transparent", text: color.to_s
        )
      end
    end
  end

  it "renders with a count" do
    render_inline(described_class.new(label: "Contacts", count: 24))

    expect(page).to have_css("span.badge", text: "Contacts 24")
    expect(page).to have_css("span[aria-label='Contacts: 24']")
  end
end
