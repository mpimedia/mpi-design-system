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

    it "keeps the suggestion dropdown hidden on initial load" do
      visit "/tag_input_demo"
      expect(page).to have_css("[data-controller='mpi--tag-input']")
      display = page.evaluate_script(
        "getComputedStyle(document.querySelector(\"[data-mpi--tag-input-target='dropdown']\")).display"
      )
      expect(display).to eq("none")
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

  # Before #168 this spec proved a chip EXISTED but never inspected its styling, and
  # the controller carried its own frozen palette keyed on a stale vocabulary
  # (buyers/press/festivals/…) that the server never sends. Only `internal` overlapped,
  # so six of seven groups silently painted grey — a live defect that shipped green
  # precisely because nothing here read a colour. These examples close that hole.
  describe "the colour of an interactively-added chip (#168)" do
    # Group -> the semantic Bootstrap paints for `bg-{sem}-subtle`, measured against the
    # compiled engine bundle in light mode. Pinning the PAINTED value (not merely the
    # class) is what proves the controller resolved the right variant: an unstyled or
    # wrongly-keyed chip would inherit its parent's background instead.
    {
      "VIP" => { group: "distribution", variant: "danger", surface: "#F8D7DA", foreground: "#58151C" },
      "Priority" => { group: "outreach", variant: "success", surface: "#D3ECE1", foreground: "#0E402B" },
      "Budget" => { group: "finance", variant: "warning", surface: "#F6E4D5", foreground: "#553012" },
      "Ops" => { group: "internal", variant: "secondary", surface: "#E2E3E5", foreground: "#2B2F32" }
    }.each do |label, expected|
      it "paints a #{expected[:group]} chip with the #{expected[:variant]} subtle/emphasis pair" do
        visit "/tag_input_demo"

        fill_tag_input(label)
        find("[role='option']", text: label).click
        expect(page).to have_css(chip, text: label)

        # The classes the controller must emit — identical to the server-rendered chip.
        expect(page).to have_css(
          "#{chip}.rounded-pill.bg-#{expected[:variant]}-subtle.text-#{expected[:variant]}-emphasis",
          text: label
        )

        measured, foreground, background = ratio_for("#{chip}[data-tag-label='#{label}']")

        expect(foreground).to eq(expected[:foreground])
        expect(background).to eq(expected[:surface])
        expect(measured).to be >= 4.5,
          "#{expected[:group]} chip #{foreground} on #{background} = #{measured.round(2)}:1"
      end
    end

    # The retired `opacity: 0.6` faded the chip's foreground; RESOLVE_JS multiplies
    # cumulative ancestor opacity, so this measures what a user actually sees rather
    # than the declared pair (#130's lesson — audit opacity, not just `color:`).
    it "keeps the remove button's effective foreground above the AA floor" do
      visit "/tag_input_demo"

      fill_tag_input("VIP")
      find("[role='option']", text: "VIP").click
      expect(page).to have_css(chip, text: "VIP")

      measured, foreground, background = ratio_for("#{chip} button")

      expect(foreground).to eq("#58151C")
      expect(background).to eq("#F8D7DA")
      expect(measured).to be >= 4.5,
        "remove button #{foreground} on #{background} = #{measured.round(2)}:1"
      # The declared pair above can be AA-clean and still fail once faded, so assert
      # nothing in the ancestor chain reintroduces an opacity multiplier.
      expect(resolve("#{chip} button")[:cumulativeOpacity]).to eq(1.0)
    end

    # A chip added after load must be indistinguishable from one rendered by the server.
    # This is the assertion the old vocabulary mismatch would have failed outright.
    it "matches the server-rendered chip's classes exactly" do
      visit "/tag_input_demo"

      fill_tag_input("VIP")
      find("[role='option']", text: "VIP").click
      expect(page).to have_css(chip, text: "VIP")

      added = page.evaluate_script(
        "document.querySelector(\"#{chip}[data-tag-label='VIP']\").className.split(/\\s+/).sort().join(' ')"
      )
      expect(added).to eq(
        %w[
          align-items-center bg-danger-subtle d-inline-flex fw-semibold gap-1
          rounded-pill text-danger-emphasis
        ].join(" ")
      )
    end

    it "gives the dropdown suggestion dot its group's semantic fill" do
      visit "/tag_input_demo"

      fill_tag_input("VIP")

      expect(page).to have_css("[role='option'] span.d-inline-block.bg-danger")
      expect(page).to have_css("[role='option'].text-body", text: "VIP")
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
