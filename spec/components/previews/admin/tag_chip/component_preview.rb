# frozen_string_literal: true

class Admin::TagChip::ComponentPreview < ApplicationComponentPreview
  # @label Default
  def default
    render Admin::TagChip::Component.new(label: "Buyer — Theatrical", group: :buyers)
  end

  # @label All Groups
  def all_groups
    render_with_template(
      locals: {
        tags: [
          { label: "Buyer — Theatrical", group: :buyers },
          { label: "Press — Film Critic", group: :press },
          { label: "Fest — Acquisitions", group: :festivals },
          { label: "Seller — Worldwide", group: :sellers },
          { label: "Institutional — Archive", group: :institutional },
          { label: "Organization — Studio", group: :organizations },
          { label: "Internal — Staff", group: :internal }
        ]
      }
    )
  end

  # @label Removable
  def removable
    render Admin::TagChip::Component.new(
      label: "Fest — MIPCOM 2025",
      group: :festivals,
      removable: true,
      remove_url: "#"
    )
  end

  # @label Small Size
  def small
    render_with_template(
      locals: {
        tags: [
          { label: "Buyer — Theatrical", group: :buyers, size: :sm },
          { label: "Press — Critic", group: :press, size: :sm },
          { label: "Fest — Selection", group: :festivals, size: :sm }
        ]
      }
    )
  end
end
