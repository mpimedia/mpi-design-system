# frozen_string_literal: true

require "spec_helper"

RSpec.describe Admin::AccountDetailPanel::Component, type: :component do
  let(:default_params) do
    {
      name: "Sony Pictures",
      account_type: "Distributor",
      account_type_color: :primary,
      contacts: [
        { name: "Jane Doe", title: "VP of Acquisitions", path: "/contacts/1" },
        { name: "John Smith", title: "Director of Sales", path: "/contacts/2" }
      ],
      email: "info@sonypictures.com",
      phone: "+1 (555) 987-6543",
      location: "Los Angeles, CA",
      created_date: "Jan 10, 2025",
      owner: { name: "A. Garcia", path: "/users/3" }
    }
  end

  it "renders card with white background and rounded border" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("div[style*='background: #fff'][style*='border-radius: 8px']")
  end

  it "renders aria-label with account name" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("div[aria-label='Account details for Sony Pictures']")
  end

  it "renders 56px AvatarCircle with account name" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("span[style*='width: 56px']", text: "SP")
  end

  it "renders account name as h5" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("h5", text: "Sony Pictures")
  end

  it "renders account type badge" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("span.badge", text: "Distributor")
  end

  it "renders associated contacts section heading" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("div[style*='text-transform: uppercase']", text: "Associated Contacts")
  end

  it "renders contact names as links" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("a[href='/contacts/1']", text: "Jane Doe")
    expect(page).to have_css("a[href='/contacts/2']", text: "John Smith")
  end

  it "renders contact titles" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("div[style*='color: #6C757D']", text: "VP of Acquisitions")
    expect(page).to have_css("div[style*='color: #6C757D']", text: "Director of Sales")
  end

  it "renders small AvatarCircles for contacts" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("span[style*='width: 28px']", text: "JD")
    expect(page).to have_css("span[style*='width: 28px']", text: "JS")
  end

  it "renders contact rows with border separators" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("div[style*='border-bottom: 1px solid #F0F0F0']", minimum: 1)
  end

  it "renders contact info section heading" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("div[style*='text-transform: uppercase']", text: "Contact Info")
  end

  it "renders email as mailto link" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("a[href='mailto:info@sonypictures.com']", text: "info@sonypictures.com")
  end

  it "renders phone" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_text("+1 (555) 987-6543")
  end

  it "renders location" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_text("Los Angeles, CA")
  end

  it "renders created date" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_text("Jan 10, 2025")
  end

  it "renders owner as link" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("a[href='/users/3']", text: "A. Garcia")
  end

  it "renders owner label" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("div[style*='text-transform: uppercase']", text: "Owner")
  end

  it "renders hr dividers between sections" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("hr[style*='border-top: 1px solid #DEE2E6']", minimum: 2)
  end

  context "with no contacts" do
    it "does not render associated contacts section" do
      render_inline(described_class.new(name: "Sony Pictures"))

      expect(page).not_to have_text("Associated Contacts")
    end
  end

  context "with no contact info" do
    it "does not render contact info section" do
      render_inline(described_class.new(name: "Sony Pictures"))

      expect(page).not_to have_text("Contact Info")
    end
  end

  context "with no account type" do
    it "does not render badge" do
      render_inline(described_class.new(name: "Sony Pictures"))

      expect(page).not_to have_css("span.badge")
    end
  end

  it "defaults invalid account_type_color to primary" do
    render_inline(described_class.new(name: "Test", account_type: "Custom", account_type_color: :invalid))

    expect(page).to have_css("span.badge.bg-primary", text: "Custom")
  end
end
