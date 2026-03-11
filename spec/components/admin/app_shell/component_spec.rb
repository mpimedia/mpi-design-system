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

  it "renders shell with CSS classes" do
    render_inline(described_class.new(current_section: :dashboard))

    expect(page).to have_css("div.mds-shell[role='document']")
    expect(page).to have_css("main.mds-shell__main[role='main']")
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

    expect(page).to have_css("aside.mds-shell__sidebar[role='complementary']", text: "Sidebar content")
    expect(page).to have_css("aside[aria-label='Content sidebar']")
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

    expect(page).to have_css("div.mds-shell[role='document']")
  end

  describe "breadcrumb slot" do
    it "renders breadcrumb between nav and content" do
      render_inline(described_class.new(current_section: :crm, current_subsection: :contacts)) do |shell|
        shell.with_breadcrumb do
          "<nav aria-label='Breadcrumb'>Contacts > Jane</nav>".html_safe
        end
        shell.with_body { "<p>Detail page</p>".html_safe }
      end

      expect(page).to have_css("nav[aria-label='Breadcrumb']", text: "Contacts > Jane")
    end

    it "does not render breadcrumb area when no breadcrumb provided" do
      render_inline(described_class.new(current_section: :dashboard)) do |shell|
        shell.with_body { "<p>Content</p>".html_safe }
      end

      expect(page).not_to have_css("div.mds-shell__breadcrumb")
    end
  end

  describe "forwarding nav config to NavBar" do
    it "forwards custom sections to NavBar" do
      sections = [
        { key: :home, label: "Home", href: "/admin" },
        { key: :contacts, label: "Contacts", href: "/admin/contacts" }
      ]

      render_inline(described_class.new(current_section: :home, sections: sections))

      expect(page).to have_link("Home", href: "/admin")
      expect(page).to have_link("Contacts", href: "/admin/contacts")
      expect(page).not_to have_link("Dashboard")
    end

    it "forwards environment to NavBar" do
      render_inline(described_class.new(current_section: :dashboard, environment: :development))

      expect(page).to have_css("div.mds-env-bar.mds-env-bar--development")
    end

    it "forwards system_url to NavBar" do
      render_inline(described_class.new(current_section: :dashboard, system_url: "/admin/system"))

      expect(page).to have_css("a.mds-navbar__gear[href='/admin/system']")
    end

    it "forwards sign_out_url to NavBar" do
      render_inline(described_class.new(
        current_section: :dashboard,
        user_name: "Jane Doe",
        sign_out_url: "/sign_out"
      ))

      expect(page).to have_link("Sign out", href: "/sign_out")
    end

    it "forwards custom logo_text to NavBar" do
      render_inline(described_class.new(current_section: :dashboard, logo_text: "MY CRM"))

      expect(page).to have_text("MY CRM")
    end

    it "forwards search_placeholder to NavBar" do
      render_inline(described_class.new(
        current_section: :dashboard,
        search_url: "/search",
        search_placeholder: "Search contacts, accounts, engagements"
      ))

      expect(page).to have_css("input[placeholder='Search contacts, accounts, engagements']")
    end

    it "uses default search_placeholder when not specified" do
      render_inline(described_class.new(current_section: :dashboard, search_url: "/search"))

      expect(page).to have_css("input[placeholder='Search...']")
    end
  end
end
