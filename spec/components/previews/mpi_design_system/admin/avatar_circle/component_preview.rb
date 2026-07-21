# frozen_string_literal: true

class MpiDesignSystem::Admin::AvatarCircle::ComponentPreview < ApplicationComponentPreview
  # @label Default
  def default
    render MpiDesignSystem::Admin::AvatarCircle::Component.new(name: "Jane Cooper")
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

  # One name per palette entry, so all ten backgrounds — and the foreground
  # derived for each — are visible at a glance. The previous eight names hashed
  # onto only seven distinct colors, which hid #4EA8DE: the worst offender before
  # #130, at 2.63:1 against the white text this component used to pin.
  # `component_preview_spec.rb` asserts the coverage rather than trusting it.
  #
  # @label Color Variety
  def color_variety
    render_with_template(
      locals: {
        names: [
          "Jane Cooper", "Sarah Williams", "Tom Wilson", "Lisa Park", "Dana Reyes",
          "Robert Fox", "Emily Chen", "Mona Habib", "Hana Ito", "David Kim"
        ]
      }
    )
  end

  # @label Placeholder
  def placeholder
    render MpiDesignSystem::Admin::AvatarCircle::Component.new(size: :lg)
  end

  # @label With Link
  def with_link
    render MpiDesignSystem::Admin::AvatarCircle::Component.new(name: "Jane Cooper", href: "#")
  end
end
