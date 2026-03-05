# frozen_string_literal: true

class Admin::TagInput::ComponentPreview < ApplicationComponentPreview
  # @label Default
  def default
    render Admin::TagInput::Component.new(
      available_tags: [
        { label: "Acquisitions", group: :distribution },
        { label: "Streaming", group: :distribution },
        { label: "Journalist", group: :outreach },
        { label: "Press — Trade Publication", group: :outreach },
        { label: "Festival", group: :press_festival },
        { label: "Fest — MIPCOM 2025", group: :press_festival },
        { label: "Intl Sales", group: :vendors },
        { label: "Internal — Staff", group: :internal }
      ]
    )
  end

  # @label With Selected Tags
  def with_selected
    render Admin::TagInput::Component.new(
      available_tags: [
        { label: "Acquisitions", group: :distribution },
        { label: "Streaming", group: :distribution },
        { label: "Journalist", group: :outreach },
        { label: "Press — Trade Publication", group: :outreach },
        { label: "Festival", group: :press_festival },
        { label: "Fest — MIPCOM 2025", group: :press_festival }
      ],
      selected_tags: [
        { label: "Acquisitions", group: :distribution },
        { label: "Festival", group: :press_festival },
        { label: "Journalist", group: :outreach }
      ]
    )
  end

  # @label Custom Field
  def custom_field
    render Admin::TagInput::Component.new(
      available_tags: [
        { label: "Acquisitions", group: :distribution },
        { label: "Journalist", group: :outreach }
      ],
      name: "contact[tags][]",
      placeholder: "Search and add tags..."
    )
  end
end
