# frozen_string_literal: true

class Admin::TagChip::ComponentPreview < ApplicationComponentPreview
  # @label Default
  def default
    render Admin::TagChip::Component.new(label: "Acquisitions", group: :distribution)
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
    render Admin::TagChip::Component.new(
      label: "Fest — MIPCOM 2025",
      group: :press_festival,
      removable: true,
      remove_url: "#"
    )
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
