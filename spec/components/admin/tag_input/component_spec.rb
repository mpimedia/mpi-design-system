# frozen_string_literal: true

require "spec_helper"

RSpec.describe Admin::TagInput::Component, type: :component do
  let(:available_tags) do
    [
      { label: "VIP", group: :distribution },
      { label: "Priority", group: :outreach },
      { label: "TIFF 2026", group: :press_festival },
      { label: "Cannes", group: :press_festival }
    ]
  end

  let(:selected_tags) do
    [
      { label: "VIP", group: :distribution },
      { label: "TIFF 2026", group: :press_festival }
    ]
  end

  it "renders wrapper with border styling" do
    render_inline(described_class.new(available_tags: available_tags))

    expect(page).to have_css("div[style*='border: 1px solid #DEE2E6'][style*='border-radius: 6px']")
  end

  it "renders text input with placeholder" do
    render_inline(described_class.new(available_tags: available_tags, placeholder: "Search tags..."))

    expect(page).to have_css("input[type='text'][placeholder='Search tags...']")
  end

  it "renders default placeholder" do
    render_inline(described_class.new(available_tags: available_tags))

    expect(page).to have_css("input[placeholder='Add a tag...']")
  end

  it "renders input with aria-label" do
    render_inline(described_class.new(available_tags: available_tags))

    expect(page).to have_css("input[aria-label='Type to search tags']")
  end

  it "renders Stimulus controller data attribute" do
    render_inline(described_class.new(available_tags: available_tags))

    expect(page).to have_css("div[data-controller='tag-input']")
  end

  it "renders available tags as JSON value" do
    render_inline(described_class.new(available_tags: available_tags))

    expect(page).to have_css("div[data-tag-input-available-tags-value]")
  end

  it "renders selected tags as removable chips" do
    render_inline(described_class.new(
      available_tags: available_tags,
      selected_tags: selected_tags
    ))

    expect(page).to have_css("span[data-tag-input-target='tag']", text: "VIP")
    expect(page).to have_css("span[data-tag-input-target='tag']", text: "TIFF 2026")
  end

  it "renders remove buttons on selected tags" do
    render_inline(described_class.new(
      available_tags: available_tags,
      selected_tags: selected_tags
    ))

    expect(page).to have_css("button[aria-label='Remove VIP']")
    expect(page).to have_css("button[aria-label='Remove TIFF 2026']")
  end

  it "renders hidden inputs for selected tags" do
    render_inline(described_class.new(
      available_tags: available_tags,
      selected_tags: selected_tags,
      name: "contact[tags][]"
    ))

    expect(page).to have_css("input[type='hidden'][name='contact[tags][]'][value='VIP']", visible: :hidden)
    expect(page).to have_css("input[type='hidden'][name='contact[tags][]'][value='TIFF 2026']", visible: :hidden)
  end

  it "renders dropdown container with listbox role" do
    render_inline(described_class.new(available_tags: available_tags))

    expect(page).to have_css("div[role='listbox'][aria-label='Tag suggestions']", visible: :hidden)
  end

  it "renders dropdown hidden by default" do
    render_inline(described_class.new(available_tags: available_tags))

    expect(page).to have_css("div[data-tag-input-target='dropdown'][style*='display: none']", visible: :hidden)
  end

  it "renders selected tag chips with correct colors" do
    render_inline(described_class.new(
      available_tags: available_tags,
      selected_tags: [ { label: "VIP", group: :distribution } ]
    ))

    expect(page).to have_css("span[style*='color: #E8733A']", text: "VIP")
  end

  it "renders Stimulus action bindings on input" do
    render_inline(described_class.new(available_tags: available_tags))

    expect(page).to have_css("input[data-action*='tag-input#filter']")
    expect(page).to have_css("input[data-action*='tag-input#onKeydown']")
  end

  it "renders field name value for Stimulus" do
    render_inline(described_class.new(
      available_tags: available_tags,
      name: "contact[tags][]"
    ))

    expect(page).to have_css("div[data-tag-input-field-name-value='contact[tags][]']")
  end

  it "renders aria-label on wrapper" do
    render_inline(described_class.new(available_tags: available_tags))

    expect(page).to have_css("div[aria-label='Tag selection']")
  end

  context "with no selected tags" do
    it "renders empty selected tags container" do
      render_inline(described_class.new(available_tags: available_tags))

      expect(page).to have_css("div[data-tag-input-target='selectedTags']")
      expect(page).not_to have_css("span[data-tag-input-target='tag']")
    end
  end

  context "with no available tags" do
    it "renders component with empty available tags value" do
      render_inline(described_class.new(available_tags: []))

      expect(page).to have_css("div[data-tag-input-available-tags-value='[]']")
    end
  end

  context "with derived groups" do
    it "renders auto-derived groups section when tags are selected" do
      render_inline(described_class.new(
        available_tags: available_tags,
        selected_tags: selected_tags
      ))

      expect(page).to have_text("Auto-Derived Groups")
      expect(page).to have_text("Distribution")
      expect(page).to have_text("Press Festival")
    end

    it "does not render derived groups when no tags are selected" do
      render_inline(described_class.new(available_tags: available_tags))

      expect(page).not_to have_text("Auto-Derived Groups")
    end
  end

  it "renders keyboard navigation hint" do
    render_inline(described_class.new(available_tags: available_tags))

    expect(page).to have_text("to navigate")
    expect(page).to have_text("Enter to select")
    expect(page).to have_text("Esc to close")
  end
end
