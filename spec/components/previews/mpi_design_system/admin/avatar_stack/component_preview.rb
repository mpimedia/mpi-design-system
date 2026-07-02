# frozen_string_literal: true

class MpiDesignSystem::Admin::AvatarStack::ComponentPreview < ApplicationComponentPreview
  # @label Default
  def default
    render MpiDesignSystem::Admin::AvatarStack::Component.new(
      names: [ "Jane Cooper", "Robert Fox", "Emily Chen" ]
    )
  end

  # @label With Overflow
  def with_overflow
    render MpiDesignSystem::Admin::AvatarStack::Component.new(
      names: [ "Jane Cooper", "Robert Fox", "Emily Chen", "Marcus Johnson", "Sarah Williams", "David Kim" ],
      max: 4
    )
  end

  # @label Small Size
  def small
    render MpiDesignSystem::Admin::AvatarStack::Component.new(
      names: [ "Jane Cooper", "Robert Fox", "Emily Chen" ],
      size: :sm
    )
  end

  # @label Single Avatar
  def single
    render MpiDesignSystem::Admin::AvatarStack::Component.new(names: [ "Jane Cooper" ])
  end
end
