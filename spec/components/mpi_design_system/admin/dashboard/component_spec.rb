# frozen_string_literal: true

require "spec_helper"

RSpec.describe MpiDesignSystem::Admin::Dashboard::Component, type: :component do
  let(:default_params) do
    {
      user_name: "Badie",
      greeting_time: :morning,
      current_date: "Tuesday, Feb 25"
    }
  end

  # ---- Independent expectation maps -------------------------------------------------
  # These MIRROR the component constants deliberately by hand. Building the expected
  # selector from `described_class::ACTIVITY_TYPES` instead would grade the implementation
  # against itself: a mutation to the constant would move BOTH sides and the example would
  # stay green (testing.md, Codex P1). Flipping `meeting: :secondary -> :danger` in the
  # component reddens the meeting example precisely because this map does not follow it.
  EXPECTED_ICON_VARIANT = {
    email: :primary, meeting: :secondary, new_contact: :success, call: :success, note: :warning
  }.freeze
  EXPECTED_ICON_GLYPH = {
    email: "bi-envelope-fill", meeting: "bi-camera-video-fill", new_contact: "bi-plus-circle-fill",
    call: "bi-telephone-fill", note: "bi-journal-text"
  }.freeze
  EXPECTED_FOLLOWUP_CLASS = {
    overdue: "text-danger-emphasis", due_today: "text-danger-emphasis",
    due_tomorrow: "text-warning-emphasis", future: "text-body-secondary"
  }.freeze

  # ---- Greeting / subtitle ----------------------------------------------------------

  it "renders morning greeting with user name in adaptive body text" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("h5.text-body", text: "Good morning, Badie")
  end

  it "renders afternoon greeting" do
    render_inline(described_class.new(**default_params.merge(greeting_time: :afternoon)))

    expect(page).to have_css("h5.text-body", text: "Good afternoon, Badie")
  end

  it "renders evening greeting" do
    render_inline(described_class.new(**default_params.merge(greeting_time: :evening)))

    expect(page).to have_css("h5.text-body", text: "Good evening, Badie")
  end

  it "falls back to morning for invalid greeting_time" do
    render_inline(described_class.new(**default_params.merge(greeting_time: :midnight)))

    expect(page).to have_text("Good morning, Badie")
  end

  it "renders subtitle with current date in secondary body text" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("div.text-body-secondary", text: "Here's your CRM snapshot for Tuesday, Feb 25")
  end

  it "does not render subtitle when current_date is nil" do
    render_inline(described_class.new(**default_params.merge(current_date: nil)))

    # Positive pin first, then the absence (testing.md False Green #2).
    expect(page).to have_css("h5.text-body", text: "Good morning, Badie")
    expect(page).not_to have_text("Here's your CRM snapshot")
  end

  # ---- Stat cards -------------------------------------------------------------------

  it "renders stat cards via slot" do
    card1_html = render_inline(MpiDesignSystem::Admin::StatCard::Component.new(label: "Total Contacts", value: "2,307")).to_html
    card2_html = render_inline(MpiDesignSystem::Admin::StatCard::Component.new(label: "Engagements This Week", value: "47")).to_html

    render_inline(described_class.new(**default_params)) do |dash|
      dash.with_stat_card { card1_html.html_safe }
      dash.with_stat_card { card2_html.html_safe }
    end

    expect(page).to have_text("Total Contacts")
    expect(page).to have_text("2,307")
    expect(page).to have_text("Engagements This Week")
    expect(page).to have_text("47")
  end

  it "renders stat cards in a 4-column grid" do
    render_inline(described_class.new(**default_params)) do |dash|
      dash.with_stat_card { "<div>Card</div>".html_safe }
    end

    expect(page).to have_css("div.row.g-3 div.col-md-6.col-lg-3")
  end

  # ---- Activity feed ----------------------------------------------------------------

  it "renders activity feed via data props" do
    params = default_params.merge(
      activities: [
        { type: :email, description: "Email logged to Sarah", timestamp: "2 hours ago" },
        { type: :meeting, description: "Meeting with Sony", timestamp: "4 hours ago" }
      ]
    )
    render_inline(described_class.new(**params))

    expect(page).to have_text("Recent Activity")
    expect(page).to have_text("Email logged to Sarah")
    expect(page).to have_text("Meeting with Sony")
  end

  # Independent-map loop: the icon chip is `bg-#{variant}-subtle text-#{variant}-emphasis`
  # (theme-adaptive, AA in both modes). Child combinator pins the classes to the icon div
  # itself (a direct child of the activity row), not a wrapper (testing.md, ISS#152).
  EXPECTED_ICON_VARIANT.each do |type, variant|
    it "renders the #{type} activity icon as #{variant}-subtle/emphasis" do
      render_inline(described_class.new(**default_params.merge(
        activities: [ { type: type, description: "x", timestamp: "now" } ]
      )))

      expect(page).to have_css(
        "div.d-flex.align-items-start > div.bg-#{variant}-subtle.text-#{variant}-emphasis"
      )
    end
  end

  # Glyph half of the same constant — a typo in `ACTIVITY_TYPES[:x][:icon]` reddens here.
  EXPECTED_ICON_GLYPH.each do |type, glyph|
    it "renders the #{type} activity icon glyph #{glyph}" do
      render_inline(described_class.new(**default_params.merge(
        activities: [ { type: type, description: "x", timestamp: "now" } ]
      )))

      expect(page).to have_css("div.bg-#{EXPECTED_ICON_VARIANT[type]}-subtle i.bi.#{glyph}")
    end
  end

  it "falls back to the email (primary) icon pair for an unknown activity type" do
    render_inline(described_class.new(**default_params.merge(
      activities: [ { type: :mystery, description: "x", timestamp: "now" } ]
    )))

    expect(page).to have_css("div.bg-primary-subtle.text-primary-emphasis i.bi.bi-envelope-fill")
  end

  it "exposes exactly the documented activity types" do
    expect(described_class::ACTIVITY_TYPES.keys).to contain_exactly(:email, :meeting, :new_contact, :call, :note)
  end

  it "renders activity timestamps in secondary body text" do
    render_inline(described_class.new(**default_params.merge(
      activities: [ { type: :email, description: "Test", timestamp: "3 hours ago" } ]
    )))

    expect(page).to have_css("div.text-body-secondary", text: "3 hours ago")
  end

  it "renders an activity contact link with no colour class (adaptive --bs-link-color, underline kept)" do
    render_inline(described_class.new(**default_params.merge(
      activities: [ {
        type: :email, description: "Email logged with",
        contact_name: "Sarah Chen", contact_path: "/contacts/1", timestamp: "2 hours ago"
      } ]
    )))

    # Positive pin first, then the class/style absence — the DataTable shape (#151).
    expect(page).to have_css("a[href='/contacts/1']", text: "Sarah Chen")
    link = page.find("a[href='/contacts/1']")
    expect(link[:class]).to be_nil
    expect(link[:style]).to eq("font-weight: 500;")
  end

  it "renders an activity account link with no colour class" do
    render_inline(described_class.new(**default_params.merge(
      activities: [ {
        type: :email, description: "Email logged",
        account_name: "Sony Pictures", account_path: "/accounts/1", timestamp: "now"
      } ]
    )))

    expect(page).to have_css("a[href='/accounts/1']", text: "Sony Pictures")
    link = page.find("a[href='/accounts/1']")
    expect(link[:class]).to be_nil
    expect(link[:style]).to eq("font-weight: 500;")
  end

  it "renders a plain contact name (no link) when contact_path is missing" do
    render_inline(described_class.new(**default_params.merge(
      activities: [ { type: :email, description: "Email", contact_name: "Jane Roe", timestamp: "now" } ]
    )))

    expect(page).to have_css("strong", text: "Jane Roe")
    expect(page).not_to have_css("a", text: "Jane Roe")
  end

  # ---- Quick actions ----------------------------------------------------------------

  it "renders quick actions with correct labels" do
    params = default_params.merge(
      quick_action_buttons: [
        { label: "Add new Contact", path: "/contacts/new", icon: "bi-plus-lg" },
        { label: "Add new Account", path: "/accounts/new", icon: "bi-plus-lg" },
        { label: "Add new Engagement", path: "/engagements/new", icon: "bi-plus-lg" }
      ]
    )
    render_inline(described_class.new(**params))

    expect(page).to have_text("Quick Actions")
    expect(page).to have_link("Add new Contact", href: "/contacts/new")
    expect(page).to have_link("Add new Account", href: "/accounts/new")
    expect(page).to have_link("Add new Engagement", href: "/engagements/new")
  end

  it "renders quick action buttons as adaptive outlined controls" do
    render_inline(described_class.new(**default_params.merge(
      quick_action_buttons: [ { label: "Add new Contact", path: "/contacts/new" } ]
    )))

    expect(page).to have_css("a.border.bg-body.text-body[href='/contacts/new']", text: "Add new Contact")
  end

  # ---- Follow-up queue --------------------------------------------------------------

  it "renders follow-up queue with statuses" do
    params = default_params.merge(
      followups: [
        { name: "Sarah Connor", description: "Follow-up with Sarah", status: :overdue, status_label: "7d overdue", avatar_name: "Sarah Connor" },
        { name: "John Smith", description: "Check in with John", status: :due_today, status_label: "Due today", avatar_name: "John Smith" }
      ],
      followup_count: 12,
      followup_path: "/followups"
    )
    render_inline(described_class.new(**params))

    expect(page).to have_text("Follow-up Queue")
    expect(page).to have_text("Follow-up with Sarah")
  end

  # Independent-map loop for follow-up status colours; a typo in FOLLOWUP_CLASSES reddens.
  EXPECTED_FOLLOWUP_CLASS.each do |status, klass|
    it "renders the #{status} follow-up status as .#{klass}" do
      render_inline(described_class.new(**default_params.merge(
        followups: [ { name: "T", description: "d", status: status, status_label: status.to_s, avatar_name: "T U" } ]
      )))

      expect(page).to have_css("div.#{klass}", text: status.to_s)
    end
  end

  it "falls back to the future (text-body-secondary) status for an unknown status" do
    render_inline(described_class.new(**default_params.merge(
      followups: [ { name: "T", description: "d", status: :mystery, status_label: "Someday", avatar_name: "T U" } ]
    )))

    expect(page).to have_css("div.text-body-secondary", text: "Someday")
  end

  it "exposes exactly the documented follow-up statuses" do
    expect(described_class::FOLLOWUP_CLASSES.keys).to contain_exactly(:overdue, :due_today, :due_tomorrow, :future)
  end

  it "renders a 'View all' link with no colour class (adaptive link colour, underline kept)" do
    render_inline(described_class.new(**default_params.merge(
      followups: [ { name: "T", description: "d", status: :overdue, status_label: "Overdue", avatar_name: "T U" } ],
      followup_count: 12, followup_path: "/followups"
    )))

    expect(page).to have_css("a[href='/followups']", text: "View all 12")
    link = page.find("a[href='/followups']")
    expect(link[:class]).to be_nil
    expect(link[:style]).to eq("font-size: 13px; font-weight: 500;")
  end

  it "renders follow-up avatars" do
    render_inline(described_class.new(**default_params.merge(
      followups: [ { name: "Sarah Connor", description: "Follow-up", status: :overdue, status_label: "Overdue", avatar_name: "Sarah Connor" } ]
    )))

    expect(page).to have_css("span.rounded-circle", text: "SC")
  end

  it "renders the follow-up name in adaptive body text" do
    render_inline(described_class.new(**default_params.merge(
      followups: [ { name: "Sarah Chen", description: "Follow-up task", status: :overdue, status_label: "7d overdue", avatar_name: "Sarah Chen" } ]
    )))

    expect(page).to have_css("div.text-body[style*='font-weight: 600']", text: "Sarah Chen")
  end

  # ---- Contacts by group chart ------------------------------------------------------

  it "renders contacts by group chart with a labelled role=img bar" do
    render_inline(described_class.new(**default_params.merge(
      group_data: [
        { label: "Distribution", count: 120, color: "#E8733A", percentage: 35.0 },
        { label: "Outreach", count: 85, color: "#2DA67E", percentage: 25.0 }
      ]
    )))

    expect(page).to have_text("Contacts by Group")
    expect(page).to have_css("div[role='img'][aria-label='Contacts by group distribution']")
  end

  it "renders the group chart legend with adaptive label and count text" do
    render_inline(described_class.new(**default_params.merge(
      group_data: [ { label: "Distribution", count: 120, color: "#E8733A", percentage: 35.0 } ]
    )))

    expect(page).to have_css("span.text-body-secondary", text: "Distribution")
    expect(page).to have_css("span.text-body", text: "120")
  end

  # ---- Widget chrome + layout -------------------------------------------------------

  it "renders each widget as a theme-adaptive card" do
    render_inline(described_class.new(**default_params.merge(
      activities: [ { type: :email, description: "x", timestamp: "now" } ],
      quick_action_buttons: [ { label: "Add", path: "#" } ]
    )))

    expect(page).to have_css("div.bg-body.border.rounded-3", count: 2)
    # Title placement differs by widget: Recent Activity's title sits inside a d-flex
    # header (a grandchild), so this is a descendant match; Quick Actions' title is a
    # DIRECT child of the card, so it gets a `>` child-combinator pin — the class cannot
    # drift onto a wrapper and still pass (ISS#152). Guard 1's exact-style `count: 4` pin
    # independently anchors the class to the styled element for every widget.
    expect(page).to have_css("div.bg-body.border.rounded-3 div.text-body", text: "Recent Activity")
    expect(page).to have_css("div.bg-body.border.rounded-3 > div.text-body", text: "Quick Actions")
  end

  it "renders two-column body layout" do
    render_inline(described_class.new(**default_params))

    expect(page).to have_css("div.row.g-4 div.col-lg-8")
    expect(page).to have_css("div.row.g-4 div.col-lg-4")
  end

  # ---- Slot overrides ---------------------------------------------------------------

  it "renders activity feed slot when provided" do
    render_inline(described_class.new(**default_params)) do |dash|
      dash.with_activity_feed { "<div id='custom-feed'>Custom Feed</div>".html_safe }
    end

    expect(page).to have_css("#custom-feed", text: "Custom Feed")
  end

  it "renders quick actions slot when provided" do
    render_inline(described_class.new(**default_params)) do |dash|
      dash.with_quick_actions { "<div id='custom-actions'>Custom Actions</div>".html_safe }
    end

    expect(page).to have_css("#custom-actions", text: "Custom Actions")
  end

  # ---- Empty collections ------------------------------------------------------------

  it "omits every built-in widget when all four collections are empty" do
    render_inline(described_class.new(user_name: "Zoe", greeting_time: :morning, current_date: "Wednesday, Mar 1"))

    # Positive pin first, then assert every built-in widget title is absent.
    expect(page).to have_css("h5.text-body", text: "Good morning, Zoe")
    expect(page).not_to have_text("Recent Activity")
    expect(page).not_to have_text("Contacts by Group")
    expect(page).not_to have_text("Quick Actions")
    expect(page).not_to have_text("Follow-up Queue")
  end

  # ---- Theme-adaptivity guards ------------------------------------------------------
  #
  # #153 moved every colour Dashboard SELECTS onto Bootstrap semantic utilities so the
  # layout tracks `data-bs-theme`. The one exception is the Contacts-by-Group chart's
  # CALLER-supplied `group_data[:color]`, a documented data-viz passthrough deferred to a
  # follow-up issue. Each guard pins its subject positively before asserting an absence and
  # was proven by watching it fail (testing.md, "A Guard Is Not Real Until You Have Watched
  # It Fail"). Guard shapes are copied from `data_table/component_spec.rb`.
  describe "theme-adaptivity guards" do
    AVATAR_ROOT = ".rounded-circle.justify-content-center"

    let(:group_colors) { %w[#E8733A #2DA67E #2E75B6] }
    let(:group_percentages) { [ 35.0, 25.0, 40.0 ] }

    let(:everything_followups) do
      [
        { name: "Sarah Chen", description: "d1", status: :overdue, status_label: "7d overdue", avatar_name: "Sarah Chen" },
        { name: "Marcus Johnson", description: "d2", status: :due_today, status_label: "Due today", avatar_name: "Marcus Johnson" },
        { name: "Emily Fox", description: "d3", status: :due_tomorrow, status_label: "Due tomorrow", avatar_name: "Emily Fox" },
        { name: "Robert Kim", description: "d4", status: :future, status_label: "In 3 days", avatar_name: "Robert Kim" }
      ]
    end

    let(:everything) do
      described_class.new(
        user_name: "Badie", greeting_time: :morning, current_date: "Tuesday, Feb 25",
        activities: [
          { type: :email, description: "Email logged with", contact_name: "Sarah Chen", contact_path: "/contacts/1", timestamp: "2h" },
          { type: :meeting, description: "Meeting", timestamp: "4h" },
          { type: :new_contact, description: "Added", timestamp: "6h" },
          { type: :call, description: "Call", timestamp: "1d" },
          { type: :note, description: "Note", timestamp: "2d" }
        ],
        followups: everything_followups,
        followup_count: 12, followup_path: "/followups",
        quick_action_buttons: [ { label: "Add new Contact", path: "/contacts/new", icon: "bi-plus-lg" } ],
        group_data: group_colors.each_with_index.map do |c, i|
          { label: "G#{i}", count: (i + 1) * 10, color: c, percentage: group_percentages[i] }
        end
      )
    end

    def dashboard_fragment
      render_inline(everything)
      Nokogiri::HTML::DocumentFragment.parse(rendered_content)
    end

    let(:hex_literal) { /#(?:\h{8}|\h{6}|\h{4}|\h{3})(?!\h)/ }

    # A paint-affecting property matched on the name left of the colon (`border-radius`, the
    # `--bs-*` custom-prop prefix, and `text-decoration` [shorthand, `none` here] fall outside,
    # staying allowed geometry). Broadened past the data_table original beyond
    # colour/background(-color)/border/outline/box-shadow/opacity to every paint property a
    # regression could smuggle a hue through — `background-image` (gradient), `text-shadow`,
    # `filter`/`backdrop-filter`, `fill`/`stroke`, `caret-color`, `accent-color`,
    # `text-decoration-color`, `text-emphasis-color`, `-webkit-text-fill-color` — because a
    # narrow list false-greens on `background-image: linear-gradient(rebeccapurple, …)` and the
    # like (Codex PR review, #173). Proven by mutation: a `background-image` gradient reddens
    # guard 2.
    let(:colour_or_border_prop) do
      /\A(color|background(-(color|image|blend-mode))?|border(-(top|right|bottom|left|color|style|width))?|
         outline|box-shadow|text-shadow|filter|backdrop-filter|fill|stroke|caret-color|accent-color|
         text-decoration-color|text-emphasis-color|-webkit-text-fill-color)\z/x
    end
    # Named colours are matched as whole words so a hue in an allowed property's VALUE is caught
    # even if its property name somehow is not; `rebeccapurple` is included alongside the CSS
    # basics (the property scan above already catches the paint properties, this is the net).
    let(:colour_value_literal) do
      /#(?:\h{3,8})|\brgb|\bhsl|\b(?:red|green|blue|white|black|orange|yellow|purple|rebeccapurple|gr[ae]y)\b/i
    end

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

    # GUARD 1 — exact-equality survivors. One complete `[style='…']` per converted element,
    # never `[style*=…]`: representative pins leave the rest deletable-green (ISS#152). Each
    # is proven by deleting one declaration from its helper and watching THIS example redden.
    it "keeps every surviving non-colour inline style of each converted element exactly" do
      render_inline(everything)

      # greeting
      expect(page).to have_css("h5.text-body[style='font-size: 20px; font-weight: 600;']", text: "Good morning, Badie")
      # subtitle
      expect(page).to have_css("div.text-body-secondary[style='font-size: 14px; margin-top: 4px;']", text: /CRM snapshot/)
      # widget chrome (4 widgets)
      expect(page).to have_css("div.bg-body.border.rounded-3[style='padding: 20px']", count: 4)
      # widget titles (4)
      expect(page).to have_css("div.text-body[style='font-weight: 600; font-size: 16px;']", count: 4)
      # activity icon geometry (5 activities)
      expect(page).to have_css(
        "div[style='width: 28px; height: 28px; border-radius: 50%; display: inline-flex; " \
        "align-items: center; justify-content: center; font-size: 13px; flex-shrink: 0']",
        count: 5
      )
      # activity text (scoped by text so it is distinct from follow-up desc, same style)
      expect(page).to have_css("div.text-body[style='font-size: 13px;']", text: "Meeting")
      # activity link (no class)
      expect(page).to have_css("a[style='font-weight: 500;']", text: "Sarah Chen")
      # activity timestamp (scoped by text so it is distinct from legend label, same style)
      expect(page).to have_css("div.text-body-secondary[style='font-size: 12px;']", text: "4h")
      # follow-up status
      expect(page).to have_css("div.text-danger-emphasis[style='font-size: 12px; font-weight: 600;']", text: "7d overdue")
      # follow-up name
      expect(page).to have_css("div.text-body[style='font-size: 13px; font-weight: 600;']", text: "Sarah Chen")
      # follow-up desc (scoped by text)
      expect(page).to have_css("div.text-body[style='font-size: 13px;']", text: "d3")
      # quick action
      expect(page).to have_css(
        "a.border.bg-body.text-body[style='padding: 10px 14px; border-radius: 6px; " \
        "text-decoration: none; display: block; font-size: 14px; font-weight: 500; text-align: left']",
        text: "Add new Contact"
      )
      # view all
      expect(page).to have_css("a[style='font-size: 13px; font-weight: 500;']", text: "View all 12")
      # legend label
      expect(page).to have_css("span.text-body-secondary[style='font-size: 12px;']", text: "G0")
      # legend count
      expect(page).to have_css("span.text-body[style='font-size: 12px; font-weight: 600;']", text: "10")
    end

    # Sanity for the strip used by guards 2 and 3: exactly one AvatarCircle root per
    # follow-up row, each an identity-checked avatar carrying its initials + geometry. If
    # AvatarCircle's classes ever change so the strip stops matching, its inline hex leaks
    # INTO guards 2/3 and reddens them — a loud failure, not a silent over-strip.
    it "strips exactly the follow-up AvatarCircle roots and nothing else" do
      fragment = dashboard_fragment
      avatars = fragment.css(AVATAR_ROOT)

      expect(avatars.length).to eq(everything_followups.length)
      expect(avatars.map { |a| a.text.strip }).to eq(%w[SC MJ EF RK])
      avatars.each { |a| expect(a["style"]).to include("width: 28px") }

      avatars.remove
      expect(fragment.css(AVATAR_ROOT)).to be_empty
    end

    # GUARD 2 — declaration scan. Renders EVERY built-in branch, strips the embedded
    # AvatarCircles (which legitimately still emit inline hex — ISS#169's territory), then
    # asserts the ONLY colour/border/opacity declarations left are the chart's caller
    # backgrounds: `2 * group_data.length` (each caller colour appears twice — bar segment
    # + legend dot). A re-introduced `border: 1px solid red` / `border: none` reddens this.
    it "emits no colour, border, or opacity declaration beyond the caller chart backgrounds" do
      fragment = dashboard_fragment
      fragment.css(AVATAR_ROOT).remove

      # Geometry inline styles DO still exist — without this the scan below could pass on
      # markup that emitted no style at all.
      expect(fragment.css("[style*='padding: 20px']")).not_to be_empty

      expected = group_colors.flat_map { |c| Array.new(2, "background: #{c}") }
      expect(offending_style_declarations(fragment).sort).to eq(expected.sort)
    end

    # GUARD 3 — caller-passthrough confinement. Every hex literal remaining in Dashboard's
    # OWN markup (avatars stripped) is exactly the caller's `group_data[:color]` set, each
    # appearing twice; and the segment/dot inline styles equal their expected strings. A new
    # hex anywhere else — or an ALLOWED chart hex reused in another declaration (the ISS#150
    # same-hex-elsewhere mode) — pushes the multiset off and reddens this.
    it "confines every hex literal to the caller group colours, each appearing twice" do
      fragment = dashboard_fragment

      # Prove an avatar was present, else the strip would be masking nothing.
      expect(fragment.css(AVATAR_ROOT).length).to eq(everything_followups.length)
      fragment.css(AVATAR_ROOT).remove

      expect(fragment.to_html.scan(hex_literal)).to contain_exactly(*group_colors.flat_map { |c| [ c, c ] })

      group_colors.each_with_index do |c, i|
        pct = group_percentages[i]
        expect(fragment.at_css("div[style='background: #{c}; width: #{pct}%; height: 100%;']")).not_to be_nil
        expect(fragment.at_css("div[style='width: 10px; height: 10px; border-radius: 50%; background: #{c}; flex-shrink: 0;']")).not_to be_nil
      end
    end

    # GUARD 4 — utility ALLOWLIST. Every colour-bearing class applied anywhere must be one
    # of the six adaptive utilities (bg-body, text-body, text-body-secondary, bare border,
    # bg-#{sem}-subtle, text-#{sem}-emphasis). An allowlist, not a denylist: bare
    # `text-primary` / `bg-success` / `text-bg-*` / `bg-white` are all fixed-hue or
    # fixed-scheme and must reject (a denylist misses the base utilities).
    # The CLASSIFIER also spans Bootstrap's other colour-bearing families — `btn-*`, `link-*`,
    # `alert-*`, `badge-*`, `list-group-item-*` — so a fixed-hue `btn-primary` / `link-danger` /
    # `alert-danger` regression is CLASSIFIED (and therefore rejected), not silently ignored by a
    # classifier that only saw `bg`/`text`/`border` (Codex PR review, #173). Proven by mutation:
    # a `btn-primary` on any Dashboard element reddens this.
    let(:colour_utility) { /\A(?:bg|text|border)(?:-|\z)|\A(?:btn|link|alert|badge|list-group-item)-/ }
    let(:colour_utility_allowlist) do
      %w[bg-body text-body text-body-secondary border] +
        %i[primary secondary success warning danger].flat_map { |s| [ "bg-#{s}-subtle", "text-#{s}-emphasis" ] }
    end

    it "applies only allowlisted colour utilities, no fixed-hue or fixed-scheme class" do
      fragment = dashboard_fragment
      applied = fragment.css("[class]").flat_map { |n| n["class"].to_s.split }.uniq
      colour_bearing = applied.select { |c| c.match?(colour_utility) }

      # Prove the adaptive utilities we expect are actually present, so the subset check
      # below is not vacuously green on an empty set.
      expect(colour_bearing).to include(
        "bg-body", "text-body", "text-body-secondary",
        "bg-primary-subtle", "text-primary-emphasis", "text-danger-emphasis"
      )
      expect(colour_bearing - colour_utility_allowlist).to eq([])
    end
  end
end
