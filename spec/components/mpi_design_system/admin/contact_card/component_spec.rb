# frozen_string_literal: true

require "spec_helper"

RSpec.describe MpiDesignSystem::Admin::ContactCard::Component, type: :component do
  let(:default_params) do
    {
      name: "Jane Doe",
      company: "Paramount Pictures",
      tags: [
        { label: "Acquisitions", group: :distribution },
        { label: "Critic", color: "#2DA67E", bg_color: "#ECF8F4" }
      ],
      last_engaged: "2 days ago",
      engagement_count: 12,
      owner_name: "J. Smith",
      path: "/contacts/1"
    }
  end

  it "renders as a clickable link" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("a[href='/contacts/1']")
  end

  it "renders card with white background and rounded border" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("a[style*='background: #fff'][style*='border-radius: 8px']")
  end

  it "renders avatar with name" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("span.rounded-circle", text: "JD")
  end

  it "renders name in bold navy" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("div[style*='font-weight: 600'][style*='color: #1B2A4A']", text: "Jane Doe")
  end

  it "renders company in gray" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("div[style*='color: #6C757D']", text: "Paramount Pictures")
  end

  it "renders tag pills with colored dots" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("span[style*='border-radius: 50%']", minimum: 1)
    expect(page).to have_text("Acquisitions")
  end

  describe "tag pills (#168)" do
    # The complete surviving inline style for a semantic pill — exact equality, so any
    # dropped or added declaration reddens rather than silently passing (#152).
    let(:semantic_pill_style) { "padding: 2px 8px; font-size: 11px; font-weight: 500" }
    let(:pill_dot_style) { "width: 6px; height: 6px; border-radius: 50%; background-color: currentColor; flex-shrink: 0" }

    MpiDesignSystem::Admin::TagChip::Component::GROUP_VARIANTS.each do |group, variant|
      it "renders a #{group} tag as the #{variant} subtle/emphasis pair" do
        render_inline(described_class.new(name: "Test", tags: [ { label: group.to_s, group: group } ]))

        expect(page).to have_css(
          "span.rounded-pill.bg-#{variant}-subtle.text-#{variant}-emphasis[style='#{semantic_pill_style}']",
          text: group.to_s
        )
      end
    end

    # The dot is a direct child of the pill, so `currentColor` resolves to whatever the
    # pill paints — the `-emphasis` foreground here, the caller's own colour below.
    # Child combinator, not descendant: the latter would pass with the semantic class
    # on any ancestor wrapper (#152).
    it "nests a currentColor dot directly inside the pill" do
      render_inline(described_class.new(name: "Test", tags: [ { label: "Acquisitions", group: :distribution } ]))

      expect(page).to have_css(
        "span.bg-danger-subtle.text-danger-emphasis > span[aria-hidden='true'][style='#{pill_dot_style}']"
      )
    end

    # #168 replaced the old no-group default — a frozen #64748B on #F1F5F9 that ISS#142
    # measured at 4.34:1, below the AA floor — with the adaptive secondary pair. Only
    # genuinely caller-supplied colour stays inline (the ISS#172 passthrough principle).
    it "falls back to the adaptive secondary pair when neither group nor custom colour is given" do
      render_inline(described_class.new(name: "Test", tags: [ { label: "Plain" } ]))

      expect(page).to have_css(
        "span.rounded-pill.bg-secondary-subtle.text-secondary-emphasis[style='#{semantic_pill_style}']",
        text: "Plain"
      )
      expect(page.native.to_html).not_to include("#64748B")
      expect(page.native.to_html).not_to include("#F1F5F9")
    end

    describe "the caller-supplied colour passthrough" do
      it "keeps both custom values inline when no group is given" do
        tags = [ { label: "Custom", color: "#2DA67E", bg_color: "#ECF8F4" } ]
        render_inline(described_class.new(name: "Test", tags: tags))

        expect(page).to have_css(
          "span.rounded-pill[style='#{semantic_pill_style}; color: #2DA67E; background-color: #ECF8F4']",
          text: "Custom"
        )
        expect(page).not_to have_css("span[class*='-subtle']")
      end

      # Precedence. The custom values here are ones the semantic path can NEVER emit,
      # so this fails if custom ever overrides a known group — which asserting a
      # reachable-by-both value could not distinguish (False Green #1).
      it "ignores custom colours when the group is known" do
        tags = [ { label: "Acquisitions", group: :distribution, color: "#123456", bg_color: "#654321" } ]
        render_inline(described_class.new(name: "Test", tags: tags))

        expect(page).to have_css(
          "span.rounded-pill.bg-danger-subtle.text-danger-emphasis[style='#{semantic_pill_style}']",
          text: "Acquisitions"
        )
        expect(page.native.to_html).not_to include("#123456")
        expect(page.native.to_html).not_to include("#654321")
      end

      # The two halves fall back independently, exactly as resolve_color/resolve_bg did.
      # Requiring BOTH to be present would pass the two-value example above and still
      # break these callers.
      it "keeps a custom foreground while defaulting the background" do
        render_inline(described_class.new(name: "Test", tags: [ { label: "FgOnly", color: "#123456" } ]))

        expect(page).to have_css(
          "span.rounded-pill[style='#{semantic_pill_style}; color: #123456; background-color: #F1F5F9']",
          text: "FgOnly"
        )
      end

      it "keeps a custom background while defaulting the foreground" do
        render_inline(described_class.new(name: "Test", tags: [ { label: "BgOnly", bg_color: "#654321" } ]))

        expect(page).to have_css(
          "span.rounded-pill[style='#{semantic_pill_style}; color: #64748B; background-color: #654321']",
          text: "BgOnly"
        )
      end
    end

    it "leaves no frozen-colour declaration on a semantic pill or its dot" do
      render_inline(described_class.new(name: "Test", tags: [ { label: "Acquisitions", group: :distribution } ]))

      expect(page).to have_css("span.bg-danger-subtle", text: "Acquisitions")
      inline_styles("span.rounded-pill, span.rounded-pill > span").each do |style|
        expect(style).to be_free_of_frozen_colour
      end
    end
  end

  it "renders last engaged time with prefix" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_text("Last engaged: 2 days ago")
  end

  it "renders engagement count" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_text("12 engagements")
  end

  it "renders owner name" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_text("Owner: J. Smith")
  end

  it "renders metadata in light gray" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("div[style*='color: #ADB5BD']")
  end

  it "hides company when not provided" do
    render_inline(described_class.new(name: "Test User", path: "/contacts/2"))

    expect(page).not_to have_css("div[style*='font-size: 13px'][style*='color: #6C757D']")
  end

  it "renders without tags" do
    render_inline(described_class.new(name: "Test User", tags: [], path: "/contacts/2"))

    expect(page).not_to have_css("span[style*='border-radius: 999px']")
  end

  it "hides owner when not provided" do
    render_inline(described_class.new(name: "Test User", path: "/contacts/2"))

    expect(page).not_to have_text("Owner:")
  end
end
