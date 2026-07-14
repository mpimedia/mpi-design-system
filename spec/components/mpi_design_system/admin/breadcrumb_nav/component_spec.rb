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

  # Bootstrap's text-color utilities, enumerated deliberately. A `[class*='text-']` substring
  # match would be simpler but overreaches — it also rejects legitimate non-color utilities
  # (text-decoration-none, text-wrap, text-truncate), so it would block valid future changes.
  let(:bootstrap_text_color_classes) do
    %w[
      text-primary text-secondary text-success text-danger text-warning text-info
      text-light text-dark text-body text-muted text-white text-black
      text-body-secondary text-body-tertiary text-body-emphasis
      text-primary-emphasis text-secondary-emphasis text-success-emphasis
      text-danger-emphasis text-warning-emphasis text-info-emphasis
      text-light-emphasis text-dark-emphasis text-black-50 text-white-50
    ]
  end

  # Guards the deliberate absence in the template: these two elements must inherit the consumer's
  # --bs-link-color / --bs-body-color. A future `text-primary` here would silently re-pin the
  # palette and undo #124 while every other assertion in this file still passed.
  it "pins no color class on the elements that must inherit the consumer palette" do
    render_inline(described_class.new(**default_params))

    link_classes = page.find("a")[:class].split
    title_classes = page.find("span.fw-semibold")[:class].split

    expect(link_classes & bootstrap_text_color_classes).to be_empty
    expect(title_classes & bootstrap_text_color_classes).to be_empty
  end

  it "escapes HTML-special characters in the current title" do
    render_inline(described_class.new(**default_params.merge(current_title: "Tom & Jerry <script>")))

    expect(page).to have_css("span.fw-semibold", text: "Tom & Jerry <script>")
    expect(rendered_content).to include("Tom &amp; Jerry &lt;script&gt;")
  end
end
