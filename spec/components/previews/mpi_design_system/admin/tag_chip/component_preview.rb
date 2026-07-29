# frozen_string_literal: true

class MpiDesignSystem::Admin::TagChip::ComponentPreview < ApplicationComponentPreview
  # @label Default
  def default
    render MpiDesignSystem::Admin::TagChip::Component.new(label: "Acquisitions", group: :distribution)
  end

  # @label All Groups
  def all_groups
    render_with_template(
      locals: {
        tags: [
          { label: "Acquisitions", group: :distribution },
          { label: "Journalist", group: :outreach },
          { label: "Festival", group: :press_festival },
          { label: "Intl Sales", group: :vendors },
          { label: "Institutional — Archive", group: :finance },
          { label: "Organization — Studio", group: :production },
          { label: "Internal — Staff", group: :internal }
        ]
      }
    )
  end

  # @label Removable
  def removable
    render MpiDesignSystem::Admin::TagChip::Component.new(
      label: "Fest — MIPCOM 2025",
      group: :press_festival,
      removable: true,
      remove_url: "#"
    )
  end

  # The chip is one of the few converted components whose surrounding markup is the chip
  # itself, so a colour-mode preview here shows the real thing rather than an adaptive tag
  # sitting inside a still-fixed light shell. The card, list-row and detail-panel previews
  # deliberately do NOT get a dark example for that reason — see the #168 PR notes.
  #
  # @label Colour Modes
  def colour_modes
    render_with_template
  end

  # @label Small Size
  def small
    render_with_template(
      locals: {
        tags: [
          { label: "Acquisitions", group: :distribution, size: :sm },
          { label: "Journalist", group: :outreach, size: :sm },
          { label: "Fest — Selection", group: :press_festival, size: :sm }
        ]
      }
    )
  end
end
