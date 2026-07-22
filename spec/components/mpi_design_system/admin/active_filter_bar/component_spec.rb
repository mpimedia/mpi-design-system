# frozen_string_literal: true

require "spec_helper"

RSpec.describe MpiDesignSystem::Admin::ActiveFilterBar::Component, type: :component do
  let(:filters) do
    [
      { category: "Keyword", value: "investors", remove_url: "/contacts?remove=keyword" },
      { category: "Group", value: "Distribution", remove_url: "/contacts?remove=group" }
    ]
  end

  # Utilities that pin one colour scheme. Any of these on a bar meant to follow
  # `data-bs-theme` reintroduces exactly the defect #150 removed.
  let(:fixed_scheme_utilities) do
    %w[
      bg-white bg-black bg-light bg-dark
      text-white text-black text-light text-dark
      text-bg-light text-bg-dark
      border-white border-black border-light border-dark
    ]
  end

  # Matches 3-, 4-, 6- and 8-digit CSS hex. The trailing (?!\h) stops #abcdef1234
  # from matching as a 6-digit literal, and the 4/8 branches close the alpha forms.
  let(:hex_literal) { /#(?:\h{8}|\h{6}|\h{4}|\h{3})(?!\h)/ }

  # The pill carries Bootstrap's `.text-bg-primary`, so its background AND foreground
  # derive from the consuming app's actual $primary rather than a literal. (#130)
  it "renders active filter pills" do
    render_inline(described_class.new(filters: filters))

    expect(page).to have_css("span.rounded-pill.text-bg-primary", text: "Keyword: investors")
    expect(page).to have_css("span.rounded-pill.text-bg-primary", text: "Group: Distribution")
  end

  it "renders ACTIVE label" do
    render_inline(described_class.new(filters: filters))

    expect(page).to have_css("span[style*='text-transform: uppercase']", text: "Active:")
  end

  it "renders remove buttons for each filter" do
    render_inline(described_class.new(filters: filters))

    expect(page).to have_css("a[aria-label='Remove filter: Keyword: investors']")
    expect(page).to have_css("a[data-turbo-method='delete']", count: 2)
  end

  it "renders clear all link" do
    render_inline(described_class.new(filters: filters, clear_all_url: "/contacts?clear"))

    expect(page).to have_css("a[href='/contacts?clear']", text: "Clear all")
  end

  it "renders as a toolbar with aria label" do
    render_inline(described_class.new(filters: filters))

    expect(page).to have_css("div[role='toolbar'][aria-label='Active filters']")
  end

  # #150: the bar surface was a pinned light `#F5F7FA` scoped to `data-bs-theme="light"`.
  # It is now `.bg-body-secondary.rounded` — adaptive — so the theme pin is gone (it
  # would now BLOCK dark mode). `.rounded` == --bs-border-radius == 6px under this
  # engine's config, preserving the retired `border-radius: 6px`.
  it "renders the bar on the adaptive secondary body surface with no colour-mode pin" do
    render_inline(described_class.new(filters: filters))

    expect(page).to have_css("div.bg-body-secondary.rounded[role='toolbar']")
    expect(page).to have_no_css("div[style*='background']")
    expect(page).to have_no_css("[data-bs-theme]")
  end

  describe "contrast (#130) and theme-adaptivity (#150)" do
    it "derives the pill foreground from Bootstrap instead of pinning white" do
      render_inline(described_class.new(filters: filters))

      expect(page).to have_css("span.text-bg-primary")
      expect(page).to have_no_css("span[style*='color: #fff']")
      expect(page).to have_no_css("span[style*='background: #2E75B6']")
    end

    # The retired `opacity: 0.8` faded white to an effective #D5E3F0 over the pill —
    # 3.71:1, an AA failure invisible to any audit that only reads `color:`. The
    # button now inherits the pill's derived foreground at full strength.
    it "does not fade the remove button, which eroded contrast to 3.71:1" do
      render_inline(described_class.new(filters: filters))

      expect(page).to have_css("a[style*='color: inherit']", count: 2)
      expect(page).to have_no_css("a[style*='opacity']")
    end

    it "derives the label and clear-all foreground rather than pinning #6C757D" do
      render_inline(described_class.new(filters: filters, clear_all_url: "/contacts?clear"))

      expect(page).to have_css("span.text-body-secondary", text: "Active:")
      expect(page).to have_css("a.text-body-secondary", text: "Clear all")
      expect(page).to have_no_css("[style*='color: #6C757D']")
    end

    # The component now carries NO colour hex at all (surface, pill, label and remove
    # button are all Bootstrap utilities), so a single sweep over the whole rendered
    # document catches a hardcoded literal reintroduced anywhere in this template —
    # including markup this spec does not enumerate. The positive pin proves the
    # markup actually rendered, so the regex is not passing over an empty string.
    it "emits no literal hex anywhere in the rendered markup" do
      render_inline(described_class.new(filters: filters, clear_all_url: "/contacts?clear"))

      expect(page).to have_css("div.bg-body-secondary[role='toolbar']")
      expect(page).to have_css("span.text-bg-primary", text: "Keyword: investors")

      expect(rendered_content).not_to match(hex_literal)
    end

    it "pins no fixed-scheme utility that would break under data-bs-theme" do
      render_inline(described_class.new(filters: filters, clear_all_url: "/contacts?clear"))

      elements = page.all("div[role='toolbar'], div[role='toolbar'] *")
      expect(elements.size).to be > 1

      applied = elements.flat_map { |el| el[:class].to_s.split }.uniq
      expect(applied).to include("bg-body-secondary", "text-bg-primary", "text-body-secondary")
      expect(applied & fixed_scheme_utilities).to be_empty
    end
  end

  describe "edge cases" do
    it "renders nothing when filters are empty" do
      render_inline(described_class.new(filters: []))

      # show? is false, so the whole template is elided — assert the output itself
      # is empty rather than merely that the toolbar is absent (a positive check on
      # the rendered string, not a bare absence).
      expect(rendered_content.strip).to be_empty
    end

    it "renders nothing and does not raise when filters is nil" do
      output = nil
      expect { output = render_inline(described_class.new(filters: nil)) }.not_to raise_error
      expect(output.to_html.strip).to be_empty
    end

    it "renders a pill without a remove button when remove_url is missing" do
      render_inline(described_class.new(filters: [ { category: "Tag", value: "Acquisitions" } ]))

      expect(page).to have_css("span.text-bg-primary", text: "Tag: Acquisitions")
      expect(page).to have_no_css("a[data-turbo-method='delete']")
    end

    it "omits the clear-all link when no url is given" do
      render_inline(described_class.new(filters: filters))

      expect(page).to have_css("span.text-bg-primary", text: "Keyword: investors")
      expect(page).to have_no_css("a[aria-label='Clear all filters']")
    end
  end
end
