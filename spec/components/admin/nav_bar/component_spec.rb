# frozen_string_literal: true

require "spec_helper"

RSpec.describe Admin::NavBar::Component, type: :component do
  it "renders the brand logo SVG and MARKAZ text" do
    render_inline(described_class.new(current_section: :dashboard))

    expect(page).to have_css("svg")
    expect(page).to have_text("MARKAZ")
  end

  it "renders all 6 default navigation sections" do
    render_inline(described_class.new(current_section: :dashboard))

    expect(page).to have_link("Dashboard")
    expect(page).to have_link("Content")
    expect(page).to have_link("CRM")
    expect(page).to have_link("Rights & Avails")
    expect(page).to have_link("Releases")
    expect(page).to have_link("Screenings")
  end

  it "highlights the active section with CSS class" do
    render_inline(described_class.new(current_section: :crm))

    expect(page).to have_css("a.mds-navbar__section-link--active[aria-current='page']", text: "CRM")
  end

  it "renders inactive sections without active class" do
    render_inline(described_class.new(current_section: :crm))

    dashboard_link = page.find("a.mds-navbar__section-link", text: "Dashboard")
    expect(dashboard_link[:class]).not_to include("mds-navbar__section-link--active")
  end

  it "renders Level 1 only when section has no sub-nav" do
    render_inline(described_class.new(current_section: :dashboard))

    expect(page).to have_css("nav[aria-label='Main navigation']")
    expect(page).not_to have_css("nav[aria-label='Section navigation']")
  end

  it "renders Level 1 + Level 2 for CRM section" do
    render_inline(described_class.new(current_section: :crm, current_subsection: :contacts))

    expect(page).to have_css("nav[aria-label='Main navigation']")
    expect(page).to have_css("nav[aria-label='Section navigation']")
    expect(page).to have_link("Contacts")
    expect(page).to have_link("Accounts")
    expect(page).to have_link("Engagements")
  end

  it "highlights the active subsection with CSS class" do
    render_inline(described_class.new(current_section: :crm, current_subsection: :contacts))

    expect(page).to have_css("a.mds-subnav__link--active[aria-current='page']", text: "Contacts")
  end

  it "renders the user avatar" do
    render_inline(described_class.new(current_section: :dashboard, user_name: "Jane Doe"))

    expect(page).to have_css("span.rounded-circle", text: "JD")
  end

  it "renders the search bar when search_url is provided" do
    render_inline(described_class.new(current_section: :dashboard, search_url: "/search"))

    expect(page).to have_css("form[action='/search']")
    expect(page).to have_css("input[type='search']")
  end

  it "does not render search bar when search_url is nil" do
    render_inline(described_class.new(current_section: :dashboard))

    expect(page).not_to have_css("form[action]")
  end

  it "renders the navbar with mds-navbar CSS class" do
    render_inline(described_class.new(current_section: :dashboard))

    expect(page).to have_css("div.mds-navbar")
  end

  it "renders the sub-nav with mds-subnav CSS class" do
    render_inline(described_class.new(current_section: :crm, current_subsection: :dashboard))

    expect(page).to have_css("div.mds-subnav")
  end

  it "logo links to first section href by default" do
    render_inline(described_class.new(current_section: :dashboard))

    expect(page).to have_css("a.mds-navbar__brand[href='/dashboard']", text: "MARKAZ")
  end

  describe "search_placeholder passthrough" do
    it "passes custom placeholder to SearchBar" do
      render_inline(described_class.new(
        current_section: :dashboard,
        search_url: "/search",
        search_placeholder: "Search contacts, accounts, engagements"
      ))

      expect(page).to have_css("input[placeholder='Search contacts, accounts, engagements']")
    end

    it "uses default placeholder when not specified" do
      render_inline(described_class.new(current_section: :dashboard, search_url: "/search"))

      expect(page).to have_css("input[placeholder='Search...']")
    end
  end

  describe "environment bar" do
    it "renders 10px env bar for development" do
      render_inline(described_class.new(current_section: :dashboard, environment: :development))

      expect(page).to have_css("div.mds-env-bar.mds-env-bar--development")
    end

    it "renders 10px env bar for staging" do
      render_inline(described_class.new(current_section: :dashboard, environment: :staging))

      expect(page).to have_css("div.mds-env-bar.mds-env-bar--staging")
    end

    it "does not render env bar for production" do
      render_inline(described_class.new(current_section: :dashboard, environment: :production))

      expect(page).not_to have_css("div.mds-env-bar")
    end

    it "does not render env bar when environment is nil" do
      render_inline(described_class.new(current_section: :dashboard))

      expect(page).not_to have_css("div.mds-env-bar")
    end
  end

  describe "custom sections" do
    let(:custom_sections) do
      [
        { key: :home, label: "Home", href: "/admin" },
        { key: :contacts, label: "Contacts", href: "/admin/contacts" },
        { key: :settings, label: "Settings", href: "/admin/settings" }
      ]
    end

    it "renders custom sections instead of defaults" do
      render_inline(described_class.new(current_section: :home, sections: custom_sections))

      expect(page).to have_link("Home", href: "/admin")
      expect(page).to have_link("Contacts", href: "/admin/contacts")
      expect(page).to have_link("Settings", href: "/admin/settings")
      expect(page).not_to have_link("Dashboard")
      expect(page).not_to have_link("CRM")
    end

    it "highlights the active custom section" do
      render_inline(described_class.new(current_section: :contacts, sections: custom_sections))

      expect(page).to have_css("a.mds-navbar__section-link--active[aria-current='page']", text: "Contacts")
    end

    it "uses first custom section href for logo link" do
      render_inline(described_class.new(current_section: :home, sections: custom_sections))

      expect(page).to have_css("a.mds-navbar__brand[href='/admin']", text: "MARKAZ")
    end

    it "renders placeholder sections that will 404" do
      sections = [
        { key: :crm, label: "CRM", href: "/admin/organizations" },
        { key: :avails, label: "Avails", href: "/avails" }
      ]
      render_inline(described_class.new(current_section: :crm, sections: sections))

      expect(page).to have_link("Avails", href: "/avails")
    end
  end

  describe "custom subsections" do
    let(:custom_subsections) do
      {
        contacts: [
          { key: :all, label: "All", href: "/admin/contacts" },
          { key: :recent, label: "Recent", href: "/admin/contacts/recent" }
        ]
      }
    end

    it "renders custom subsections for the active section" do
      render_inline(described_class.new(
        current_section: :contacts,
        current_subsection: :all,
        sections: [ { key: :contacts, label: "Contacts", href: "/admin/contacts" } ],
        subsections: custom_subsections
      ))

      expect(page).to have_css("nav[aria-label='Section navigation']")
      expect(page).to have_link("All", href: "/admin/contacts")
      expect(page).to have_link("Recent", href: "/admin/contacts/recent")
    end
  end

  describe "visible: false sections" do
    it "hides sections marked as not visible" do
      sections = [
        { key: :home, label: "Home", href: "/admin", visible: true },
        { key: :hidden, label: "Hidden", href: "/admin/hidden", visible: false },
        { key: :settings, label: "Settings", href: "/admin/settings" }
      ]

      render_inline(described_class.new(current_section: :home, sections: sections))

      expect(page).to have_link("Home")
      expect(page).to have_link("Settings")
      expect(page).not_to have_link("Hidden")
    end
  end

  describe "system admin gear" do
    it "renders gear icon when system_url is provided" do
      render_inline(described_class.new(current_section: :dashboard, system_url: "/admin/system"))

      expect(page).to have_css("a.mds-navbar__gear[href='/admin/system']")
      expect(page).to have_css("a[aria-label='System administration'] svg")
    end

    it "does not render gear icon when system_url is nil" do
      render_inline(described_class.new(current_section: :dashboard))

      expect(page).not_to have_css("a.mds-navbar__gear")
    end
  end

  describe "user menu" do
    it "renders avatar as dropdown trigger when sign_out_url is provided" do
      render_inline(described_class.new(
        current_section: :dashboard,
        user_name: "Jane Doe",
        sign_out_url: "/sign_out"
      ))

      expect(page).to have_css("button[data-bs-toggle='dropdown'][aria-label='User menu']")
      expect(page).to have_css(".dropdown-menu")
      expect(page).to have_link("Sign out", href: "/sign_out")
    end

    it "shows user name in the dropdown" do
      render_inline(described_class.new(
        current_section: :dashboard,
        user_name: "Jane Doe",
        sign_out_url: "/sign_out"
      ))

      expect(page).to have_css(".dropdown-item-text", text: "Jane Doe")
    end

    it "renders avatar with nav variant" do
      render_inline(described_class.new(
        current_section: :dashboard,
        user_name: "Jane Doe",
        sign_out_url: "/sign_out"
      ))

      expect(page).to have_css("span.mds-avatar--nav")
    end

    it "renders profile link when profile_url is provided" do
      render_inline(described_class.new(
        current_section: :dashboard,
        user_name: "Jane Doe",
        sign_out_url: "/sign_out",
        profile_url: "/profile"
      ))

      expect(page).to have_link("Profile", href: "/profile")
    end

    it "uses turbo method for sign out" do
      render_inline(described_class.new(
        current_section: :dashboard,
        sign_out_url: "/sign_out"
      ))

      expect(page).to have_css("a[data-turbo-method='delete']", text: "Sign out")
    end

    it "renders plain avatar when no sign_out_url or profile_url" do
      render_inline(described_class.new(
        current_section: :dashboard,
        user_name: "Jane Doe"
      ))

      expect(page).not_to have_css("button[data-bs-toggle='dropdown']")
      expect(page).to have_css("span.rounded-circle", text: "JD")
    end
  end

  describe "custom logo" do
    it "renders custom logo text" do
      render_inline(described_class.new(current_section: :dashboard, logo_text: "MARKAZ CRM"))

      expect(page).to have_css("a.mds-navbar__brand", text: "MARKAZ CRM")
    end

    it "renders custom logo href" do
      render_inline(described_class.new(current_section: :dashboard, logo_href: "/admin"))

      expect(page).to have_css("a.mds-navbar__brand[href='/admin']")
    end
  end

  describe "regression: profile_url without sign_out_url" do
    it "does not render sign out link when only profile_url is provided" do
      render_inline(described_class.new(
        current_section: :dashboard,
        user_name: "Jane Doe",
        profile_url: "/profile"
      ))

      expect(page).to have_css("button[data-bs-toggle='dropdown']")
      expect(page).to have_link("Profile", href: "/profile")
      expect(page).not_to have_link("Sign out")
    end
  end

  describe "regression: logo href with hidden first section" do
    it "uses first visible section href for logo link" do
      sections = [
        { key: :hidden, label: "Hidden", href: "/hidden", visible: false },
        { key: :home, label: "Home", href: "/home" },
        { key: :settings, label: "Settings", href: "/settings" }
      ]

      render_inline(described_class.new(current_section: :home, sections: sections))

      expect(page).to have_css("a.mds-navbar__brand[href='/home']", text: "MARKAZ")
    end
  end
end
