# frozen_string_literal: true

class Admin::AvatarCircle::ComponentPreview < ApplicationComponentPreview
  # @label Default
  def default
    render Admin::AvatarCircle::Component.new(name: "Jane Cooper")
  end

  # @label Sizes
  def sizes
    render_with_template(
      locals: {
        avatars: [
          { name: "Jane Cooper", size: :sm },
          { name: "Jane Cooper", size: :md },
          { name: "Jane Cooper", size: :lg },
          { name: "Jane Cooper", size: :xl }
        ]
      }
    )
  end

  # @label Color Variety
  def color_variety
    render_with_template(
      locals: {
        names: [
          "Jane Cooper", "Robert Fox", "Emily Chen", "Marcus Johnson",
          "Sarah Williams", "David Kim", "Lisa Park", "Tom Wilson"
        ]
      }
    )
  end

  # @label Placeholder
  def placeholder
    render Admin::AvatarCircle::Component.new(size: :lg)
  end

  # @label With Link
  def with_link
    render Admin::AvatarCircle::Component.new(name: "Jane Cooper", href: "#")
  end
end
