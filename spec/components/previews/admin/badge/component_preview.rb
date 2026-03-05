# frozen_string_literal: true

class Admin::Badge::ComponentPreview < ApplicationComponentPreview
  # @label Default
  def default
    render Admin::Badge::Component.new(label: "Active", color: :primary)
  end

  # @label Colors
  # @display bg_color "#f8f9fa"
  def colors
    render_with_template(
      locals: {
        badges: [
          { label: "Primary", color: :primary },
          { label: "Success", color: :success },
          { label: "Danger", color: :danger },
          { label: "Warning", color: :warning },
          { label: "Secondary", color: :secondary }
        ]
      }
    )
  end

  # @label Variants
  def variants
    render_with_template(
      locals: {
        badges: [
          { label: "Filled", color: :primary, variant: :filled },
          { label: "Outline", color: :primary, variant: :outline },
          { label: "Distribution", color: :primary, variant: :tag_group, tag_group: :distribution }
        ]
      }
    )
  end

  # @label Sizes
  def sizes
    render_with_template(
      locals: {
        badges: [
          { label: "Small", color: :primary, size: :sm },
          { label: "Medium", color: :primary, size: :md },
          { label: "Large", color: :primary, size: :lg }
        ]
      }
    )
  end

  # @label Tag Groups
  def tag_groups
    render_with_template(
      locals: {
        badges: Admin::TagChip::Component::GROUPS.keys.map do |group|
          { label: group.to_s.capitalize, variant: :tag_group, tag_group: group }
        end
      }
    )
  end

  # @label With Count
  def with_count
    render Admin::Badge::Component.new(label: "Contacts", color: :primary, count: 42)
  end
end
