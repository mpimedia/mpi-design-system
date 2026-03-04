# frozen_string_literal: true

class Admin::TagInput::ComponentPreview < ApplicationComponentPreview
  # @label Default
  def default
    render Admin::TagInput::Component.new(
      available_tags: [
        { label: "Buyer — Theatrical", group: :buyers },
        { label: "Buyer — Digital", group: :buyers },
        { label: "Press — Film Critic", group: :press },
        { label: "Press — Trade Publication", group: :press },
        { label: "Fest — Acquisitions", group: :festivals },
        { label: "Fest — MIPCOM 2025", group: :festivals },
        { label: "Seller — Worldwide", group: :sellers },
        { label: "Internal — Staff", group: :internal }
      ]
    )
  end

  # @label With Selected Tags
  def with_selected
    render Admin::TagInput::Component.new(
      available_tags: [
        { label: "Buyer — Theatrical", group: :buyers },
        { label: "Buyer — Digital", group: :buyers },
        { label: "Press — Film Critic", group: :press },
        { label: "Press — Trade Publication", group: :press },
        { label: "Fest — Acquisitions", group: :festivals },
        { label: "Fest — MIPCOM 2025", group: :festivals }
      ],
      selected_tags: [
        { label: "Buyer — Theatrical", group: :buyers },
        { label: "Fest — Acquisitions", group: :festivals },
        { label: "Press — Film Critic", group: :press }
      ]
    )
  end

  # @label Custom Field
  def custom_field
    render Admin::TagInput::Component.new(
      available_tags: [
        { label: "Buyer — Theatrical", group: :buyers },
        { label: "Press — Film Critic", group: :press }
      ],
      name: "contact[tags][]",
      placeholder: "Search and add tags..."
    )
  end
end
