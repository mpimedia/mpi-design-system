# frozen_string_literal: true

require "spec_helper"

RSpec.describe Admin::AvatarStack::Component, type: :component do
  it "renders multiple avatars" do
    render_inline(described_class.new(names: [ "Alice Wong", "Bob Smith", "Carol Davis" ]))

    expect(page).to have_css("span.rounded-circle", count: 3)
  end

  it "shows overflow indicator when names exceed max" do
    names = [ "Alice", "Bob", "Carol", "Dave", "Eve", "Frank" ]
    render_inline(described_class.new(names: names, max: 4))

    expect(page).to have_css("span.rounded-circle", minimum: 4)
    expect(page).to have_text("+2")
  end

  it "does not show overflow when within max" do
    render_inline(described_class.new(names: [ "Alice", "Bob" ]))

    expect(page).not_to have_text("+")
  end

  it "includes aria-label describing the group" do
    names = [ "Alice", "Bob", "Carol", "Dave", "Eve" ]
    render_inline(described_class.new(names: names, max: 3))

    expect(page).to have_css("div[aria-label='5 contacts, plus 2 more']")
  end
end
