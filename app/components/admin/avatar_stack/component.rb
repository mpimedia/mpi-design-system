# frozen_string_literal: true

module Admin
  module AvatarStack
    class Component < ViewComponent::Base
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
        [@names.length - @max, 0].max
      end

      def overflow?
        overflow_count > 0
      end

      def dimension
        @size == :sm ? 28 : 40
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
