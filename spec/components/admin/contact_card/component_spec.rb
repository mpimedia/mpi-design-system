# frozen_string_literal: true

require "spec_helper"

RSpec.describe Admin::ContactCard::Component, type: :component do
  let(:default_params) do
    {
      name: "Jane Doe",
      company: "Paramount Pictures",
      tags: [
        { label: "Buyer — Theatrical", group: :buyers },
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
    expect(page).to have_text("Buyer — Theatrical")
  end

  it "renders tag pills from group symbol" do
    tags = [ { label: "Buyer — Theatrical", group: :buyers } ]
    render_inline(described_class.new(name: "Test", tags: tags))

    expect(page).to have_css("span[style*='color: #E8733A']", text: "Buyer — Theatrical")
  end

  it "renders tag pills from raw colors" do
    tags = [ { label: "Custom", color: "#2DA67E", bg_color: "#ECF8F4" } ]
    render_inline(described_class.new(name: "Test", tags: tags))

    expect(page).to have_css("span[style*='color: #2DA67E']", text: "Custom")
  end

  it "renders tag pills as rounded pills" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("span[style*='border-radius: 999px']", minimum: 1)
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
