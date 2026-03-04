# frozen_string_literal: true

require "spec_helper"

RSpec.describe Admin::EngagementCard::Component, type: :component do
  let(:default_params) do
    {
      engagement_type: :email,
      time: "10:42 AM",
      subject: "Follow-up on distribution deal",
      excerpt: "Hi team, just wanted to circle back on the theatrical rights...",
      contacts: [
        { name: "John Smith", path: "/contacts/1" },
        { name: "Jane Doe", path: "/contacts/2" }
      ],
      account_name: "Sony Pictures",
      account_path: "/accounts/1",
      tags: [ { group: :buyers, role: "Buyer — Theatrical" } ],
      creator_name: "M. Johnson"
    }
  end

  it "renders as an article element" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("article[style*='border-radius: 8px']")
  end

  it "renders email type badge with blue outline" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("span[style*='color: #2E75B6'][style*='border: 1.5px solid']", text: "EMAIL")
  end

  it "renders meeting type badge with purple outline" do
    render_inline(described_class.new(**default_params.merge(engagement_type: :meeting)))

    expect(page).to have_css("span[style*='color: #8B5CF6']", text: "MEETING")
  end

  it "renders call type badge with green outline" do
    render_inline(described_class.new(**default_params.merge(engagement_type: :call)))

    expect(page).to have_css("span[style*='color: #16A34A']", text: "CALL")
  end

  it "renders note type badge with orange outline" do
    render_inline(described_class.new(**default_params.merge(engagement_type: :note)))

    expect(page).to have_css("span[style*='color: #E8913A']", text: "NOTE")
  end

  it "renders type badge as outlined (transparent background)" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("span[style*='background: transparent']", text: "EMAIL")
  end

  it "renders time" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("span[style*='color: #6C757D']", text: "10:42 AM")
  end

  it "renders subject in bold navy" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("div[style*='font-weight: 600'][style*='color: #1B2A4A']", text: /Follow-up/)
  end

  it "renders excerpt in muted text" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("div[style*='color: #6C757D'][style*='font-size: 13px']", text: /circle back/)
  end

  it "renders contact chips with avatars" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("a[href='/contacts/1']", text: "John Smith")
    expect(page).to have_css("a[href='/contacts/2']", text: "Jane Doe")
    expect(page).to have_css("span.rounded-circle", text: "JS")
  end

  it "renders contact chips as plain spans when no path" do
    contacts = [ { name: "Test User" } ]
    render_inline(described_class.new(**default_params.merge(contacts: contacts)))

    expect(page).to have_css("span[style*='background: #F5F7FA']", text: "Test User")
    expect(page).not_to have_css("a", text: "Test User")
  end

  it "renders account link in right meta" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("a[href='/accounts/1'][style*='color: #2E75B6']", text: "Sony Pictures")
  end

  it "renders tags with colored dots in right meta" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("span[style*='background: #E8733A']")
    expect(page).to have_text("Buyer — Theatrical")
  end

  it "renders creator name" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("span[style*='color: #6C757D']", text: "by M. Johnson")
  end

  it "defaults invalid type to email" do
    render_inline(described_class.new(engagement_type: :invalid, subject: "Test"))

    expect(page).to have_css("span[style*='color: #2E75B6']", text: "EMAIL")
  end

  it "renders linked titles when provided" do
    titles = [ { name: "The Film", path: "/titles/1" } ]
    render_inline(described_class.new(**default_params.merge(linked_titles: titles)))

    expect(page).to have_css("a[href='/titles/1'][style*='color: #2E75B6']", text: "The Film")
  end

  it "hides right meta when no account, tags, or titles" do
    render_inline(described_class.new(
      engagement_type: :email, subject: "Test",
      account_name: nil, tags: [], linked_titles: []
    ))

    expect(page).not_to have_css("div[style*='min-width: 160px']")
  end
end
