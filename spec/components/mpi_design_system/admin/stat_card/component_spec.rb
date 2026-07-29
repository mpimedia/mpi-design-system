# frozen_string_literal: true

require "spec_helper"

RSpec.describe MpiDesignSystem::Admin::StatCard::Component, type: :component do
  it "renders label and value" do
    render_inline(described_class.new(label: "Total Contacts", value: "2,307"))

    expect(page).to have_css("div[style*='text-transform: uppercase']", text: "Total Contacts")
    expect(page).to have_css("div[style*='font-size: 32px']", text: "2,307")
  end

  it "renders the card on the adaptive body surface with a border and lg radius" do
    render_inline(described_class.new(label: "Accounts", value: "418"))

    # `rounded-3` == --bs-border-radius-lg == 8px under this engine's config, so the
    # retired `border-radius: 8px` is preserved while becoming theme-adaptive.
    expect(page).to have_css("div.bg-body.border.rounded-3", text: "418")
  end

  it "colours the label with the secondary body token, not a pinned gray" do
    render_inline(described_class.new(label: "Accounts", value: "418"))

    expect(page).to have_css("div.text-body-secondary", text: "Accounts")
  end

  it "renders the value in the adaptive body colour by default" do
    render_inline(described_class.new(label: "Accounts", value: "418"))

    expect(page).to have_css("div.text-body", text: "418")
  end

  it "renders the value in danger red when alert is true" do
    render_inline(described_class.new(label: "Overdue Follow-Ups", value: "12", alert: true))

    # 32px value is large text (AA 3:1); base `.text-danger` clears it in both modes
    # while staying semantically red — so base danger is correct here, not -emphasis.
    expect(page).to have_css("div.text-danger", text: "12")
  end

  it "does not render the value in danger red when alert is false" do
    render_inline(described_class.new(label: "Accounts", value: "418"))

    expect(page).to have_css("div.text-body", text: "418")
    expect(page).to have_no_css("div.text-danger")
  end

  it "adds role=alert when alert is true" do
    render_inline(described_class.new(label: "Overdue", value: "5", alert: true))

    expect(page).to have_css("div.bg-body[role='alert']", text: "5")
  end

  it "omits role=alert when alert is false" do
    render_inline(described_class.new(label: "Accounts", value: "418"))

    expect(page).to have_css("div.bg-body", text: "418")
    expect(page).to have_no_css("[role='alert']")
  end

  describe "trend colour by sentiment" do
    # The `-emphasis` variants are a deliberate AA fix: the 12px trend is small text
    # (AA 4.5:1), where base `.text-success` (3.33:1 light) and `.text-danger`
    # (3.41:1 dark) both fail and do not follow the colour mode. Neutral uses the
    # secondary body token.
    expected = {
      positive: "text-success-emphasis",
      negative: "text-danger-emphasis",
      neutral: "text-body-secondary"
    }

    it "maps every sentiment the constant declares (an unmapped addition reddens here)" do
      expect(described_class::TREND_SENTIMENTS).to match_array(expected.keys)
    end

    described_class::TREND_SENTIMENTS.each do |sentiment|
      it "renders #{sentiment} trend text in .#{expected.fetch(sentiment)}" do
        render_inline(described_class.new(
          label: "Total", value: "100",
          trend_text: "34 this month", trend_sentiment: sentiment
        ))

        expect(page).to have_css("div.#{expected.fetch(sentiment)}", text: "34 this month")
      end
    end
  end

  describe "trend arrows" do
    it "renders an up arrow with an up direction" do
      render_inline(described_class.new(
        label: "Total", value: "100",
        trend_text: "34 this month", trend_direction: :up, trend_sentiment: :positive
      ))

      expect(page).to have_css("i.bi.bi-arrow-up[aria-hidden='true']")
    end

    it "renders a down arrow with a down direction" do
      render_inline(described_class.new(
        label: "Active", value: "50",
        trend_text: "5 this week", trend_direction: :down, trend_sentiment: :negative
      ))

      expect(page).to have_css("i.bi.bi-arrow-down[aria-hidden='true']")
    end

    it "renders no arrow with a neutral direction" do
      render_inline(described_class.new(
        label: "Accounts", value: "418",
        trend_text: "8 added this month", trend_direction: :neutral, trend_sentiment: :neutral
      ))

      expect(page).to have_css("div.text-body-secondary", text: "8 added this month")
      expect(page).to have_no_css("i.bi")
    end
  end

  it "hides the trend section when no trend_text is provided" do
    render_inline(described_class.new(label: "Total", value: "100"))

    # Pin the card positively so the absence below is not a false green on an
    # empty render.
    expect(page).to have_css("div.bg-body", text: "100")
    expect(page).to have_no_css("div[style*='font-size: 12px']")
  end

  describe "theme-adaptivity guards" do
    it "keeps the non-colour geometry that has no Bootstrap equivalent" do
      render_inline(described_class.new(
        label: "Total Contacts", value: "2,307",
        trend_text: "34 this month", trend_direction: :up, trend_sentiment: :positive
      ))

      # Colour left these declarations; size did not. Nothing else pins them — the
      # guards below only assert what must be ABSENT, so removing a style helper
      # outright would otherwise ship green.
      expect(page).to have_css("div.bg-body[style*='padding: 20px']")
      expect(page).to have_css("div[style*='text-transform: uppercase']", text: "Total Contacts")
      expect(page).to have_css(
        "div.text-body[style*='font-size: 32px'][style*='font-weight: 700']",
        text: "2,307"
      )
      expect(page).to have_css(
        "div.text-success-emphasis[style*='font-size: 12px']",
        text: "34 this month"
      )
    end

    it "emits no literal hex in any colour-bearing branch" do
      # A single render can show at most one value branch (alert is card-wide) and one
      # trend sentiment, so sweeping one render leaves the others unswept — a hex
      # re-introduced in an unrendered branch ships green. Sweep every colour-bearing
      # branch: the default value (.text-body), the alert value (.text-danger), and each
      # TREND_SENTIMENTS member (.text-success-emphasis / .text-danger-emphasis /
      # .text-body-secondary), driving the sentiment set off the constant so a new
      # sentiment is swept automatically.
      trend_class = {
        positive: "text-success-emphasis",
        negative: "text-danger-emphasis",
        neutral: "text-body-secondary"
      }

      branches = [
        { args: { label: "Accounts", value: "418" }, css: "div.text-body", text: "418" },
        { args: { label: "Overdue", value: "12", alert: true }, css: "div.text-danger", text: "12" }
      ]
      described_class::TREND_SENTIMENTS.each do |sentiment|
        branches << {
          args: { label: "Total", value: "100", trend_text: "34 this month", trend_sentiment: sentiment },
          css: "div.#{trend_class.fetch(sentiment)}", text: "34 this month"
        }
      end

      branches.each do |branch|
        render_inline(described_class.new(**branch[:args]))

        # Prove the branch actually rendered — a regex over an empty string passes forever.
        expect(page).to have_css(branch[:css], text: branch[:text])
        # Attributes and text included, so a hex in an `svg fill=` or a `data-*` is
        # caught too — neither is visible to a declaration scan.
        expect(rendered_fragment).to be_free_of_colour_literals,
          "colour literal leaked in branch #{branch[:args]}"
      end
    end

    it "emits no colour, background, or border declaration in the inline styles that remain" do
      render_inline(described_class.new(
        label: "Total", value: "100",
        trend_text: "34 this month", trend_direction: :up, trend_sentiment: :positive
      ))

      # Inline styles DO still exist (geometry) — without this the absences below
      # would pass on a component that emitted no style at all.
      expect(page).to have_css("div[style*='padding: 20px']")

      expect(page).to have_no_css("[style*='color']")
      expect(page).to have_no_css("[style*='background']")
      # Colon-anchored so it does not match a future `border-radius` inline (radius is
      # a class now, but the guard stays precise regardless).
      expect(page).to have_no_css("[style*='border: ']")

      # The substring assertions above cannot see a named colour, `opacity`, or
      # `box-shadow`; the shared declaration scan can. Kept alongside them rather than
      # replacing them, because they additionally forbid an inline `background-image`
      # this component has no business emitting.
      rendered_fragment.css("[style]").each do |node|
        expect(node["style"]).to be_free_of_frozen_colour
      end
    end

    # No `allowing:` — the non-alert branches take no fixed-hue exception at all.
    it "applies only theme-adaptive colour utilities outside the alert branch" do
      render_inline(described_class.new(
        label: "Total", value: "100",
        trend_text: "34 this month", trend_direction: :up, trend_sentiment: :positive
      ))
      fragment = rendered_fragment

      applied = ThemeAdaptivity.applied_utility_classes(fragment)
      expect(applied).to include("bg-body", "border", "rounded-3", "text-body-secondary", "text-body", "text-success-emphasis")

      expect(fragment).to be_free_of_fixed_hue_utilities
    end

    # The alert branch is the one place this card paints a base semantic foreground, and
    # it is deliberate — reasoned in component.rb:48-50,88. The alert VALUE is large text
    # (32px/600), so it is held to AA's 3:1 large-text floor rather than 4.5:1, which base
    # `.text-danger` clears in both modes (4.53:1 light) where `text-danger-emphasis` would
    # over-darken a number meant to read as an alarm. Asserted in its own example so the
    # exception is scoped to the branch that takes it, not to every StatCard render.
    it "applies a base text-danger on the alert value, and nothing else fixed-hue" do
      render_inline(described_class.new(label: "Overdue", value: "12", alert: true))
      fragment = rendered_fragment

      expect(fragment.at_css("div.text-danger")).not_to be_nil
      expect(ThemeAdaptivity.applied_utility_classes(fragment)).to include("bg-body", "text-body-secondary")

      expect(fragment).to be_free_of_fixed_hue_utilities.allowing("text-danger")
    end
  end

  describe "edge cases" do
    it "falls back to :neutral for an invalid trend_direction (no arrow)" do
      render_inline(described_class.new(
        label: "Total", value: "100",
        trend_text: "note", trend_direction: :sideways, trend_sentiment: :neutral
      ))

      expect(page).to have_css("div.text-body-secondary", text: "note")
      expect(page).to have_no_css("i.bi")
    end

    it "falls back to :neutral for an invalid trend_sentiment" do
      render_inline(described_class.new(
        label: "Total", value: "100",
        trend_text: "note", trend_sentiment: :fuchsia
      ))

      expect(page).to have_css("div.text-body-secondary", text: "note")
      expect(page).to have_no_css("div.text-success-emphasis")
      expect(page).to have_no_css("div.text-danger-emphasis")
    end

    it "renders no trend div when trend_text is nil" do
      render_inline(described_class.new(label: "Total", value: "100", trend_text: nil))

      expect(page).to have_css("div.bg-body", text: "100")
      expect(page).to have_no_css("div[style*='font-size: 12px']")
    end
  end
end
