# frozen_string_literal: true

require "spec_helper"

RSpec.describe MpiDesignSystem::Admin::AccountListRow::Component, type: :component do
  let(:default_params) do
    {
      name: "Sony Pictures Classics",
      type_label: "Distributor",
      location: "Los Angeles, CA",
      contact_names: [ "Sarah Chen", "James Park", "Maria Lopez" ],
      tags: [ { group: :distribution, role: "Acquisitions" } ],
      health: :active,
      account_path: "/accounts/1"
    }
  end

  it "renders avatar with account name initials" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("span.rounded-circle[aria-label='Sony Pictures Classics']", text: "SC")
  end

  it "renders account name as a link when path is provided" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("a[href='/accounts/1']", text: "Sony Pictures Classics")
  end

  it "renders account name as plain text when path is missing" do
    render_inline(described_class.new(**default_params.merge(account_path: nil)))

    expect(page).to have_css("span[style*='font-weight: 600']", text: "Sony Pictures Classics")
    expect(page).not_to have_css("a", text: "Sony Pictures Classics")
  end

  it "renders type label badge" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("span[style*='text-transform: uppercase']", text: "Distributor")
  end

  it "renders location in muted text" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("span[style*='color: #6C757D']", text: "Los Angeles, CA")
  end

  it "renders contact avatar stack" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("span.rounded-circle[aria-label='Sony Pictures Classics']", text: "SC")
    expect(page).to have_css("span.rounded-circle", text: "JP")
    expect(page).to have_css("span.rounded-circle", text: "ML")
  end

  describe "tag dots (#168)" do
    # A decorative identity dot on the row/card surface — not inside a `-subtle` chip —
    # so it keeps the solid `bg-#{variant}` treatment whose >=3:1 on both resting
    # backdrops DataTable's browser spec already proves. Geometry survives inline and is
    # pinned by exact equality so a dropped declaration reddens (#152).
    let(:dot_style) { "width: 6px; height: 6px; border-radius: 50%;" }

    MpiDesignSystem::Admin::TagChip::Component::GROUP_VARIANTS.each do |group, variant|
      it "renders the #{group} dot as a solid bg-#{variant}" do
        render_inline(described_class.new(**default_params.merge(tags: [ { group: group, role: group.to_s } ])))

        expect(page).to have_css(
          "span.d-inline-block.bg-#{variant}[aria-hidden='true'][style='#{dot_style}']", count: 1
        )
      end
    end

    it "falls back to secondary for an unknown group" do
      render_inline(described_class.new(**default_params.merge(tags: [ { group: :not_a_group, role: "Mystery" } ])))

      expect(page).to have_css("span.d-inline-block.bg-secondary[aria-hidden='true']", count: 1)
      expect(page).to have_text("Mystery")
    end

    it "renders one dot per tag" do
      tags = [ { group: :distribution, role: "Acquisitions" }, { group: :outreach, role: "Press" } ]
      render_inline(described_class.new(**default_params.merge(tags: tags)))

      expect(page).to have_css("span.d-inline-block.bg-danger[aria-hidden='true']", count: 1)
      expect(page).to have_css("span.d-inline-block.bg-success[aria-hidden='true']", count: 1)
      expect(page).to have_text("Acquisitions")
      expect(page).to have_text("Press")
    end

    # The label beside the dot is what actually carries the category for a screen
    # reader (the dot is aria-hidden), so it must stay legible in BOTH colour modes.
    # The frozen #1B2A4A navy it used to paint measures 1.09:1 on Bootstrap's dark
    # surface — which would have quietly invalidated the decorative-dot rationale.
    it "renders the accompanying label in adaptive text-body" do
      render_inline(described_class.new(**default_params.merge(tags: [ { group: :distribution, role: "Acquisitions" } ])))

      expect(page).to have_css("span.text-body", text: "Acquisitions")
      expect(inline_style("span.text-body")).to be_free_of_frozen_colour
    end

    it "renders no dots when there are no tags" do
      render_inline(described_class.new(**default_params.merge(tags: [])))

      expect(page).to have_css("span, div")
      # Reject ANY tag dot, not merely one carrying `bg-*`: a dot that lost its semantic
      # class is exactly the regression this should catch, and a `bg-*`-scoped absence
      # assertion would pass right through it (Codex PR review, P1-8).
      expect(page).not_to have_css("span[aria-hidden='true'][style*='border-radius: 50%']:not([style*='width: 8px'])")
      expect(page).not_to have_css("span[aria-hidden='true'][class*='bg-']")
    end

    it "leaves no frozen-colour declaration on the dot" do
      render_inline(described_class.new(**default_params.merge(tags: [ { group: :distribution, role: "Acquisitions" } ])))

      expect(page).to have_css("span.bg-danger[aria-hidden='true']")
      inline_styles("span[aria-hidden='true'][class*='bg-']").each do |style|
        expect(style).to be_free_of_frozen_colour
      end
    end
  end

  it "renders health status with colored dot" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("span[style*='background: #22A06B']")
    expect(page).to have_text("Active")
  end

  it "renders warm health status" do
    render_inline(described_class.new(**default_params.merge(health: :warm)))

    expect(page).to have_css("span[style*='background: #D4772C']")
    expect(page).to have_text("Warm")
  end

  it "renders cold health status" do
    render_inline(described_class.new(**default_params.merge(health: :cold)))

    expect(page).to have_css("span[style*='background: #DC3545']")
    expect(page).to have_text("Cold")
  end

  it "hides health when not provided" do
    render_inline(described_class.new(name: "Test Corp"))

    expect(page).not_to have_text("Active")
    expect(page).not_to have_text("Warm")
    expect(page).not_to have_text("Cold")
  end


  it "renders without optional fields" do
    render_inline(described_class.new(name: "Minimal Corp"))

    expect(page).to have_css("tr")
    expect(page).to have_text("Minimal Corp")
  end

  it "ignores invalid health values" do
    component = described_class.new(name: "Test", health: :invalid)
    expect(component.instance_variable_get(:@health)).to be_nil
  end
end
