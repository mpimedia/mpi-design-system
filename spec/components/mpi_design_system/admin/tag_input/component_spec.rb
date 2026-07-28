# frozen_string_literal: true

require "spec_helper"

RSpec.describe MpiDesignSystem::Admin::TagInput::Component, type: :component do
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

    expect(page).to have_css("div[data-controller='mpi--tag-input']")
  end

  it "renders available tags as JSON value" do
    render_inline(described_class.new(available_tags: available_tags))

    expect(page).to have_css("div[data-mpi--tag-input-available-tags-value]")
  end

  it "renders selected tags as removable chips" do
    render_inline(described_class.new(
      available_tags: available_tags,
      selected_tags: selected_tags
    ))

    expect(page).to have_css("span[data-mpi--tag-input-target='tag']", text: "VIP")
    expect(page).to have_css("span[data-mpi--tag-input-target='tag']", text: "TIFF 2026")
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

    expect(page).to have_css("div[data-mpi--tag-input-target='dropdown'][style*='margin-top: 4px; display: none']", visible: :hidden)
  end

  # Three separate colour-emitting paths live in this template — the selected chip, its
  # remove button, and the derived-group pills — and before #168 only ONE had any
  # coverage. Each is asserted by a selector unique to it, so a defect in one cannot be
  # masked by another being right.
  describe "selected tag chips (#168)" do
    let(:chip) { "span[data-mpi--tag-input-target='tag']" }
    let(:chip_style) { "font-size: 13px; padding: 0.25em 0.75em; line-height: 1.4" }
    let(:remove_style) { "padding: 0; font-size: inherit; line-height: 1; cursor: pointer" }

    MpiDesignSystem::Admin::TagChip::Component::GROUP_VARIANTS.each do |group, variant|
      it "renders a #{group} chip as the #{variant} subtle/emphasis pair" do
        render_inline(described_class.new(
          available_tags: available_tags, selected_tags: [ { label: "VIP", group: group } ]
        ))

        expect(page).to have_css(
          "#{chip}.rounded-pill.bg-#{variant}-subtle.text-#{variant}-emphasis[style='#{chip_style}']",
          text: "VIP"
        )
      end
    end

    it "falls back to the adaptive secondary pair for an unknown group" do
      render_inline(described_class.new(
        available_tags: available_tags, selected_tags: [ { label: "VIP", group: :not_a_group } ]
      ))

      expect(page).to have_css("#{chip}.bg-secondary-subtle.text-secondary-emphasis", text: "VIP")
    end

    it "renders a remove button that pins no colour and no opacity" do
      render_inline(described_class.new(
        available_tags: available_tags, selected_tags: [ { label: "VIP", group: :distribution } ]
      ))

      expect(page).to have_css(
        "#{chip} > button.text-reset.bg-transparent.border-0[aria-label='Remove VIP'][style='#{remove_style}']"
      )
      expect(page).not_to have_css("#{chip} > button[style*='opacity']")
      expect(page).not_to have_css("#{chip} > button[style*='color']")
    end

    it "leaves no frozen-colour declaration on the chip or its button" do
      render_inline(described_class.new(
        available_tags: available_tags, selected_tags: [ { label: "VIP", group: :distribution } ]
      ))

      expect(page).to have_css("#{chip}.bg-danger-subtle", text: "VIP")
      inline_styles("#{chip}, #{chip} > button").each do |style|
        expect(style).to be_free_of_frozen_colour
      end
    end
  end

  describe "derived group pills (#168)" do
    # `d-inline-block` distinguishes the derived pill from the `d-inline-flex` chip, so
    # these assertions cannot be satisfied by the chips being correct.
    let(:derived) { "span.rounded-pill.d-inline-block" }

    it "renders one pill per distinct group of the selected tags" do
      render_inline(described_class.new(
        available_tags: available_tags,
        selected_tags: [
          { label: "VIP", group: :distribution },
          { label: "Press", group: :outreach },
          { label: "Also VIP", group: :distribution }
        ]
      ))

      expect(page).to have_css("#{derived}.bg-danger-subtle.text-danger-emphasis", text: "Distribution", count: 1)
      expect(page).to have_css("#{derived}.bg-success-subtle.text-success-emphasis", text: "Outreach", count: 1)
    end

    # Complete surviving inline style, exact equality. Without this, deleting
    # `derived_group_styles` outright or dropping one declaration both ship green — the
    # #152 "guards police what LEFT, not what stayed" lesson.
    MpiDesignSystem::Admin::TagChip::Component::GROUP_VARIANTS.each do |group, variant|
      it "renders the #{group} derived pill as the #{variant} pair with its complete geometry" do
        render_inline(described_class.new(
          available_tags: available_tags, selected_tags: [ { label: "X", group: group } ]
        ))

        expect(page).to have_css(
          "#{derived}.bg-#{variant}-subtle.text-#{variant}-emphasis[style='padding: 2px 8px; font-size: 11px; font-weight: 500']"
        )
      end
    end

    it "leaves no frozen-colour declaration on a derived pill" do
      render_inline(described_class.new(
        available_tags: available_tags, selected_tags: [ { label: "X", group: :distribution } ]
      ))

      expect(page).to have_css("#{derived}.bg-danger-subtle")
      inline_styles(derived).each { |style| expect(style).to be_free_of_frozen_colour }
    end

    it "renders no derived section when nothing is selected" do
      render_inline(described_class.new(available_tags: available_tags))

      expect(page).to have_css("div[data-controller='mpi--tag-input']")
      expect(page).not_to have_css(derived)
    end
  end

  it "renders Stimulus action bindings on input" do
    render_inline(described_class.new(available_tags: available_tags))

    expect(page).to have_css("input[data-action*='mpi--tag-input#filter']")
    expect(page).to have_css("input[data-action*='mpi--tag-input#onKeydown']")
  end

  it "renders field name value for Stimulus" do
    render_inline(described_class.new(
      available_tags: available_tags,
      name: "contact[tags][]"
    ))

    expect(page).to have_css("div[data-mpi--tag-input-field-name-value='contact[tags][]']")
  end

  it "renders aria-label on wrapper" do
    render_inline(described_class.new(available_tags: available_tags))

    expect(page).to have_css("div[aria-label='Tag selection']")
  end

  context "with no selected tags" do
    it "renders empty selected tags container" do
      render_inline(described_class.new(available_tags: available_tags))

      expect(page).to have_css("div[data-mpi--tag-input-target='selectedTags']")
      expect(page).not_to have_css("span[data-mpi--tag-input-target='tag']")
    end
  end

  context "with no available tags" do
    it "renders component with empty available tags value" do
      render_inline(described_class.new(available_tags: []))

      expect(page).to have_css("div[data-mpi--tag-input-available-tags-value='[]']")
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
