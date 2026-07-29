# frozen_string_literal: true

require "spec_helper"

RSpec.describe MpiDesignSystem::Admin::EngagementCard::Component, type: :component do
  let(:default_params) do
    {
      engagement_type: :email,
      time: "10:42 AM",
      subject: "Follow-up on distribution deal",
      excerpt: "Hi team, just wanted to circle back on the theatrical rights...",
      contacts: [
        { name: "John Smith", path: "/contacts/1" },
        { name: "Jane Doe", path: "/contacts/2" }
      ],
      account_name: "Sony Pictures",
      account_path: "/accounts/1",
      tags: [ { group: :distribution, role: "Acquisitions" } ],
      creator_name: "M. Johnson"
    }
  end

  it "renders as an article element" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("article[style*='border-radius: 8px']")
  end

  it "renders email type badge with blue color and background" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("span[style*='color: #2E75B6'][style*='background: #EBF3FB']", text: "EMAIL")
  end

  it "renders meeting type badge with purple color and background" do
    render_inline(described_class.new(**default_params.merge(engagement_type: :meeting)))

    expect(page).to have_css("span[style*='color: #8B5CF6'][style*='background: #F3EFFE']", text: "MEETING")
  end

  it "renders call type badge with green color and background" do
    render_inline(described_class.new(**default_params.merge(engagement_type: :call)))

    expect(page).to have_css("span[style*='color: #16A34A'][style*='background: #ECF8F4']", text: "CALL")
  end

  it "renders note type badge with orange color and background" do
    render_inline(described_class.new(**default_params.merge(engagement_type: :note)))

    expect(page).to have_css("span[style*='color: #E8913A'][style*='background: #FEF3EC']", text: "NOTE")
  end

  it "renders time" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("span[style*='color: #6C757D']", text: "10:42 AM")
  end

  it "renders subject in bold navy" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("div[style*='font-weight: 600'][style*='color: #1B2A4A']", text: /Follow-up/)
  end

  it "renders excerpt in muted text" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("div[style*='color: #6C757D'][style*='font-size: 13px']", text: /circle back/)
  end

  it "renders contact chips with avatars" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("a[href='/contacts/1']", text: "John Smith")
    expect(page).to have_css("a[href='/contacts/2']", text: "Jane Doe")
    expect(page).to have_css("span.rounded-circle", text: "JS")
  end

  it "renders contact chips as plain spans when no path" do
    contacts = [ { name: "Test User" } ]
    render_inline(described_class.new(**default_params.merge(contacts: contacts)))

    expect(page).to have_css("span[style*='background: #F5F7FA']", text: "Test User")
    expect(page).not_to have_css("a", text: "Test User")
  end

  it "renders account link in right meta" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("a[href='/accounts/1'][style*='color: #2E75B6']", text: "Sony Pictures")
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

    # DELIBERATELY the opposite of the list rows' equivalent example. This card paints
    # its own hardcoded `background: #fff`, so the label sits on a fixed white surface in
    # both colour modes: the navy measures 14.22:1 there, whereas an adaptive `text-body`
    # would resolve to #DEE2E6 in dark mode and paint 1.30:1 on that same white card.
    # `text-body` is correct only where the surface adapts too. Pinning the navy here
    # stops a well-meaning "make it adaptive" edit from reintroducing that regression.
    it "keeps the frozen navy label, because the card surface is fixed white" do
      render_inline(described_class.new(**default_params.merge(tags: [ { group: :distribution, role: "Acquisitions" } ])))

      expect(page).to have_css("span[style='font-size: 12px; color: #1B2A4A;']", text: "Acquisitions")
      expect(page).not_to have_css("span.text-body", text: "Acquisitions")
    end

    it "still paints that label against a white card, so the pair stays AA in both modes" do
      render_inline(described_class.new(**default_params.merge(tags: [ { group: :distribution, role: "Acquisitions" } ])))

      expect(page).to have_css("article[style*='background: #fff']")
      expect(MpiDesignSystem::ColorContrast.ratio("#1B2A4A", "#FFFFFF")).to be >= 4.5
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

  it "renders creator name" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("span[style*='color: #6C757D']", text: "by M. Johnson")
  end

  it "defaults invalid type to email" do
    render_inline(described_class.new(engagement_type: :invalid, subject: "Test"))

    expect(page).to have_css("span[style*='color: #2E75B6']", text: "EMAIL")
  end

  it "renders linked titles when provided" do
    titles = [ { name: "The Film", path: "/titles/1" } ]
    render_inline(described_class.new(**default_params.merge(linked_titles: titles)))

    expect(page).to have_css("a[href='/titles/1'][style*='color: #2E75B6']", text: "The Film")
  end

  it "hides right meta when no account, tags, or titles" do
    render_inline(described_class.new(
      engagement_type: :email, subject: "Test",
      account_name: nil, tags: [], linked_titles: []
    ))

    expect(page).not_to have_css("div[style*='min-width: 160px']")
  end
end
