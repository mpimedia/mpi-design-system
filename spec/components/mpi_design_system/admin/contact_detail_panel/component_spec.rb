# frozen_string_literal: true

require "spec_helper"

RSpec.describe MpiDesignSystem::Admin::ContactDetailPanel::Component, type: :component do
  let(:default_params) do
    {
      name: "Jane Doe",
      title: "VP of Acquisitions",
      company: "Sony Pictures",
      tags: [
        { label: "VIP", group: :distribution },
        { label: "TIFF 2026", group: :press_festival }
      ],
      add_tag_path: "/contacts/1/tags/new",
      email: "jane@sonypictures.com",
      phone: "+1 (555) 123-4567",
      account: { name: "Sony Pictures", path: "/accounts/42" },
      location: "Los Angeles, CA",
      added_date: "Jan 15, 2026",
      owner: { name: "M. Johnson", path: "/users/5" },
      auto_groups: [
        { label: "Distribution", group: :distribution },
        { label: "Press/Festival", group: :press_festival }
      ]
    }
  end

  it "renders card with white background and rounded border" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("div[style*='background: #fff'][style*='border-radius: 8px']")
  end

  it "renders aria-label with contact name" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("div[aria-label='Contact details for Jane Doe']")
  end

  it "renders 56px AvatarCircle" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("span[style*='width: 56px']", text: "JD")
  end

  it "renders name as h5" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("h5", text: "Jane Doe")
  end

  it "renders title" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("div[style*='color: #6C757D']", text: "VP of Acquisitions")
  end

  it "renders company" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_text("Sony Pictures")
  end

  it "renders tags section heading" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("div[style*='text-transform: uppercase']", text: "Tags")
  end

  it "renders TagChip components for each tag" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("span.fw-semibold", text: "VIP")
    expect(page).to have_css("span.fw-semibold", text: "TIFF 2026")
  end

  it "renders + Add tag link" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("a[href='/contacts/1/tags/new']", text: "+ Add tag")
  end

  it "renders contact info section heading" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("div[style*='text-transform: uppercase']", text: "Contact Info")
  end

  it "renders email as mailto link" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("a[href='mailto:jane@sonypictures.com']", text: "jane@sonypictures.com")
  end

  it "renders phone number" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_text("+1 (555) 123-4567")
  end

  it "renders account as link" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("a[href='/accounts/42']", text: "Sony Pictures")
  end

  it "renders location" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_text("Los Angeles, CA")
  end

  it "renders added date" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_text("Jan 15, 2026")
  end

  it "renders owner as link" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("a[href='/users/5']", text: "M. Johnson")
  end

  it "renders owner label" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("div[style*='text-transform: uppercase']", text: "Owner")
  end

  it "renders auto-groups section heading" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("div[style*='text-transform: uppercase']", text: /Groups/)
  end

  # This panel has TWO tag-rendering paths — delegated `TagChip` components for @tags,
  # and its own auto-group pills. A bare `span.bg-danger-subtle` would pass if only the
  # delegated chip were correct, so every assertion here is scoped to the auto-group
  # pill by its own class (`d-inline-block`, which TagChip's `d-inline-flex` chip never
  # carries).
  describe "auto-group pills (#168)" do
    let(:pill) { "span.rounded-pill.d-inline-block" }
    let(:pill_style) { "padding: 2px 8px; font-size: 11px; font-weight: 500" }

    it "renders each auto-group as its semantic subtle/emphasis pair" do
      render_inline(described_class.new(**default_params))

      expect(page).to have_css("#{pill}.bg-danger-subtle.text-danger-emphasis", text: "Distribution")
      expect(page).to have_css("#{pill}.bg-primary-subtle.text-primary-emphasis", text: "Press/Festival")
    end

    MpiDesignSystem::Admin::TagChip::Component::GROUP_VARIANTS.each do |group, variant|
      it "renders the #{group} pill as the #{variant} pair with its complete geometry" do
        render_inline(described_class.new(
          **default_params.merge(auto_groups: [ { label: group.to_s, group: group } ])
        ))

        expect(page).to have_css(
          "#{pill}.bg-#{variant}-subtle.text-#{variant}-emphasis[style='#{pill_style}']", text: group.to_s
        )
      end
    end

    it "falls back to the adaptive secondary pair for an unknown group" do
      render_inline(described_class.new(
        **default_params.merge(auto_groups: [ { label: "Mystery", group: :not_a_group } ])
      ))

      expect(page).to have_css("#{pill}.bg-secondary-subtle.text-secondary-emphasis", text: "Mystery")
    end

    it "renders no auto-group section when the list is empty" do
      render_inline(described_class.new(**default_params.merge(auto_groups: [])))

      expect(page).to have_text("Jane Doe")
      expect(page).not_to have_css(pill)
    end

    it "leaves no frozen-colour declaration on a pill" do
      render_inline(described_class.new(**default_params))

      expect(page).to have_css("#{pill}.bg-danger-subtle", text: "Distribution")
      inline_styles(pill).each { |style| expect(style).to be_free_of_frozen_colour }
    end

    # The delegated TagChip path carries its own conversion; this proves the panel
    # actually renders it, so the two paths above are genuinely distinct.
    it "renders @tags through the delegated TagChip, not the auto-group pill" do
      render_inline(described_class.new(
        **default_params.merge(tags: [ { label: "VIP", group: :outreach } ], auto_groups: [])
      ))

      expect(page).to have_css("span.d-inline-flex.bg-success-subtle", text: "VIP")
      expect(page).not_to have_css(pill)
    end
  end

  it "renders hr dividers between sections" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("hr[style*='border-top: 1px solid #DEE2E6']", minimum: 3)
  end

  context "with minimal data" do
    it "renders without tags section when no tags" do
      render_inline(described_class.new(name: "Jane Doe"))

      expect(page).not_to have_text("Tags")
    end

    it "renders without contact info when none provided" do
      render_inline(described_class.new(name: "Jane Doe"))

      expect(page).not_to have_text("Contact Info")
    end

    it "renders without auto-groups when none provided" do
      render_inline(described_class.new(name: "Jane Doe"))

      expect(page).not_to have_text("Groups")
    end

    it "still renders avatar and name" do
      render_inline(described_class.new(name: "Jane Doe"))

      expect(page).to have_css("h5", text: "Jane Doe")
      expect(page).to have_css("span.rounded-circle", text: "JD")
    end
  end

  context "with tags but no add_tag_path" do
    it "does not render + Add tag link" do
      render_inline(described_class.new(
        name: "Jane Doe",
        tags: [ { label: "VIP", group: :distribution } ]
      ))

      expect(page).not_to have_text("+ Add tag")
    end
  end
end
