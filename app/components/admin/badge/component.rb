# frozen_string_literal: true

module Admin
  module Badge
    class Component < ViewComponent::Base
      COLORS = %i[primary success danger warning secondary].freeze
      VARIANTS = %i[filled outline tag_group].freeze
      SIZES = %i[sm md lg].freeze

      TAG_GROUPS = {
        buyers: { color: "#E8733A", bg: "#FEF3EC" },
        press: { color: "#2DA67E", bg: "#ECF8F4" },
        festivals: { color: "#2E75B6", bg: "#EBF3FB" },
        sellers: { color: "#8B5CF6", bg: "#F3EFFE" },
        institutional: { color: "#D97706", bg: "#FEF9EC" },
        organizations: { color: "#6366F1", bg: "#EEEFFE" },
        internal: { color: "#64748B", bg: "#F1F5F9" }
      }.freeze

      # @param label [String] Badge text
      # @param color [Symbol] :primary, :success, :danger, :warning, :secondary
      # @param variant [Symbol] :filled (default), :outline, :tag_group
      # @param size [Symbol] :sm, :md (default), :lg
      # @param tag_group [Symbol] Optional — :buyers, :press, :festivals, :sellers,
      #   :institutional, :organizations, :internal
      # @param count [Integer] Optional inline count
      def initialize(label:, color: :primary, variant: :filled, size: :md, tag_group: nil, count: nil)
        @label = label
        @color = COLORS.include?(color) ? color : :primary
        @variant = VARIANTS.include?(variant) ? variant : :filled
        @size = SIZES.include?(size) ? size : :md
        @tag_group = tag_group
        @count = count
      end

      private

      def css_classes
        classes = ["badge", "rounded-pill"]
        classes << size_class unless @size == :md
        classes.concat(variant_classes)
        classes.join(" ")
      end

      def variant_classes
        case @variant
        when :filled
          ["bg-#{@color}", "text-white"]
        when :outline
          ["border", "border-#{@color}", "text-#{@color}", "bg-transparent"]
        when :tag_group
          [] # Handled by inline styles
        end
      end

      def size_class
        case @size
        when :sm then "fs-7"
        when :lg then "fs-6 px-3 py-1"
        end
      end

      def tag_group_styles
        return unless @variant == :tag_group && @tag_group

        group = TAG_GROUPS[@tag_group]
        return unless group

        "color: #{group[:color]}; background-color: #{group[:bg]};"
      end

      def display_text
        @count ? "#{@label} #{@count}" : @label
      end
    end
  end
end
