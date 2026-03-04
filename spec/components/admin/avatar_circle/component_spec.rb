# frozen_string_literal: true

require "spec_helper"

RSpec.describe Admin::AvatarCircle::Component, type: :component do
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
    expect(page).to have_css("span[style*='#6C757D']")
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
end
