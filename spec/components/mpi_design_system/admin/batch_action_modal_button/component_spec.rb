# frozen_string_literal: true

require "spec_helper"

RSpec.describe MpiDesignSystem::Admin::BatchActionModalButton::Component, type: :component do
  it "renders a trigger whose data-bs-target matches its own modal id" do
    render_inline(described_class.new(:assign, label: "Assign")) { "Body fields" }

    trigger = page.find("button[type='button'][data-bs-toggle='modal']")
    modal_id = trigger["data-bs-target"].delete_prefix("#")

    expect(modal_id).to be_present
    expect(page).to have_css("##{modal_id}.modal.fade")
    expect(page).to have_css("button[data-mpi--batch-actions-target='actionButton']", text: "Assign")
  end

  it "gives the dialog an accessible name via aria-labelledby -> the modal-title id" do
    render_inline(described_class.new(:assign, label: "Assign")) { "Body fields" }

    modal = page.find(".modal")
    title_id = modal["aria-labelledby"]

    expect(title_id).to be_present
    expect(page).to have_css("h5.modal-title##{title_id}", text: "Assign")
  end

  it "generates a unique modal id per instance so two tables can expose the same action" do
    render_inline(described_class.new(:assign, label: "Assign")) { "A" }
    first_id = page.find(".modal")["id"]

    render_inline(described_class.new(:assign, label: "Assign")) { "B" }
    second_id = page.find(".modal")["id"]

    expect(first_id).to be_present
    expect(second_id).to be_present
    expect(first_id).not_to eq(second_id)
  end

  it "uses a Bootstrap 5 modal (modal fade, not legacy 'hide') with a text-bg-primary header and no inline style" do
    render_inline(described_class.new(:assign, label: "Assign")) { "Body fields" }

    expect(page).to have_css(".modal.fade")
    expect(page).to have_no_css(".modal.hide")
    expect(page).to have_css(".modal-header.text-bg-primary")
    expect(page).to have_no_css("[style]")
  end

  it "renders the content slot as the modal body and a matching submit button" do
    render_inline(described_class.new(:assign, label: "Assign")) { "Body fields" }

    expect(page).to have_css(".modal-body", text: "Body fields")
    expect(page).to have_css(".modal-footer button[type='submit'][name='assign']", text: "Assign")
  end

  it "renders the trigger disabled by default (fail-safe; the controller enables it on selection)" do
    render_inline(described_class.new(:assign, label: "Assign")) { "Body fields" }

    expect(page).to have_css("button[type='button'][data-bs-toggle='modal'][disabled]")
  end

  # ISS#183 follow-up: the last of the five `btn-*`-emitting components left unguarded, and
  # the one `.claude/rules/frontend.md` singled out as NOT covered by the selected-state
  # `text-bg-*` exception. It is guarded here on its own terms rather than by borrowing that
  # rule — the header is a resting surface, not a selection affordance.
  describe "theme-adaptivity guards" do
    let(:modal) { described_class.new(:assign, label: "Assign") }

    def render_modal
      render_inline(modal) { "Body fields" }
    end

    # Four sanctioned fixed hues, each on its own justification:
    #
    #   * the trigger and the footer submit carry `btn-primary` — the brand action
    #     affordance, #fff on #2E75B6 = 4.843:1, identical in both modes;
    #   * the footer close carries `btn-secondary` — #fff on #6C757D = 4.689:1, likewise;
    #   * the header carries `text-bg-primary`. This is NOT the selected-state exception
    #     (`frontend.md` says so explicitly, and correctly — a modal header is a resting
    #     surface with no selected state near it). It stands on a different footing: the
    #     header pins `data-bs-theme="dark"` on ITSELF, so it is a deliberately
    #     self-contained brand banner rather than an element that should track the page.
    #     Bootstrap derives the foreground from the pair, giving the same 4.843:1 in either
    #     ambient mode, and that pinned attribute is asserted below — if it were ever
    #     dropped, the banner would start half-tracking the page and this exception would
    #     no longer hold.
    #
    # `btn-close` is deliberately absent from the list: it is tier-1 in the shared guard
    # (its glyph rides `--bs-btn-close-filter`, which Bootstrap re-resolves per mode), so
    # it survives the scan on its own merits rather than by sanction.
    #
    # One entry PER NODE in document order — trigger, header, footer close, footer submit —
    # so the list's length is the exact expected count and an over-strip reddens.
    def without_sanctioned_hues(fragment)
      nodes = fragment.css(".btn-primary, .text-bg-primary, .btn-secondary")
      strip_sanctioned_hue(nodes, [
        %w[btn-primary], %w[text-bg-primary], %w[btn-secondary], %w[btn-primary]
      ])
      fragment
    end

    it "applies only theme-adaptive colour utilities once the sanctioned hues are stripped" do
      render_modal

      # Pin each sanctioned node before stripping, so a vanished control cannot simply
      # shift the strip list and pass.
      expect(page).to have_css("button.btn.btn-primary[data-bs-toggle='modal']")
      expect(page).to have_css("div.modal-header.text-bg-primary")
      expect(page).to have_css("button.btn.btn-secondary[data-bs-dismiss='modal']", text: "Close")
      expect(page).to have_css("button.btn.btn-primary[type='submit']", text: "Assign")

      expect(without_sanctioned_hues(rendered_fragment)).to be_free_of_fixed_hue_utilities
    end

    # The header's exception depends on it pinning its own colour mode. Asserted separately
    # so that removing `data-bs-theme="dark"` reddens with the reason, rather than silently
    # invalidating the justification written above while the strip carries on passing.
    it "pins the header's own colour mode, which is what its fixed hue rests on" do
      render_modal

      expect(page).to have_css("div.modal-header.text-bg-primary[data-bs-theme='dark']")
    end

    it "emits no colour literal and no inline style anywhere in the modal" do
      render_modal

      expect(page).to have_css("div.modal.fade")
      expect(rendered_fragment).to be_free_of_colour_literals
      expect(rendered_fragment.css("[style]")).to be_empty
    end
  end
end
