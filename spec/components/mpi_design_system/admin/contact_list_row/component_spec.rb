# frozen_string_literal: true

require "spec_helper"

RSpec.describe MpiDesignSystem::Admin::ContactListRow::Component, type: :component do
  let(:default_params) do
    {
      name: "John Smith",
      title: "Theatrical Buyer",
      tags: [ { group: :distribution, role: "Acquisitions" } ],
      last_engagement: "2 days ago",
      account_name: "Sony Pictures",
      account_path: "/accounts/1"
    }
  end

  it "renders avatar with contact name" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("span.rounded-circle", text: "JS")
  end

  it "renders name in bold navy" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("div[style*='font-weight: 600'][style*='color: #1B2A4A']", text: "John Smith")
  end

  it "renders job title below name" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("div[style*='font-size: 12px'][style*='color: #6C757D']", text: "Theatrical Buyer")
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

  it "renders last engagement in muted text" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("span[style*='color: #6C757D']", text: "2 days ago")
  end

  it "renders account as a blue link" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("a[href='/accounts/1'][style*='color: #2E75B6']", text: "Sony Pictures")
  end

  it "renders account as plain text when path is missing" do
    render_inline(described_class.new(**default_params.merge(account_path: nil)))

    expect(page).to have_css("span[style*='color: #2E75B6']", text: "Sony Pictures")
    expect(page).not_to have_css("a", text: "Sony Pictures")
  end


  it "hides title when not provided" do
    render_inline(described_class.new(name: "John Smith"))

    expect(page).not_to have_css("div[style*='font-size: 12px'][style*='color: #6C757D']")
  end

  context "search_result variant" do
    let(:search_params) do
      {
        name: "Jane Doe",
        title: "Festival Director",
        tags: [ { group: :press_festival, role: "Festival — Director" } ],
        variant: :search_result,
        match_text: "Title contains <strong>director</strong>",
        last_engagement: "1 week ago",
        status: :active
      }
    end

    it "renders match found in column with highlighted text" do
      render_inline(described_class.new(**search_params))

      expect(page).to have_css("strong", text: "director")
    end

    it "renders status with colored dot" do
      render_inline(described_class.new(**search_params))

      expect(page).to have_css("span[style*='background: #22A06B']")
      expect(page).to have_text("Active")
    end

    it "renders inactive status with gray dot" do
      render_inline(described_class.new(**search_params.merge(status: :inactive)))

      expect(page).to have_css("span[style*='background: #6C757D']")
      expect(page).to have_text("Inactive")
    end

    it "does not render account column in search variant" do
      render_inline(described_class.new(**search_params.merge(account_name: "Acme")))

      expect(page).not_to have_css("a", text: "Acme")
    end
  end
end
