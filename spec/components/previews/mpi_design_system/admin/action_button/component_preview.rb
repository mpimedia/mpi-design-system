# frozen_string_literal: true

class MpiDesignSystem::Admin::ActionButton::ComponentPreview < ApplicationComponentPreview
  # @label Default
  def default
    render MpiDesignSystem::Admin::ActionButton::Component.new(label: "Add Contact", icon: "bi-plus-lg")
  end

  # @label Colors
  def colors
    render_with_template(
      locals: {
        buttons: [
          { label: "Primary", color: :primary },
          { label: "Success", color: :success },
          { label: "Danger", color: :danger },
          { label: "Warning", color: :warning },
          { label: "Info", color: :info },
          { label: "Secondary", color: :secondary }
        ]
      }
    )
  end

  # @label Variants
  def variants
    render_with_template(
      locals: {
        buttons: [
          { label: "Filled", color: :primary, variant: :filled },
          { label: "Outline", color: :primary, variant: :outline }
        ]
      }
    )
  end

  # @label Sizes
  def sizes
    render_with_template(
      locals: {
        buttons: [
          { label: "Small", size: :sm },
          { label: "Medium", size: :md },
          { label: "Large", size: :lg }
        ]
      }
    )
  end

  # @label With Icon
  def with_icon
    render MpiDesignSystem::Admin::ActionButton::Component.new(
      label: "New Contact",
      icon: "bi-plus-lg",
      color: :primary
    )
  end

  # @label Icon Only
  def icon_only
    render_with_template(
      locals: {
        buttons: [
          { label: "Add", icon: "bi-plus-lg", icon_only: true, size: :sm },
          { label: "Edit", icon: "bi-pencil", icon_only: true, size: :md },
          { label: "Delete", icon: "bi-trash", icon_only: true, color: :danger, size: :lg }
        ]
      }
    )
  end

  # @label Disabled
  def disabled
    render MpiDesignSystem::Admin::ActionButton::Component.new(
      label: "Disabled",
      disabled: true
    )
  end

  # @label As Link
  def as_link
    render MpiDesignSystem::Admin::ActionButton::Component.new(
      label: "View Details",
      href: "#",
      icon: "bi-arrow-right"
    )
  end

  # @label As Action Link
  def as_action_link
    render MpiDesignSystem::Admin::ActionButton::Component.new(
      label: "Delete",
      href: "#",
      method: :delete,
      color: :danger,
      icon: "bi-trash"
    )
  end

  # @label With Appended Classes
  def with_classes_append
    render MpiDesignSystem::Admin::ActionButton::Component.new(
      label: "Add Contact",
      icon: "bi-plus-lg",
      classes_append: "float-end"
    )
  end
end
