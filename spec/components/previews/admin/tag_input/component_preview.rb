# frozen_string_literal: true

class Admin::TagInput::ComponentPreview < ApplicationComponentPreview
  # @label Default
  def default
    render Admin::TagInput::Component.new(
      available_tags: [
        { label: "Buyers — Lead", group: :buyers },
        { label: "Buyers — Reviewer", group: :buyers },
        { label: "Press — Journalist", group: :press },
        { label: "Press — Editor", group: :press },
        { label: "Festivals — Director", group: :festivals },
        { label: "Festivals — Programmer", group: :festivals },
        { label: "Sellers — Agent", group: :sellers },
        { label: "Institutional — Academic", group: :institutional },
        { label: "Organizations — Non-Profit", group: :organizations },
        { label: "Internal — Staff", group: :internal }
      ]
    )
  end

  # @label With Pre-Selected Tags
  def with_selected
    render Admin::TagInput::Component.new(
      available_tags: [
        { label: "Buyers — Lead", group: :buyers },
        { label: "Press — Journalist", group: :press },
        { label: "Festivals — Director", group: :festivals },
        { label: "Sellers — Agent", group: :sellers }
      ],
      selected_tags: [
        { label: "Buyers — Lead", group: :buyers },
        { label: "Festivals — Director", group: :festivals }
      ]
    )
  end

  # @label Custom Field Name
  def custom_field
    render Admin::TagInput::Component.new(
      available_tags: [
        { label: "Buyers — Lead", group: :buyers },
        { label: "Press — Journalist", group: :press }
      ],
      name: "contact[tag_list][]",
      placeholder: "Search tags..."
    )
  end
end
