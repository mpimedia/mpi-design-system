# frozen_string_literal: true

require "spec_helper"

RSpec.describe Admin::AccountListRow::Component, type: :component do
  let(:default_params) do
    {
      name: "Sony Pictures Classics",
      type_label: "Distributor",
      location: "Los Angeles, CA",
      contact_names: [ "Sarah Chen", "James Park", "Maria Lopez" ],
      tags: [ { group: :buyers, role: "Buyer — Theatrical" } ],
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

  it "renders tag dots with group colors" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("span[style*='background: #E8733A']")
    expect(page).to have_text("Buyer — Theatrical")
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

  it "renders multiple tags" do
    tags = [
      { group: :buyers, role: "Buyer — Theatrical" },
      { group: :press, role: "Press — Publicist" }
    ]
    render_inline(described_class.new(**default_params.merge(tags: tags)))

    expect(page).to have_css("span[style*='background: #E8733A']")
    expect(page).to have_css("span[style*='background: #2DA67E']")
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
