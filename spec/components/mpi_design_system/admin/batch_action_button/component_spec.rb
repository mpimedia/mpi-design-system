# frozen_string_literal: true

require "spec_helper"

RSpec.describe MpiDesignSystem::Admin::BatchActionButton::Component, type: :component do
  it "renders a submit button whose name is the action and text is the label" do
    render_inline(described_class.new(:archive, label: "Archive selected"))

    expect(page).to have_css("button[type='submit'][name='archive']", text: "Archive selected")
  end

  it "wires the action-button Stimulus target" do
    render_inline(described_class.new(:archive, label: "Archive selected"))

    expect(page).to have_css("button[data-mpi--batch-actions-target='actionButton']")
  end

  it "is disabled by default (fail-safe; the controller enables it on selection)" do
    render_inline(described_class.new(:archive, label: "Archive selected"))

    expect(page).to have_css("button[type='submit'][disabled]")
  end

  # ISS#183 follow-up: this is one of the five `btn-*`-emitting components the consolidation
  # left unguarded. The class axis is the only one that finds anything here — the component
  # emits no inline style and no colour literal at all, and both of those absences are pinned
  # below so that a future inline `style="background: #fff"` cannot slip in unnoticed.
  describe "theme-adaptivity guards" do
    let(:button) { described_class.new(:archive, label: "Archive selected") }

    # `btn-primary` is a DELIBERATE fixed hue, not an oversight. Bootstrap 5.3 defines
    # `.btn-primary` exactly once and never under a `[data-bs-theme=dark]` scope (verified in
    # `node_modules/bootstrap/dist/css/bootstrap.css`), so it paints `#2E75B6` in both colour
    # modes. That is the point: a primary action button is the brand affordance and is supposed
    # not to track the surface, exactly like the selected-state pills in
    # `.claude/rules/frontend.md`. It clears AA in both modes on the foreground Bootstrap
    # derives for it — `#fff` on `#2E75B6` = 4.843:1 (`MpiDesignSystem::ColorContrast.ratio`),
    # identical in both modes because neither value re-resolves.
    #
    # Only that one class is stripped, and the node stays in the scan — not `.allowing(…)`,
    # which is class-scoped rather than placement-scoped, and not `node.remove`, which would
    # also delete every other regression on the button and its subtree (#183 round 2).
    def without_brand_button_hue(fragment)
      buttons = fragment.css("button.btn")
      strip_sanctioned_hue(buttons, [ %w[btn-primary] ])
      expect(buttons.first["type"]).to eq("submit")
      fragment
    end

    it "applies only theme-adaptive colour utilities once the brand hue is stripped" do
      render_inline(button)

      expect(page).to have_css("button.btn.btn-primary", text: "Archive selected")

      expect(without_brand_button_hue(rendered_fragment)).to be_free_of_fixed_hue_utilities
    end

    it "emits no colour literal and no inline style at all" do
      render_inline(button)

      # Pin that the markup under scrutiny really rendered — a scan over an empty fragment
      # matches nothing and would pass forever (False Green #2).
      expect(page).to have_css("button[name='archive']", text: "Archive selected")

      expect(rendered_fragment).to be_free_of_colour_literals
      expect(rendered_fragment.css("[style]")).to be_empty
    end
  end
end
