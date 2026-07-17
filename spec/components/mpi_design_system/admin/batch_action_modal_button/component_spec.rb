# frozen_string_literal: true

require "spec_helper"

RSpec.describe MpiDesignSystem::Admin::BatchActionModalButton::Component, type: :component do
  it "renders a trigger button targeting its modal" do
    render_inline(described_class.new(:assign, label: "Assign")) { "Body fields" }

    expect(page).to have_css("button[type='button'][data-bs-toggle='modal'][data-bs-target='#modal_assign']", text: "Assign")
    expect(page).to have_css("button[data-mpi--batch-actions-target='actionButton']")
  end

  it "renders a Bootstrap 5 modal (modal fade, not the legacy 'hide') with a text-bg-primary header" do
    render_inline(described_class.new(:assign, label: "Assign")) { "Body fields" }

    expect(page).to have_css("#modal_assign.modal.fade")
    expect(page).to have_no_css(".modal.hide")
    expect(page).to have_css(".modal-header.text-bg-primary")
    expect(page).to have_no_css("[style]")
  end

  it "renders the content slot as the modal body and a matching submit button" do
    render_inline(described_class.new(:assign, label: "Assign")) { "Body fields" }

    expect(page).to have_css(".modal-body", text: "Body fields")
    expect(page).to have_css(".modal-footer button[type='submit'][name='assign']", text: "Assign")
  end
end
