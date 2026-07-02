# frozen_string_literal: true

require "spec_helper"

# Browser-level (real headless Chrome) coverage of the Stimulus `mpi--tag-input`
# controller.
#
# `render_inline` proves the ERB emits the right attributes, but it runs no
# JavaScript — it cannot prove the controller actually *binds* under the
# namespaced identifier. This spec is therefore the load-bearing safety net for
# the `tag-input` -> `mpi--tag-input` prefix rename (issue #103), and in
# particular for the `tag_input_controller.js` line-186 `dataset` -> `setAttribute`
# change: a chip added via `addTagChip` must carry `data-mpi--tag-input-target="tag"`
# for the Stimulus `tag` target (and thus `removeTag`'s `closest()` lookup) to work.
RSpec.describe "TagInput Stimulus controller", type: :feature, js: true do
  let(:root) { "[data-controller='mpi--tag-input']" }
  let(:chip) { "[data-mpi--tag-input-target='tag']" }

  def fill_tag_input(text)
    find("#{root} [data-mpi--tag-input-target='input']").set(text)
  end

  describe "controller registration" do
    it "connects under the namespaced identifier so typing triggers the filter action" do
      visit "/tag_input_demo"

      expect(page).to have_css(root)
      expect(page).to have_no_css(chip)

      # Typing fires `input->mpi--tag-input#filter`, which is only wired if the
      # controller is registered and bound under the *namespaced* identifier. A
      # populated dropdown is therefore proof the prefix rename connected end to end.
      fill_tag_input("VIP")
      expect(page).to have_css("[role='option']", text: "VIP")
    end
  end

  describe "adding a tag" do
    it "filters suggestions as the user types and adds a chip on selection" do
      visit "/tag_input_demo"

      fill_tag_input("TIFF")
      find("[role='option']", text: "TIFF 2026").click

      # The chip carries the namespaced target attribute — this is what the
      # line-186 setAttribute change makes true (dataset.tagInputTarget would
      # have produced the wrong, un-namespaced attribute).
      expect(page).to have_css(chip, text: "TIFF 2026")
      expect(page).to have_css(
        "input[type='hidden'][name='contact[tags][]'][value='TIFF 2026']", visible: :hidden
      )
    end

    it "does not offer an already-selected tag again" do
      visit "/tag_input_demo"

      fill_tag_input("Cannes")
      find("[role='option']", text: "Cannes").click
      expect(page).to have_css(chip, text: "Cannes")

      fill_tag_input("Cannes")
      expect(page).to have_no_css("[role='option']", text: "Cannes")
    end
  end

  describe "removing a tag" do
    it "removes the chip and its hidden input when the remove button is clicked" do
      visit "/tag_input_demo"

      fill_tag_input("Cannes")
      find("[role='option']", text: "Cannes").click
      expect(page).to have_css(chip, text: "Cannes")

      within(chip, text: "Cannes") { click_button }

      expect(page).to have_no_css(chip)
      expect(page).to have_no_css(
        "input[type='hidden'][name='contact[tags][]'][value='Cannes']", visible: :hidden
      )
    end
  end
end
