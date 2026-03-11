# frozen_string_literal: true

require "spec_helper"

RSpec.describe Admin::QuickActionBar::Component, type: :component do
  let(:buttons) do
    [
      { label: "+ New Contact", path: "/admin/contacts/new", icon: "bi-plus-lg" },
      { label: "+ New Account", path: "/admin/organizations/new", icon: "bi-plus-lg" },
      { label: "+ New Engagement", path: "/admin/engagements/new" }
    ]
  end

  it "renders all buttons with correct labels and hrefs" do
    render_inline(described_class.new(buttons: buttons))

    expect(page).to have_link("+ New Contact", href: "/admin/contacts/new")
    expect(page).to have_link("+ New Account", href: "/admin/organizations/new")
    expect(page).to have_link("+ New Engagement", href: "/admin/engagements/new")
  end

  it "renders icons when provided" do
    render_inline(described_class.new(buttons: buttons))

    expect(page).to have_css("i.bi.bi-plus-lg", count: 2)
  end

  it "renders buttons without icons" do
    render_inline(described_class.new(buttons: [ { label: "Action", path: "/action" } ]))

    expect(page).to have_link("Action", href: "/action")
    expect(page).not_to have_css("i.bi")
  end

  it "does not render when buttons array is empty" do
    render_inline(described_class.new(buttons: []))

    expect(page.text).to be_blank
  end

  it "applies outline variant by default" do
    render_inline(described_class.new(buttons: [ { label: "Go", path: "/go" } ]))

    expect(page).to have_css("a.btn.btn-outline-primary")
  end

  it "applies filled variant" do
    render_inline(described_class.new(buttons: [ { label: "Go", path: "/go" } ], variant: :filled))

    expect(page).to have_css("a.btn.btn-primary")
  end

  it "applies sm size" do
    render_inline(described_class.new(buttons: [ { label: "Go", path: "/go" } ], size: :sm))

    expect(page).to have_css("a.btn.btn-sm")
  end

  it "applies md size by default" do
    render_inline(described_class.new(buttons: [ { label: "Go", path: "/go" } ]))

    expect(page).to have_css("a.btn.btn-md")
  end
end
