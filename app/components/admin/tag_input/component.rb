# frozen_string_literal: true

module Admin
  module TagInput
    class Component < ViewComponent::Base
      # @param available_tags [Array<Hash>] Each: { label: String, group: Symbol }
      # @param selected_tags [Array<Hash>] Each: { label: String, group: Symbol }
      # @param name [String] Form field name for hidden inputs (default: "tags[]")
      # @param placeholder [String] Input placeholder text (default: "Add a tag...")
      def initialize(available_tags: [], selected_tags: [], name: "tags[]", placeholder: "Add a tag...")
        @available_tags = available_tags || []
        @selected_tags = selected_tags || []
        @name = name
        @placeholder = placeholder
      end

      private

      def wrapper_styles
        [
          "background: #fff",
          "border: 1px solid #DEE2E6",
          "border-radius: 6px",
          "padding: 8px"
        ].join("; ")
      end

      def input_styles
        [
          "border: none",
          "outline: none",
          "font-size: 14px",
          "flex: 1",
          "min-width: 120px",
          "padding: 4px 0"
        ].join("; ")
      end

      def dropdown_styles
        [
          "position: absolute",
          "top: 100%",
          "left: 0",
          "right: 0",
          "background: #fff",
          "border: 1px solid #DEE2E6",
          "border-radius: 6px",
          "box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1)",
          "max-height: 200px",
          "overflow-y: auto",
          "z-index: 1000",
          "margin-top: 4px"
        ].join("; ")
      end

      def available_tags_json
        @available_tags.map { |t| { label: t[:label], group: t[:group].to_s } }.to_json
      end

      def tag_color(group_sym)
        groups = Admin::TagChip::Component::GROUPS
        config = groups[group_sym] || groups[:internal]
        config[:color]
      end

      def tag_bg(group_sym)
        groups = Admin::TagChip::Component::GROUPS
        config = groups[group_sym] || groups[:internal]
        config[:bg]
      end
    end
  end
end
