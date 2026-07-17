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
end
