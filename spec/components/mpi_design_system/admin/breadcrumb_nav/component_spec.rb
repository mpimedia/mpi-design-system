# frozen_string_literal: true

require "spec_helper"

RSpec.describe MpiDesignSystem::Admin::BreadcrumbNav::Component, type: :component do
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

  it "renders the current page title as class-based semibold text" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("span.fw-semibold", text: "Email: Follow-up on screening")
  end

  it "marks the current page title with aria-current" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("span[aria-current='page']", text: "Email: Follow-up on screening")
  end

  it "renders a class-based container" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("nav.d-flex.align-items-center.gap-2.py-2.small")
  end

  it "renders a class-based back link" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("a.d-inline-flex.align-items-center.gap-1.fw-medium.text-decoration-none")
  end

  it "renders a class-based separator" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("span.small.text-body-secondary", text: "/")
  end

  # The whole point of #124: no inline styling and no hardcoded palette survives anywhere.
  # The hex guard is deliberately broader than the [style] guard — it catches a literal
  # leaking back in through any attribute (fill, stroke, a data-*), not just style=.
  it "renders with no inline styles and no literal hex anywhere" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_no_css("[style]")
    expect(rendered_content).not_to match(/#[0-9A-Fa-f]{6}\b/)
  end

  # Guards the deliberate absence in the template: these elements must inherit the consumer's
  # --bs-link-color / --bs-body-color. A future `text-primary` here would silently re-pin the
  # palette and undo #124 while every other assertion above still passed.
  it "pins no color class on the elements that must inherit the consumer palette" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_no_css("a[class*='text-primary'], a[class*='text-body']")
    expect(page).to have_no_css("span.fw-semibold[class*='text-']")
  end

  it "escapes HTML-special characters in the current title" do
    render_inline(described_class.new(**default_params.merge(current_title: "Tom & Jerry <script>")))

    expect(page).to have_css("span.fw-semibold", text: "Tom & Jerry <script>")
    expect(rendered_content).to include("Tom &amp; Jerry &lt;script&gt;")
  end
end
