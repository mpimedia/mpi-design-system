# frozen_string_literal: true

require "spec_helper"

# Browser-level (real headless Chrome) coverage of the `mpi--batch-actions` Stimulus
# controller.
#
# `render_inline` proves the ERB emits the right data attributes, but it runs no
# JavaScript — it cannot prove the controller actually *binds* under the namespaced
# identifier and drives the disabled/checked state. This spec is therefore the
# load-bearing proof that batch selection works end to end, and that the action button
# is fail-safe: disabled in the server-rendered HTML and enabled only once the controller
# observes a selection (so a missing/late controller cannot submit an empty `ids[]`).
RSpec.describe "BatchActions Stimulus controller", type: :feature, js: true do
  let(:root) { "form[data-controller='mpi--batch-actions']" }
  let(:action_button) { "#{root} button[data-mpi--batch-actions-target='actionButton']" }
  let(:toggle) { "#{root} input[data-mpi--batch-actions-target='toggleCheckbox']" }
  let(:checkbox) { "#{root} input[data-mpi--batch-actions-target='checkbox']" }

  def row_checkboxes
    all(checkbox)
  end

  it "keeps the action button disabled until a row is selected, then re-disables when cleared" do
    visit "/batch_actions_demo"
    expect(page).to have_css(root)

    # Connected controller + no selection => disabled (also the fail-safe initial HTML state).
    expect(page).to have_css("#{action_button}[disabled]")

    # Selecting a row fires change->mpi--batch-actions#checkCheckboxes, which only enables the
    # button if the controller bound under the namespaced identifier.
    row_checkboxes.first.check
    expect(page).to have_css("#{action_button}:not([disabled])")

    row_checkboxes.first.uncheck
    expect(page).to have_css("#{action_button}[disabled]")
  end

  it "toggle-all checks every row and enables the action button" do
    visit "/batch_actions_demo"
    expect(page).to have_css(checkbox, count: 3)

    find(toggle).check
    expect(page).to have_css("#{checkbox}:checked", count: 3)
    expect(page).to have_css("#{action_button}:not([disabled])")
  end

  it "unchecks toggle-all once a single row is deselected" do
    visit "/batch_actions_demo"

    find(toggle).check
    expect(page).to have_css("#{toggle}:checked")

    row_checkboxes.first.uncheck
    expect(page).to have_css("#{toggle}:not(:checked)")
  end
end
