# frozen_string_literal: true

module MpiDesignSystem
  module Admin
    module Badge
      class Component < ViewComponent::Base
        COLORS = %i[primary success danger warning info secondary].freeze
        VARIANTS = %i[filled outline tag_group].freeze
        SIZES = %i[sm md lg].freeze

        # Replaces the retired `TAG_GROUPS` hex map — a byte-identical duplicate of
        # `TagChip::Component::GROUPS` that drifted independently. Reading the shared
        # mapping means a category renders one adaptive hue here and in every other
        # tag renderer. (#168)
        GROUP_VARIANTS = MpiDesignSystem::Admin::TagChip::Component::GROUP_VARIANTS

        # @param label [String] Badge text
        # @param color [Symbol] :primary, :success, :danger, :warning, :info, :secondary
        # @param variant [Symbol] :filled (default), :outline, :tag_group
        # @param size [Symbol] :sm, :md (default), :lg
        # @param tag_group [Symbol] Optional — :production, :distribution, :finance, :press_festival,
        #   :internal, :vendors, :outreach
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
          classes = [ "badge", "rounded-pill" ]
          classes << size_class unless @size == :md
          classes.concat(variant_classes)
          classes.join(" ")
        end

        def variant_classes
          case @variant
          when :filled
            [ "text-bg-#{@color}" ]
          when :outline
            [ "border", "border-#{@color}", "text-#{@color}", "bg-transparent" ]
          when :tag_group
            tag_group_classes
          end
        end

        # An unknown (or absent) `tag_group:` deliberately renders an UNSTYLED badge —
        # the exact behaviour the retired `tag_group_styles` had when it returned nil
        # and the template omitted the `style` attribute entirely. Preserved rather
        # than defaulting to `secondary`, so the conversion changes colour source
        # without changing which inputs produce a styled badge. (#168)
        def tag_group_classes
          variant = GROUP_VARIANTS[@tag_group]
          return [] unless variant

          [ "bg-#{variant}-subtle", "text-#{variant}-emphasis" ]
        end

        def size_class
          case @size
          when :sm then "fs-6"
          when :lg then "fs-6 px-3 py-1"
          end
        end

        def display_text
          @count ? "#{@label} #{@count}" : @label
        end
      end
    end
  end
end
