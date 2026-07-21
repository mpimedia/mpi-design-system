# frozen_string_literal: true

module MpiDesignSystem
  module Admin
    module AvatarStack
      class Component < ViewComponent::Base
        # Neutral background for the "+N" overflow chip. Its foreground is derived
        # rather than pinned, so the pair stays accessible if this value changes. (#130)
        OVERFLOW_COLOR = "#64748B"

        # @param names [Array<String>] List of contact names
        # @param max [Integer] Maximum visible avatars before "+N" (default: 4)
        # @param size [Symbol] :sm, :md (default)
        def initialize(names:, max: 4, size: :md)
          @names = names
          @max = max
          @size = %i[sm md].include?(size) ? size : :md
        end

        private

        def visible_names
          @names.first(@max)
        end

        def overflow_count
          [ @names.length - @max, 0 ].max
        end

        def overflow?
          overflow_count > 0
        end

        def dimension
          @size == :sm ? 28 : 40
        end

        def overflow_background_color
          OVERFLOW_COLOR
        end

        def overflow_foreground_color
          MpiDesignSystem::ColorContrast.accessible_foreground(OVERFLOW_COLOR)
        end

        def stack_label
          if overflow?
            "#{@names.length} contacts, plus #{overflow_count} more"
          else
            "#{@names.length} contacts"
          end
        end
      end
    end
  end
end
