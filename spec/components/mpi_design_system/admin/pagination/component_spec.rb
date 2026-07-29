# frozen_string_literal: true

require "spec_helper"

RSpec.describe MpiDesignSystem::Admin::Pagination::Component, type: :component do
  let(:url_builder) { ->(page) { "/contacts?page=#{page}" } }

  it "renders results text with correct range" do
    render_inline(described_class.new(current_page: 1, total_pages: 4, total_count: 93, url_builder: url_builder))

    expect(page).to have_text("Showing 1\u201325 of 93 results")
  end

  it "renders results text in the color-mode-aware primary emphasis token" do
    render_inline(described_class.new(current_page: 1, total_pages: 2, total_count: 50, url_builder: url_builder))

    # The text pins WHICH span is being asserted, so the class assertion cannot pass
    # against some other span that happens to carry the utility.
    expect(page).to have_css("span.text-primary-emphasis", text: "Showing 1–25 of 50 results")
  end

  it "renders page number buttons" do
    render_inline(described_class.new(current_page: 1, total_pages: 3, total_count: 75, url_builder: url_builder))

    expect(page).to have_css("[aria-label='Page 1']")
    expect(page).to have_css("[aria-label='Page 2']")
    expect(page).to have_css("[aria-label='Page 3']")
  end

  it "highlights the active page with the derived-foreground primary utility" do
    render_inline(described_class.new(current_page: 2, total_pages: 3, total_count: 75, url_builder: url_builder))

    expect(page).to have_css("span[aria-current='page'].text-bg-primary.border.border-primary.rounded", text: "2")
  end

  it "renders inactive pages on the adaptive body surface" do
    render_inline(described_class.new(current_page: 2, total_pages: 3, total_count: 75, url_builder: url_builder))

    expect(page).to have_css("a[aria-label='Page 1'].bg-body.text-body.border.rounded", text: "1")
    expect(page).to have_css("a[aria-label='Page 3'].bg-body.text-body.border.rounded", text: "3")
  end

  it "gives the arrows the same adaptive treatment as inactive pages" do
    render_inline(described_class.new(current_page: 2, total_pages: 3, total_count: 75, url_builder: url_builder))

    expect(page).to have_css("a[aria-label='Previous page'].bg-body.text-body.border.rounded")
    expect(page).to have_css("a[aria-label='Next page'].bg-body.text-body.border.rounded")
  end

  it "separates the bar with a border utility rather than a pinned rule" do
    render_inline(described_class.new(current_page: 1, total_pages: 3, total_count: 75, url_builder: url_builder))

    expect(page).to have_css("nav[aria-label='Pagination'].border-top")
  end

  it "keeps the gap marker on the secondary body token" do
    render_inline(described_class.new(current_page: 20, total_pages: 47, total_count: 1175, url_builder: url_builder, max_links: 7))

    expect(page).to have_css("span[aria-hidden='true'].text-body-secondary", text: "…")
  end

  it "keeps the non-colour geometry that has no Bootstrap equivalent" do
    render_inline(described_class.new(current_page: 20, total_pages: 47, total_count: 1175, url_builder: url_builder, max_links: 7))

    # Colour left these declarations; size did not. Nothing else pins them — the three
    # guards below only assert what must be ABSENT from the inline styles, so removing
    # a style helper outright would otherwise ship green with every example passing.
    expect(page).to have_css("nav[aria-label='Pagination'][style*='padding-top: 12px']")
    expect(page).to have_css(
      "span.text-primary-emphasis[style*='font-size: 13px']",
      text: "Showing 476–500 of 1175 results"
    )
    expect(page).to have_css(
      "span[aria-current='page'][style*='width: 32px'][style*='height: 32px'][style*='font-weight: 500']",
      text: "20"
    )
    expect(page).to have_css(
      "span[aria-hidden='true'][style*='width: 32px'][style*='height: 32px']",
      text: "…"
    )
  end

  it "does not show left arrow on first page" do
    render_inline(described_class.new(current_page: 1, total_pages: 3, total_count: 75, url_builder: url_builder))

    expect(page).not_to have_css("[aria-label='Previous page']")
    expect(page).to have_css("[aria-label='Next page']")
  end

  it "does not show right arrow on last page" do
    render_inline(described_class.new(current_page: 3, total_pages: 3, total_count: 75, url_builder: url_builder))

    expect(page).to have_css("[aria-label='Previous page']")
    expect(page).not_to have_css("[aria-label='Next page']")
  end

  it "shows both arrows on middle page" do
    render_inline(described_class.new(current_page: 2, total_pages: 3, total_count: 75, url_builder: url_builder))

    expect(page).to have_css("[aria-label='Previous page']")
    expect(page).to have_css("[aria-label='Next page']")
  end

  it "wraps in a nav element with aria-label" do
    render_inline(described_class.new(current_page: 1, total_pages: 1, total_count: 6, url_builder: url_builder))

    expect(page).to have_css("nav[aria-label='Pagination']")
  end

  it "handles last page with fewer records" do
    render_inline(described_class.new(current_page: 4, total_pages: 4, total_count: 93, url_builder: url_builder))

    expect(page).to have_text("Showing 76\u201393 of 93 results")
  end

  it "renders a single page without arrows" do
    render_inline(described_class.new(current_page: 1, total_pages: 1, total_count: 6, url_builder: url_builder))

    expect(page).not_to have_css("[aria-label='Previous page']")
    expect(page).not_to have_css("[aria-label='Next page']")
    expect(page).to have_text("Showing 1\u20136 of 6 results")
  end

  it "handles zero results" do
    render_inline(described_class.new(current_page: 1, total_pages: 1, total_count: 0, url_builder: url_builder))

    expect(page).to have_text("Showing 0 results")
  end

  it "clamps current_page to valid range" do
    render_inline(described_class.new(current_page: 99, total_pages: 3, total_count: 75, url_builder: url_builder))

    expect(page).to have_css("span[aria-current='page']", text: "3")
    expect(page).not_to have_css("[aria-label='Next page']")
  end

  it "does not render empty turbo frame attribute when not provided" do
    render_inline(described_class.new(current_page: 1, total_pages: 3, total_count: 75, url_builder: url_builder))

    expect(page).not_to have_css("[data-turbo-frame='']")
  end

  it "includes turbo frame data attribute when provided" do
    render_inline(described_class.new(
      current_page: 1, total_pages: 3, total_count: 75,
      url_builder: url_builder, turbo_frame: "contacts_list"
    ))

    expect(page).to have_css("a[data-turbo-frame='contacts_list']")
  end

  # The three guards that hold the #149 conversion in place. Each pins the element it is
  # talking about POSITIVELY before asserting an absence, and each was proven by watching
  # it fail against a mutation that trips it and neither of the other two
  # (`.claude/rules/testing.md`, "A Guard Is Not Real Until You Have Watched It Fail").
  #
  # #183 replaced this block's local hex regex and 12-entry fixed-scheme denylist with the
  # shared guard in `spec/support/theme_adaptivity.rb`. The denylist becomes an ALLOWLIST,
  # which is a strengthening: it named neither the base semantic utilities
  # (`text-primary`, `bg-success`) nor `btn-*` / `link-*` / `alert-*`, so all of those
  # shipped green.
  describe "theme-adaptivity guards" do
    let(:windowed) do
      described_class.new(current_page: 20, total_pages: 47, total_count: 1175, url_builder: url_builder, max_links: 7)
    end

    it "emits no literal hex anywhere in the markup" do
      render_inline(windowed)

      # Prove the markup under scrutiny actually rendered — a regex over an empty
      # string matches nothing and would pass forever.
      expect(page).to have_css("nav[aria-label='Pagination']")
      expect(page).to have_css("span[aria-current='page']", text: "20")

      # Attributes and text included, so a hex in an `svg fill=` or a `data-*` is caught
      # too — neither is visible to the declaration scan below.
      expect(rendered_fragment).to be_free_of_colour_literals
    end

    it "emits no colour declaration in the inline styles that remain" do
      render_inline(windowed)

      # Inline styles DO still exist (geometry) — without this the absence
      # assertions below would pass on a component that emitted no style at all.
      expect(page).to have_css("span[aria-current='page'][style*='width: 32px']")

      expect(page).to have_no_css("[style*='color']")
      expect(page).to have_no_css("[style*='background']")
      expect(page).to have_no_css("[style*='border']")

      # The substring assertions above cannot see `border: none` or a named colour on a
      # property they do not spell out; the shared declaration scan can. Kept alongside
      # them rather than replacing them, because they additionally forbid an inline
      # `border-radius` this component has no business emitting.
      rendered_fragment.css("[style]").each do |node|
        expect(node["style"]).to be_free_of_frozen_colour
      end
    end

    it "applies only theme-adaptive colour utilities, bar the selected-page affordance" do
      render_inline(windowed)
      fragment = rendered_fragment.css("nav[aria-label='Pagination']")

      # Scope is the nav and every descendant, enumerated — not a [class*=…]
      # substring hunt, which would match `border-primary` for `border-dark`.
      applied = ThemeAdaptivity.applied_utility_classes(fragment)
      expect(applied).to include("text-bg-primary", "bg-body", "text-primary-emphasis")

      # `text-bg-primary` + `border-primary` on the CURRENT page (component.rb:67) is a
      # deliberate fixed hue: the filled pill IS the selected-state affordance, and
      # `.claude/rules/frontend.md` records that as an accepted exception (#fff on
      # #2E75B6 = 4.843:1, identical in both colour modes because neither value
      # re-resolves). `border-primary` is the same hue on the same element, drawing the
      # pill's edge; allowing one without the other would pass a pill whose fill went
      # adaptive while its border stayed frozen. Every other colour-bearing class in the
      # nav must still be adaptive, which the same call asserts.
      expect(fragment).to be_free_of_fixed_hue_utilities.allowing("text-bg-primary", "border-primary")
    end
  end

  describe "windowing (max_links)" do
    # The ordered sequence of rendered page items: numeric page labels in document order,
    # with :gap for each non-interactive ellipsis. Excludes the prev/next arrows (their
    # aria-labels are "Previous page" / "Next page", not "Page N").
    def rendered_series
      page.all("[aria-label^='Page '], span[aria-hidden='true']").map do |el|
        el["aria-hidden"] == "true" ? :gap : el.text.strip
      end
    end

    it "renders every page (no gap) when max_links is nil — unchanged default" do
      render_inline(described_class.new(current_page: 3, total_pages: 6, total_count: 150, url_builder: url_builder, max_links: nil))

      expect(rendered_series).to eq(%w[1 2 3 4 5 6])
      expect(page).not_to have_css("span[aria-hidden='true']")
    end

    it "renders every page when total_pages <= max_links" do
      render_inline(described_class.new(current_page: 2, total_pages: 5, total_count: 120, url_builder: url_builder, max_links: 7))

      expect(rendered_series).to eq(%w[1 2 3 4 5])
      expect(page).not_to have_css("span[aria-hidden='true']")
    end

    it "clamps a below-minimum max_links (0/negative) to a five-slot window, not show-all" do
      render_inline(described_class.new(current_page: 20, total_pages: 47, total_count: 1175, url_builder: url_builder, max_links: 0))

      expect(rendered_series).to eq([ "1", :gap, "20", :gap, "47" ])
    end

    it "windows a middle page symmetrically with gaps on both sides" do
      render_inline(described_class.new(current_page: 20, total_pages: 47, total_count: 1175, url_builder: url_builder, max_links: 7))

      expect(rendered_series).to eq([ "1", :gap, "19", "20", "21", :gap, "47" ])
    end

    it "windows a near-first page with a single trailing gap" do
      render_inline(described_class.new(current_page: 2, total_pages: 47, total_count: 1175, url_builder: url_builder, max_links: 7))

      expect(rendered_series).to eq([ "1", "2", "3", "4", "5", :gap, "47" ])
    end

    it "windows a near-last page with a single leading gap" do
      render_inline(described_class.new(current_page: 46, total_pages: 47, total_count: 1175, url_builder: url_builder, max_links: 7))

      expect(rendered_series).to eq([ "1", :gap, "43", "44", "45", "46", "47" ])
    end

    it "keeps first and last present and truncates the interior (deep-table regression guard)" do
      render_inline(described_class.new(current_page: 20, total_pages: 47, total_count: 1175, url_builder: url_builder, max_links: 7))

      expect(page).to have_css("[aria-label='Page 1']")
      expect(page).to have_css("[aria-label='Page 47']")
      expect(page).to have_css("span[aria-current='page']", text: "20")
      # interior pages far from the window are NOT rendered — the whole point of windowing
      expect(page).not_to have_css("[aria-label='Page 5']")
      expect(page).not_to have_css("[aria-label='Page 35']")
    end

    it "renders the gap as a non-interactive ellipsis (no href)" do
      render_inline(described_class.new(current_page: 20, total_pages: 47, total_count: 1175, url_builder: url_builder, max_links: 7))

      gap = page.first("span[aria-hidden='true']")
      expect(gap.text.strip).to eq("…")
      expect(page).not_to have_css("a[aria-hidden='true']")
    end
  end
end
