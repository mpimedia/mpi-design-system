# frozen_string_literal: true

class Admin::AvatarStack::ComponentPreview < ApplicationComponentPreview
  # @label Default
  def default
    render Admin::AvatarStack::Component.new(
      names: [ "Jane Cooper", "Robert Fox", "Emily Chen" ]
    )
  end

  # @label With Overflow
  def with_overflow
    render Admin::AvatarStack::Component.new(
      names: [ "Jane Cooper", "Robert Fox", "Emily Chen", "Marcus Johnson", "Sarah Williams", "David Kim" ],
      max: 4
    )
  end

  # @label Small Size
  def small
    render Admin::AvatarStack::Component.new(
      names: [ "Jane Cooper", "Robert Fox", "Emily Chen" ],
      size: :sm
    )
  end

  # @label Single Avatar
  def single
    render Admin::AvatarStack::Component.new(names: [ "Jane Cooper" ])
  end
end
