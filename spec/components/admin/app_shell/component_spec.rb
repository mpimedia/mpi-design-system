# frozen_string_literal: true

require "spec_helper"

RSpec.describe Admin::AppShell::Component, type: :component do
  it "renders the NavBar component" do
    render_inline(described_class.new(current_section: :dashboard, user_name: "Test User"))

    expect(page).to have_css("nav[aria-label='Main navigation']")
    expect(page).to have_text("MARKAZ")
  end

  it "renders the user avatar via NavBar" do
    render_inline(described_class.new(current_section: :dashboard, user_name: "Jane Doe"))

    expect(page).to have_css("span.rounded-circle", text: "JD")
  end

  it "passes current_section to NavBar" do
    render_inline(described_class.new(current_section: :crm, current_subsection: :contacts))

    expect(page).to have_css("a[aria-current='page']", text: "CRM")
    expect(page).to have_css("nav[aria-label='Section navigation']")
    expect(page).to have_css("a[aria-current='page']", text: "Contacts")
  end

  it "renders content in the main area" do
    render_inline(described_class.new(current_section: :dashboard)) do |shell|
      shell.with_body { "<p>Page content here</p>".html_safe }
    end

    expect(page).to have_css("main[role='main']", text: "Page content here")
  end

  it "renders content area with correct background" do
    render_inline(described_class.new(current_section: :dashboard))

    expect(page).to have_css("main[style*='background: #F5F7FA']")
  end

  it "renders content area with 24px padding" do
    render_inline(described_class.new(current_section: :dashboard))

    expect(page).to have_css("main[style*='padding: 24px']")
  end

  it "does not render sidebar by default" do
    render_inline(described_class.new(current_section: :dashboard))

    expect(page).not_to have_css("aside[role='complementary']")
  end

  it "renders sidebar when show_sidebar is true and sidebar content is provided" do
    render_inline(described_class.new(current_section: :content, show_sidebar: true)) do |shell|
      shell.with_sidebar { "<div>Sidebar content</div>".html_safe }
      shell.with_body { "<p>Main content</p>".html_safe }
    end

    expect(page).to have_css("aside[role='complementary']", text: "Sidebar content")
    expect(page).to have_css("aside[aria-label='Content sidebar']")
  end

  it "renders sidebar at 180px width" do
    render_inline(described_class.new(current_section: :content, show_sidebar: true)) do |shell|
      shell.with_sidebar { "<div>Sidebar</div>".html_safe }
    end

    expect(page).to have_css("aside[style*='width: 180px']")
  end

  it "does not render sidebar when show_sidebar is true but no sidebar content" do
    render_inline(described_class.new(current_section: :content, show_sidebar: true))

    expect(page).not_to have_css("aside[role='complementary']")
  end

  it "passes search_url to NavBar" do
    render_inline(described_class.new(current_section: :dashboard, search_url: "/search"))

    expect(page).to have_css("form[action='/search']")
  end

  it "uses role='document' on the outer wrapper" do
    render_inline(described_class.new(current_section: :dashboard))

    expect(page).to have_css("div[role='document']")
  end

  it "renders with full-height layout" do
    render_inline(described_class.new(current_section: :dashboard))

    expect(page).to have_css("div[style*='min-height: 100vh']")
  end
end
