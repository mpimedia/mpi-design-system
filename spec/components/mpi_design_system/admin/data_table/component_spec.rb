# frozen_string_literal: true

require "spec_helper"

RSpec.describe MpiDesignSystem::Admin::DataTable::Component, type: :component do
  let(:columns) do
    [
      { key: :name, label: "Name", sortable: true },
      { key: :tags, label: "Tags" },
      { key: :last_engagement, label: "Last Engagement", sortable: true },
      { key: :account, label: "Account" }
    ]
  end

  let(:rows) do
    [
      {
        name: "John Smith",
        title: "Theatrical Buyer",
        name_href: "/contacts/1",
        tags: [ { label: "Acquisitions", group: :distribution } ],
        last_engagement: "2 days ago",
        account: "Sony Pictures",
        account_href: "/accounts/1"
      }
    ]
  end

  it "renders column headers in uppercase" do
    render_inline(described_class.new(columns: columns, rows: rows))

    expect(page).to have_css("th[style*='text-transform: uppercase']", text: "Name")
    expect(page).to have_css("th[style*='text-transform: uppercase']", text: "Tags")
  end

  # Header foreground derives from `text-body-secondary`; the 2px separator is the
  # `border-bottom` utility (colour via the adaptive `--bs-border-color`) widened by
  # an inline `--bs-border-width: 2px` on the bottom edge only. `border-2` would box
  # all four sides of a `.table th` — the browser spec proves the geometry. (#151)
  it "renders headers as muted cells with a 2px bottom border" do
    render_inline(described_class.new(columns: columns, rows: rows))

    expect(page).to have_css(
      "th.text-body-secondary.border-bottom[style*='--bs-border-width: 2px']",
      text: "Name"
    )
    expect(page).to have_css("th.text-body-secondary.border-bottom", count: 4)
  end

  it "vertically centres cells with the align-middle utility" do
    render_inline(described_class.new(columns: columns, rows: rows))

    expect(page).to have_css("td.align-middle", count: 4)
  end

  it "renders a row with avatar and name" do
    render_inline(described_class.new(columns: columns, rows: rows))

    expect(page).to have_css("span.rounded-circle", text: "JS")
    expect(page).to have_css("div.text-body[style*='font-weight: 600']", text: "John Smith")
  end

  it "renders name as a link when name_href is provided" do
    render_inline(described_class.new(columns: columns, rows: rows))

    # Adaptive body foreground via `text-body`, no underline — the retired inline
    # `color: inherit; text-decoration: none` is now the utility pair.
    expect(page).to have_css("a.text-body.text-decoration-none[href='/contacts/1']", text: "John Smith")
    expect(page).to have_no_css("a[href='/contacts/1'][style*='color']")
  end

  it "renders contact title below name in muted body text" do
    render_inline(described_class.new(columns: columns, rows: rows))

    expect(page).to have_css("div.text-body-secondary[style*='font-size: 12px']", text: "Theatrical Buyer")
  end

  # Looped over the whole mapping so a typo in GROUP_VARIANTS reddens. The table is
  # scoped to a single tags column, so the ONLY dot present is the tag dot — asserting
  # exactly one `d-inline-block` dot and that it carries `bg-#{variant}` means a bare
  # `bg-secondary` cannot silently match some other dot (testing.md, Codex P1).
  it "renders a tag dot in each group's semantic fill" do
    described_class::GROUP_VARIANTS.each do |group, variant|
      render_inline(described_class.new(
        columns: [ { key: :tags, label: "Tags" } ],
        rows: [ { tags: [ { label: group.to_s, group: group } ] } ]
      ))

      expect(page).to have_css("span.d-inline-block", count: 1)
      expect(page).to have_css("span.d-inline-block.bg-#{variant}", count: 1)
      expect(page).to have_css("span.text-body", text: group.to_s)
    end
  end

  it "falls back to a secondary tag dot for an unknown group" do
    render_inline(described_class.new(
      columns: [ { key: :tags, label: "Tags" } ],
      rows: [ { tags: [ { label: "Mystery", group: :nope } ] } ]
    ))

    expect(page).to have_css("span.d-inline-block", count: 1)
    expect(page).to have_css("span.d-inline-block.bg-secondary", count: 1)
    expect(page).to have_css("span.text-body", text: "Mystery")
  end

  it "renders the account as a default-colour link with its underline intact" do
    render_inline(described_class.new(columns: columns, rows: rows))

    expect(page).to have_css("a[href='/accounts/1']", text: "Sony Pictures")

    link = page.find("a[href='/accounts/1']")
    # No class at all -> no `text-*` colour class and no `text-decoration-none`: the
    # anchor paints Bootstrap's `--bs-link-color` and keeps its underline. Only the
    # geometry survives inline, so the exact style pins the absence of a colour too.
    # The browser spec proves the painted colour.
    expect(link[:class]).to be_nil
    expect(link[:style]).to eq("font-size: 13px;")
  end

  it "renders account as plain text when account_href is missing" do
    rows_no_href = [ { name: "Test User", account: "Acme Corp" } ]
    render_inline(described_class.new(columns: columns, rows: rows_no_href))

    expect(page).to have_css("span.text-body", text: "Acme Corp")
    expect(page).not_to have_css("a", text: "Acme Corp")
  end

  it "includes scope=col on header cells" do
    render_inline(described_class.new(columns: columns, rows: rows))

    expect(page).to have_css("th[scope='col']", count: 4)
  end

  it "renders sort indicator on sorted column" do
    render_inline(described_class.new(columns: columns, rows: rows, sort_by: :name, sort_dir: :asc))

    expect(page).to have_css("th[aria-sort='ascending']", text: /Name/)
  end

  it "renders descending sort indicator" do
    render_inline(described_class.new(columns: columns, rows: rows, sort_by: :name, sort_dir: :desc))

    expect(page).to have_css("th[aria-sort='descending']", text: /Name/)
  end

  it "uses table-hover class for row hover effect" do
    render_inline(described_class.new(columns: columns, rows: rows))

    expect(page).to have_css("table.table.table-hover")
  end

  it "renders an empty table body when rows are empty" do
    render_inline(described_class.new(columns: columns, rows: []))

    expect(page).to have_css("thead th", count: 4)
    expect(page).not_to have_css("tbody tr")
  end

  # Colour left these inline styles; geometry did not, and has no Bootstrap
  # equivalent. The theme-adaptivity guards below only assert ABSENCE, so without this
  # a wiped `*_styles` helper would ship green. Watched red by emptying each helper.
  it "keeps the non-colour geometry that has no Bootstrap equivalent" do
    render_inline(described_class.new(columns: columns, rows: rows))

    expect(page).to have_css(
      "th[style*='font-size: 11px'][style*='letter-spacing: 0.06em'][style*='--bs-border-width: 2px']",
      text: "Name"
    )
    expect(page).to have_css("div.text-body[style*='font-weight: 600'][style*='font-size: 14px']", text: "John Smith")
    expect(page).to have_css("span.d-inline-block[style*='width: 6px'][style*='height: 6px'][style*='border-radius: 50%']")
    # tag_text_styles and meta_text_styles each retain `font-size: 13px` inline (no
    # Bootstrap equivalent). Pin them POSITIVELY — the theme-adaptivity guards below only
    # assert ABSENCE, so without this, emptying either helper ships green. Watched red by
    # emptying each. (#151, FIX 5)
    expect(page).to have_css("span.text-body[style*='font-size: 13px']", text: "Acquisitions")
    expect(page).to have_css("span.text-body-secondary[style*='font-size: 13px']", text: "2 days ago")
  end

  describe "search results variant" do
    let(:search_columns) do
      [
        { key: :name, label: "Name" },
        { key: :tags, label: "Tags" },
        { key: :match_found_in, label: "Match Found In" },
        { key: :status, label: "Status" }
      ]
    end

    it "renders a keyword-highlighted match cell" do
      render_inline(described_class.new(
        columns: search_columns,
        rows: [ { name: "Jane Doe", match_found_in: "Title contains <strong>investor</strong>", status: "Active", status_key: :active } ],
        variant: :search_results
      ))

      expect(page).to have_css("td strong", text: "investor")
    end

    # Looped over the whole STATUS_VARIANTS mapping; the status-only table means the
    # single dot present is the status dot, so count + fill together prevent a stray
    # `bg-secondary` from matching the wrong element.
    it "renders a status dot in each status's semantic fill" do
      described_class::STATUS_VARIANTS.each do |status, variant|
        render_inline(described_class.new(
          columns: [ { key: :status, label: "Status" } ],
          rows: [ { status: status.to_s, status_key: status } ],
          variant: :search_results
        ))

        expect(page).to have_css("span.d-inline-block", count: 1)
        expect(page).to have_css("span.d-inline-block.bg-#{variant}", count: 1)
        expect(page).to have_css("span.text-body-secondary", text: status.to_s)
      end
    end

    it "falls back to a secondary status dot for an unknown status" do
      render_inline(described_class.new(
        columns: [ { key: :status, label: "Status" } ],
        rows: [ { status: "Weird", status_key: :nope } ],
        variant: :search_results
      ))

      expect(page).to have_css("span.d-inline-block", count: 1)
      expect(page).to have_css("span.d-inline-block.bg-secondary", count: 1)
    end

    # Unknown tag group AND unknown status in one row: both fall back to `secondary`.
    # Two dots total, both `bg-secondary` — asserting the count proves neither is some
    # other colour that merely happened to render.
    it "falls back to secondary for both an unknown group and an unknown status in one row" do
      render_inline(described_class.new(
        columns: [ { key: :tags, label: "Tags" }, { key: :status, label: "Status" } ],
        rows: [ { tags: [ { label: "Mystery", group: :nope } ], status: "Weird", status_key: :nope } ],
        variant: :search_results
      ))

      expect(page).to have_css("span.d-inline-block", count: 2)
      expect(page).to have_css("span.d-inline-block.bg-secondary", count: 2)
    end
  end

  # #151 moved every DataTable colour (header, name, title, tag/status dots, tag/meta
  # text, account link) onto Bootstrap semantic utilities so the table tracks
  # `data-bs-theme`. Each guard pins its subject POSITIVELY before asserting an
  # absence, and each was proven by watching it fail (testing.md, "A Guard Is Not Real
  # Until You Have Watched It Fail"). The 12-entry fixed-scheme list is the exact one
  # from pagination/component_spec.rb.
  describe "theme-adaptivity guards" do
    let(:fixed_scheme_utilities) do
      %w[
        bg-white bg-black bg-light bg-dark
        text-white text-black text-light text-dark
        border-white border-black border-light border-dark
      ]
    end

    let(:hex_literal) { /#(?:\h{8}|\h{6}|\h{4}|\h{3})(?!\h)/ }

    # A colour/border/opacity-bearing property, matched on the name to the LEFT of the
    # colon. `--bs-border-width` (custom-property prefix) and `border-radius` (radius is
    # not one of the side/attribute suffixes) fall OUTSIDE this pattern and stay allowed
    # geometry — so a re-introduced `border: 1px solid red` or `border: none` is caught
    # while the surviving `--bs-border-width: 2px` is not. (#151, FIX 3)
    let(:colour_or_border_prop) do
      /\A(color|background(-color)?|border(-(top|right|bottom|left|color|style|width))?|outline|box-shadow|opacity)\z/
    end

    # A colour literal in a declaration VALUE: hex, rgb()/hsl(), or a common named colour
    # as a whole word — so a hue smuggled into an allowed property's value is still caught.
    let(:colour_value_literal) do
      /#(?:\h{3,8})|\brgb|\bhsl|\b(?:red|green|blue|white|black|orange|yellow|purple|gr[ae]y)\b/i
    end

    # Every surviving inline "property: value" declaration that names a colour/border
    # property OR carries a colour literal in its value.
    def offending_style_declarations(fragment)
      fragment.css("[style]")
              .flat_map { |el| el["style"].to_s.split(";") }
              .map(&:strip).reject(&:empty?)
              .select do |decl|
        prop, value = decl.split(":", 2)
        prop.to_s.strip.downcase.match?(colour_or_border_prop) ||
          value.to_s.strip.downcase.match?(colour_value_literal)
      end
    end

    let(:populated) do
      described_class.new(
        variant: :search_results,
        columns: [
          { key: :name, label: "Name", sortable: true },
          { key: :tags, label: "Tags" },
          { key: :last_engagement, label: "Last Engagement" },
          { key: :account, label: "Account" },
          { key: :status, label: "Status" }
        ],
        rows: [ {
          name: "John Smith",
          title: "Theatrical Buyer",
          name_href: "/contacts/1",
          tags: [ { label: "Acquisitions", group: :distribution }, { label: "Journalist", group: :outreach } ],
          last_engagement: "2 days ago",
          account: "Sony Pictures",
          account_href: "/accounts/1",
          status: "Active",
          status_key: :active
        } ],
        sort_by: :name,
        sort_dir: :asc
      )
    end

    # DataTable embeds AvatarCircle, which still emits inline colour — since #169 as a
    # token reference with a hex fallback (`background-color: var(--mds-avatar-N, #22A06B)`),
    # so the strip is still required. Strip ONLY that subtree so the scan proves DataTable's
    # OWN markup carries no frozen colour, not the avatar's. AvatarCircle's default variant renders no dedicated class
    # (its root is `d-inline-flex align-items-center justify-content-center rounded-circle
    # fw-semibold`), so we pin its root by the `rounded-circle` + `justify-content-center`
    # pair — narrower than bare `.rounded-circle`, a generic Bootstrap utility a future
    # DataTable-owned element could reuse and thereby escape the scan (the FIX 4 defect).
    # If AvatarCircle's classes ever change so this stops matching, its inline hex leaks
    # INTO the scan and reddens the guard — a loud failure, not a silent over-strip.
    def datatable_without_avatars
      render_inline(populated)
      fragment = Nokogiri::HTML::DocumentFragment.parse(rendered_content)
      fragment.css(".rounded-circle.justify-content-center").remove
      fragment
    end

    it "emits no literal colour in its own markup (avatars excluded — a separate component)" do
      fragment = datatable_without_avatars

      # Prove an avatar WAS present (else the exclusion would be masking nothing), and
      # that the scanned fragment actually contains DataTable markup.
      expect(page).to have_css("span.rounded-circle", text: "JS")
      expect(fragment.at_css("th.border-bottom")).not_to be_nil
      expect(fragment.at_css("span.bg-danger")).not_to be_nil

      html = fragment.to_html
      expect(html).not_to match(hex_literal)
      expect(html).not_to include("rgb(")
      expect(html).not_to include("hsl(")
    end

    it "emits no colour, border, or opacity declaration in the inline styles that remain" do
      fragment = datatable_without_avatars

      # Inline styles DO still exist (geometry) — without this the assertion below would
      # pass on markup that emitted no style at all.
      expect(fragment.css("[style*='--bs-border-width']")).not_to be_empty

      # Only geometry may survive inline. Matching on the PROPERTY name catches a
      # re-introduced `border: 1px solid red` or `border: none` (named colour / keyword)
      # that a `[style*='color']` / `[style*='background']` substring scan let through;
      # `--bs-border-width` and `border-radius` remain allowed. Proven by mutation: a
      # `border: 1px solid red` injected into a style helper reddens this. (#151, FIX 3)
      expect(offending_style_declarations(fragment)).to eq([])
    end

    it "pins no fixed-scheme utility that would break under data-bs-theme" do
      render_inline(populated)

      # The table and every descendant, enumerated — including the avatar, whose
      # classes carry no fixed-scheme utility — rather than a [class*=…] substring hunt.
      elements = page.all("table, table *")
      expect(elements.size).to be > 1

      applied = elements.flat_map { |el| el[:class].to_s.split }.uniq
      expect(applied).to include(
        "text-body", "text-body-secondary", "border-bottom", "bg-danger", "bg-success"
      )
      expect(applied & fixed_scheme_utilities).to be_empty
    end
  end
end
