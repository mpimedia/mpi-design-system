# frozen_string_literal: true

require "spec_helper"

RSpec.describe Admin::DataQualityPanel::Component, type: :component do
  let(:default_params) do
    {
      score: 62,
      tier: :good,
      fields_complete: 5,
      fields_total: 8,
      fields: [
        { name: "Name", complete: true, priority: :high, value: "John Smith" },
        { name: "Company", complete: true, priority: :high, value: "Sony Pictures" },
        { name: "Email", complete: true, priority: :high, value: "john@sony.com" },
        { name: "Phone", complete: false, priority: :med },
        { name: "Title", complete: true, priority: :med, value: "VP of Acquisitions" },
        { name: "Tags", complete: true, priority: :med, value: "Acquisitions" },
        { name: "Account", complete: false, priority: :low },
        { name: "Engagement History", complete: false, priority: :low }
      ]
    }
  end

  it "renders score ring with percentage" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("svg[aria-label='Data completeness: 62%']")
    expect(page).to have_css("text", text: "62%")
  end

  it "renders Data Completeness title" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("div[style*='font-weight: 600']", text: "Data Completeness")
  end

  it "renders fields complete count" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_text("5 of 8 fields complete")
  end

  it "renders grade badge with tier color" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("span[style*='color: #2E75B6'][style*='background: #EBF3FB']", text: "GOOD")
  end

  it "renders check icon for complete fields" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("i.bi.bi-check-circle-fill[style*='color: #22A06B']")
  end

  it "renders X icon for missing fields" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("i.bi.bi-x-circle-fill[style*='color: #DC3545']")
  end

  it "renders complete field names in navy" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("span[style*='color: #1B2A4A']", text: "Name")
  end

  it "renders missing field names in red" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("span[style*='color: #DC3545']", text: "Phone")
  end

  it "renders priority badges" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("span[style*='color: #DC3545']", text: "HIGH")
    expect(page).to have_css("span[style*='color: #D4772C']", text: "MED")
    expect(page).to have_css("span[style*='color: #64748B']", text: "LOW")
  end

  it "renders field values for complete fields" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_text("john@sony.com")
    expect(page).to have_text("VP of Acquisitions")
  end

  it "renders missing field rows with yellow background" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("div[style*='background: #FFFBEB']")
  end

  it "renders progress bar" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("div.progress")
    expect(page).to have_css("div.progress-bar[style*='width: 62.5%']")
  end

  it "renders progress bar with tier color" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("div.progress-bar[style*='background-color: #2E75B6']")
  end

  it "includes screen reader text for field status" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("span.visually-hidden", text: "Complete:")
    expect(page).to have_css("span.visually-hidden", text: "Missing:")
  end

  it "renders progress bar with ARIA attributes" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("div.progress-bar[aria-valuenow='5'][aria-valuemax='8']")
  end

  it "defaults invalid tier to poor" do
    render_inline(described_class.new(**default_params.merge(tier: :invalid)))

    expect(page).to have_css("span[style*='color: #DC3545']", text: "POOR")
  end

  it "clamps score to 0-100" do
    render_inline(described_class.new(**default_params.merge(score: -10)))

    expect(page).to have_css("text", text: "0%")
  end

  it "renders add action link for missing fields with add_url" do
    params = default_params.deep_dup
    params[:fields].find { |f| f[:name] == "Phone" }[:add_url] = "/contacts/1/edit?field=phone"
    render_inline(described_class.new(**params))

    expect(page).to have_css("a[href='/contacts/1/edit?field=phone']", text: "+ Add Phone")
  end

  it "does not render add action link for missing fields without add_url" do
    render_inline(described_class.new(**default_params))

    expect(page).not_to have_css("a", text: "+ Add Phone")
  end
end
