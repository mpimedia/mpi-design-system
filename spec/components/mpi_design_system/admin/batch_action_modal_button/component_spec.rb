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
end
