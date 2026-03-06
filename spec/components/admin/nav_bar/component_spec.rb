# frozen_string_literal: true

require "spec_helper"

RSpec.describe Admin::NavBar::Component, type: :component do
  it "renders the Nexus logo SVG and MARKAZ text" do
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

  it "highlights the active section with blue underline" do
    render_inline(described_class.new(current_section: :crm))

    expect(page).to have_css("a[aria-current='page'][style*='color: #2E75B6'][style*='font-weight: 600']", text: "CRM")
  end

  it "renders inactive sections in gray" do
    render_inline(described_class.new(current_section: :crm))

    expect(page).to have_css("a[style*='color: #6C757D']", text: "Dashboard")
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

  it "highlights the active subsection" do
    render_inline(described_class.new(current_section: :crm, current_subsection: :contacts))

    expect(page).to have_css("nav[aria-label='Section navigation'] a[aria-current='page']", text: "Contacts")
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

  it "renders the top bar at 52px height" do
    render_inline(described_class.new(current_section: :dashboard))

    expect(page).to have_css("div[style*='height: 52px']")
  end

  it "renders the sub-nav at 42px height" do
    render_inline(described_class.new(current_section: :crm, current_subsection: :dashboard))

    expect(page).to have_css("div[style*='height: 42px']")
  end

  it "logo links to dashboard" do
    render_inline(described_class.new(current_section: :dashboard))

    expect(page).to have_css("a[href='/dashboard'] span", text: "MARKAZ")
  end

  context "with custom sections" do
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

      expect(page).to have_css("a[aria-current='page']", text: "Contacts")
    end

    it "uses first custom section href for logo link" do
      render_inline(described_class.new(current_section: :home, sections: custom_sections))

      expect(page).to have_css("a[href='/admin'] span", text: "MARKAZ")
    end
  end

  context "with custom subsections" do
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

  context "with visible: false sections" do
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

  context "with environment color-coding" do
    it "renders development environment with blue background" do
      render_inline(described_class.new(current_section: :dashboard, environment: :development))

      expect(page).to have_css("div[style*='background: #2E75B6']")
    end

    it "renders staging environment with red background" do
      render_inline(described_class.new(current_section: :dashboard, environment: :staging))

      expect(page).to have_css("div[style*='background: #DC3545']")
    end

    it "renders production environment with white background" do
      render_inline(described_class.new(current_section: :dashboard, environment: :production))

      expect(page).to have_css("div[style*='background: #fff']")
    end

    it "renders active section text in white for colored environments" do
      render_inline(described_class.new(current_section: :dashboard, environment: :development))

      expect(page).to have_css("a[aria-current='page'][style*='color: #fff']", text: "Dashboard")
    end
  end

  context "with system_url" do
    it "renders gear icon when system_url is provided" do
      render_inline(described_class.new(current_section: :dashboard, system_url: "/admin/system"))

      expect(page).to have_css("a[href='/admin/system'][aria-label='System administration']")
      expect(page).to have_css("a[href='/admin/system'] svg")
    end

    it "does not render gear icon when system_url is nil" do
      render_inline(described_class.new(current_section: :dashboard))

      expect(page).not_to have_css("a[aria-label='System administration']")
    end
  end

  context "with user menu (sign out)" do
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

  context "with custom logo" do
    it "renders custom logo text" do
      render_inline(described_class.new(current_section: :dashboard, logo_text: "MY APP"))

      expect(page).to have_text("MY APP")
      expect(page).not_to have_text("MARKAZ")
    end

    it "renders custom logo href" do
      render_inline(described_class.new(current_section: :dashboard, logo_href: "/home"))

      expect(page).to have_css("a[href='/home'] span", text: "MARKAZ")
    end
  end
end
