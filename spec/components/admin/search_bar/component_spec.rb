# frozen_string_literal: true

require "spec_helper"

RSpec.describe Admin::SearchBar::Component, type: :component do
  it "renders a search form with icon and input" do
    render_inline(described_class.new)

    expect(page).to have_css("form[role='search']")
    expect(page).to have_css("i.bi.bi-search")
    expect(page).to have_css("input[type='search'][placeholder='Search...']")
  end

  it "renders with custom placeholder" do
    render_inline(described_class.new(placeholder: "Search contacts..."))

    expect(page).to have_css("input[placeholder='Search contacts...']")
  end

  it "renders with a value and clear link" do
    render_inline(described_class.new(value: "John", url: "/contacts"))

    expect(page).to have_css("input[value='John']")
    expect(page).to have_css("a[aria-label='Clear search']")
  end

  it "does not show clear link when empty" do
    render_inline(described_class.new)

    expect(page).not_to have_css("a[aria-label='Clear search']")
  end

  it "renders with search button" do
    render_inline(described_class.new(show_button: true))

    expect(page).to have_css("button.btn.btn-primary", text: "Search")
  end

  it "renders at large size" do
    render_inline(described_class.new(size: :lg))

    expect(page).to have_css("input.form-control.form-control-lg")
  end

  it "includes aria-label on the input" do
    render_inline(described_class.new)

    expect(page).to have_css("input[aria-label='Search']")
  end

  it "sets the form action URL" do
    render_inline(described_class.new(url: "/contacts/search"))

    expect(page).to have_css("form[action='/contacts/search']")
  end
end
