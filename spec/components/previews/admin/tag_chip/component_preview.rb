# frozen_string_literal: true

class Admin::TagChip::ComponentPreview < ApplicationComponentPreview
  # @label Default
  def default
    render Admin::TagChip::Component.new(label: "Buyers", group: :buyers)
  end

  # @label All Groups
  def all_groups
    render_with_template(
      locals: {
        tags: Admin::TagChip::Component::GROUPS.keys.map do |group|
          { label: group.to_s.capitalize, group: group }
        end
      }
    )
  end

  # @label Removable
  def removable
    render Admin::TagChip::Component.new(
      label: "Festivals",
      group: :festivals,
      removable: true,
      remove_url: "#"
    )
  end

  # @label Small Size
  def small
    render_with_template(
      locals: {
        tags: %i[buyers press festivals].map do |group|
          { label: group.to_s.capitalize, group: group, size: :sm }
        end
      }
    )
  end
end
