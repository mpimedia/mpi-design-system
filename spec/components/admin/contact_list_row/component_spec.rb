# frozen_string_literal: true

require "spec_helper"

RSpec.describe Admin::ContactListRow::Component, type: :component do
  let(:default_params) do
    {
      name: "John Smith",
      title: "Theatrical Buyer",
      tags: [ { group: :buyers, role: "Buyer — Theatrical" } ],
      last_engagement: "2 days ago",
      account_name: "Sony Pictures",
      account_path: "/accounts/1"
    }
  end

  it "renders avatar with contact name" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("span.rounded-circle", text: "JS")
  end

  it "renders name in bold navy" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("div[style*='font-weight: 600'][style*='color: #1B2A4A']", text: "John Smith")
  end

  it "renders job title below name" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("div[style*='font-size: 12px'][style*='color: #6C757D']", text: "Theatrical Buyer")
  end

  it "renders tag dot with group color" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("span[style*='background: #E8733A']")
    expect(page).to have_text("Buyer — Theatrical")
  end

  it "renders last engagement in muted text" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("span[style*='color: #6C757D']", text: "2 days ago")
  end

  it "renders account as a blue link" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("a[href='/accounts/1'][style*='color: #2E75B6']", text: "Sony Pictures")
  end

  it "renders account as plain text when path is missing" do
    render_inline(described_class.new(**default_params.merge(account_path: nil)))

    expect(page).to have_css("span[style*='color: #2E75B6']", text: "Sony Pictures")
    expect(page).not_to have_css("a", text: "Sony Pictures")
  end

  it "renders multiple tags" do
    tags = [
      { group: :buyers, role: "Buyer — Theatrical" },
      { group: :press, role: "Press — Critic" }
    ]
    render_inline(described_class.new(**default_params.merge(tags: tags)))

    expect(page).to have_css("span[style*='background: #E8733A']")
    expect(page).to have_css("span[style*='background: #2DA67E']")
  end

  it "hides title when not provided" do
    render_inline(described_class.new(name: "John Smith"))

    expect(page).not_to have_css("div[style*='font-size: 12px'][style*='color: #6C757D']")
  end

  context "search_result variant" do
    let(:search_params) do
      {
        name: "Jane Doe",
        title: "Festival Director",
        tags: [ { group: :festivals, role: "Festival — Director" } ],
        variant: :search_result,
        match_text: "Title contains <strong>director</strong>",
        last_engagement: "1 week ago",
        status: :active
      }
    end

    it "renders match found in column with highlighted text" do
      render_inline(described_class.new(**search_params))

      expect(page).to have_css("strong", text: "director")
    end

    it "renders status with colored dot" do
      render_inline(described_class.new(**search_params))

      expect(page).to have_css("span[style*='background: #22A06B']")
      expect(page).to have_text("Active")
    end

    it "renders inactive status with gray dot" do
      render_inline(described_class.new(**search_params.merge(status: :inactive)))

      expect(page).to have_css("span[style*='background: #6C757D']")
      expect(page).to have_text("Inactive")
    end

    it "does not render account column in search variant" do
      render_inline(described_class.new(**search_params.merge(account_name: "Acme")))

      expect(page).not_to have_css("a", text: "Acme")
    end
  end
end
