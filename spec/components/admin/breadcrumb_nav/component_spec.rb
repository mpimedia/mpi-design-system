# frozen_string_literal: true

require "spec_helper"

RSpec.describe Admin::BreadcrumbNav::Component, type: :component do
  let(:default_params) do
    {
      back_path: "/crm/engagements",
      back_label: "Engagements",
      current_title: "Email: Follow-up on screening"
    }
  end

  it "renders a nav element with breadcrumb aria-label" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("nav[aria-label='Breadcrumb']")
  end

  it "renders back link with arrow icon and label" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("a[href='/crm/engagements']", text: "Engagements")
    expect(page).to have_css("a svg")
  end

  it "renders back link with accessible label" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("a[aria-label='Back to Engagements']")
  end

  it "renders separator between back link and title" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("span[aria-hidden='true']", text: "/")
  end

  it "renders current page title in bold navy" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("span[style*='color: #1B2A4A'][style*='font-weight: 600']",
                             text: "Email: Follow-up on screening")
  end

  it "renders back link in primary blue" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("a[style*='color: #2E75B6']")
  end
end
