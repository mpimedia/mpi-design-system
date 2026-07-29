# frozen_string_literal: true

require "spec_helper"

RSpec.describe MpiDesignSystem::Admin::SearchBar::Component, type: :component do
  it "renders a search form with icon and input" do
    render_inline(described_class.new)

    expect(page).to have_css("form[role='search']")
    expect(page).to have_css("i.bi.bi-search")
    expect(page).to have_css("input[type='search'][placeholder='Search...']")
  end

  # The search-icon prepend must follow Bootstrap's colour mode: it was a hardcoded
  # `bg-white` patch that stayed white inside a dark navbar. `bg-body` adapts to
  # data-bs-theme. Pin the element first, then assert the retired class is gone —
  # an unpaired `not_to` would also pass if nothing rendered. (#154)
  it "renders the search-icon prepend on the adaptive body surface, not a white patch" do
    render_inline(described_class.new)

    expect(page).to have_css("span.input-group-text.bg-body i.bi.bi-search")
    expect(page).not_to have_css("span.input-group-text.bg-white")
  end

  it "renders with custom placeholder" do
    render_inline(described_class.new(placeholder: "Search contacts..."))

    expect(page).to have_css("input[placeholder='Search contacts...']")
  end

  it "renders with a value and clear link" do
    render_inline(described_class.new(value: "John", url: "/contacts"))

    expect(page).to have_css("input[value='John']")
    expect(page).to have_css("a[aria-label='Clear search']")
  end

  it "does not show clear link when empty" do
    render_inline(described_class.new)

    expect(page).not_to have_css("a[aria-label='Clear search']")
  end

  it "renders with search button" do
    render_inline(described_class.new(show_button: true))

    expect(page).to have_css("button.btn.btn-primary", text: "Search")
  end

  it "renders at large size" do
    render_inline(described_class.new(size: :lg))

    expect(page).to have_css("input.form-control.form-control-lg")
  end

  it "includes aria-label on the input" do
    render_inline(described_class.new)

    expect(page).to have_css("input[aria-label='Search']")
  end

  it "sets the form action URL" do
    render_inline(described_class.new(url: "/contacts/search"))

    expect(page).to have_css("form[action='/contacts/search']")
  end

  it "renders export button when show_export is true" do
    render_inline(described_class.new(show_export: true, export_url: "/contacts/export"))

    expect(page).to have_css("a.btn.btn-outline-secondary", text: "Export")
    expect(page).to have_css("a[href='/contacts/export']")
    expect(page).to have_css("i.bi.bi-download")
  end

  it "does not render export button by default" do
    render_inline(described_class.new)

    expect(page).not_to have_css("a", text: "Export")
  end

  it "renders export button with correct href" do
    render_inline(described_class.new(show_export: true, export_url: "/reports/download"))

    expect(page).to have_css("a[href='/reports/download']", text: "Export")
  end

  # ISS#183 follow-up: one of the five `btn-*`-emitting components the consolidation left
  # unguarded. All three buttons here are CONDITIONAL, which is the trap worth naming — the
  # default render emits no `btn-*` at all, so a guard that exercised only `new` would have
  # been green while proving nothing about the classes this component actually ships.
  describe "theme-adaptivity guards" do
    # Every button turned on at once, so one render covers all three sanctioned classes.
    let(:fully_loaded) do
      described_class.new(value: "acme", url: "/contacts", show_button: true,
                          show_export: true, export_url: "/reports/download")
    end

    # `btn-primary` on the submit button is a deliberate fixed hue (the brand affordance;
    # #fff on #2E75B6 = 4.843:1, identical in both modes because neither value re-resolves).
    #
    # `btn-outline-secondary` on the clear and export controls is the variant ISS#183's
    # guard work found failing AA — as Bootstrap ships it the resting text stays #6C757D
    # against a flipping surface (4.689 light, 3.290 dark). It is adaptive here only
    # because `app/assets/stylesheets/mpi_design_system/_buttons.scss` re-points
    # `--bs-btn-color` at `--bs-secondary-text-emphasis` (#2B2F32 / #A7ACB1, 13.502 and
    # 6.743). That adaptivity is conditional on the consumer importing the partial, which
    # the shared allowlist deliberately does not encode — hence a local strip rather than a
    # widened `ADAPTIVE_UTILITIES`. Painted values proven per mode in
    # spec/features/outline_button_theme_spec.rb.
    #
    # One entry PER NODE in document order, so the list's length IS the expected count:
    # clear (outline), submit (primary), export (outline). An over- or under-strip reddens.
    def without_button_hues(fragment)
      buttons = fragment.css(".btn")
      strip_sanctioned_hue(buttons, [
        %w[btn-outline-secondary], %w[btn-primary], %w[btn-outline-secondary]
      ])
      fragment
    end

    it "applies only theme-adaptive colour utilities once the button hues are stripped" do
      render_inline(fully_loaded)

      # Pin all three really rendered — the strip's count would otherwise be the only
      # thing asserting they exist, and a missing button would just shift the list.
      expect(page).to have_css("a.btn.btn-outline-secondary[aria-label='Clear search']")
      expect(page).to have_css("button.btn.btn-primary[type='submit']", text: "Search")
      expect(page).to have_css("a.btn.btn-outline-secondary[href='/reports/download']", text: "Export")

      expect(without_button_hues(rendered_fragment)).to be_free_of_fixed_hue_utilities
    end

    it "keeps the input-group surface on the adaptive bg-body token" do
      render_inline(fully_loaded)

      # `bg-body` is tier-2 adaptive, so it survives the scan above rather than being
      # stripped. Pinned explicitly so a swap to a fixed `bg-white` reddens HERE with a
      # clear reason as well as in the scan.
      expect(page).to have_css("span.input-group-text.bg-body")
    end

    it "emits no colour literal and no inline style, in the default render or fully loaded" do
      [ described_class.new, fully_loaded ].each do |component|
        render_inline(component)

        expect(page).to have_css("form[role='search'] input[type='search']")
        expect(rendered_fragment).to be_free_of_colour_literals
        expect(rendered_fragment.css("[style]")).to be_empty
      end
    end

    # The default render is the one a naive guard would have used. Pinning that it emits
    # NO `btn-*` at all is what makes the conditional coverage above meaningful rather
    # than incidental.
    it "emits no button classes at all in the default render" do
      render_inline(described_class.new)

      expect(page).to have_css("form[role='search']")
      expect(page).to have_no_css(".btn")
      expect(rendered_fragment).to be_free_of_fixed_hue_utilities
    end
  end
end
