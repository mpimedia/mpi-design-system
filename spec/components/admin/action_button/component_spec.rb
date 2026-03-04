# frozen_string_literal: true

require "spec_helper"

RSpec.describe Admin::ActionButton::Component, type: :component do
  it "renders a primary filled button by default" do
    render_inline(described_class.new(label: "Save"))

    expect(page).to have_css("button.btn.btn-primary", text: "Save")
  end

  it "renders an outline variant" do
    render_inline(described_class.new(label: "Filter", variant: :outline))

    expect(page).to have_css("button.btn.btn-outline-primary", text: "Filter")
  end

  it "renders with a specific color" do
    render_inline(described_class.new(label: "Delete", color: :danger))

    expect(page).to have_css("button.btn.btn-danger", text: "Delete")
  end

  it "renders at small size" do
    render_inline(described_class.new(label: "Edit", size: :sm))

    expect(page).to have_css("button.btn.btn-sm")
  end

  it "renders with an icon" do
    render_inline(described_class.new(label: "Add Contact", icon: "bi-plus-lg"))

    expect(page).to have_css("i.bi-plus-lg")
    expect(page).to have_text("Add Contact")
  end

  it "renders icon-only with aria-label" do
    render_inline(described_class.new(label: "Edit", icon: "bi-pencil", icon_only: true))

    expect(page).to have_css("button[aria-label='Edit']")
    expect(page).to have_css("i.bi-pencil")
    expect(page).not_to have_text("Edit")
  end

  it "renders as a link when href is provided" do
    render_inline(described_class.new(label: "View", href: "/contacts/1"))

    expect(page).to have_css("a.btn.btn-primary[href='/contacts/1']", text: "View")
  end

  it "renders as disabled" do
    render_inline(described_class.new(label: "Submit", disabled: true))

    expect(page).to have_css("button[disabled]")
    expect(page).to have_css("button[aria-disabled='true']")
  end

  it "includes turbo method data attribute" do
    render_inline(described_class.new(label: "Delete", color: :danger, href: "/contacts/1", method: :delete))

    expect(page).to have_css("a[data-turbo-method='delete']")
  end
end
