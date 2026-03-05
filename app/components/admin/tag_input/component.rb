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

      def derived_groups
        @selected_tags.map { |t| t[:group] }.compact.uniq
      end

      def show_derived_groups?
        derived_groups.any?
      end

      def derived_group_label(group_sym)
        group_sym.to_s.tr("_", " ").split.map(&:capitalize).join(" ")
      end

      def derived_group_styles(group_sym)
        groups = Admin::TagChip::Component::GROUPS
        config = groups[group_sym] || groups[:internal]
        [
          "display: inline-block",
          "padding: 2px 8px",
          "border-radius: 999px",
          "font-size: 11px",
          "font-weight: 500",
          "color: #{config[:color]}",
          "background-color: #{config[:bg]}"
        ].join("; ")
      end

      def section_heading_styles
        [
          "font-size: 10px",
          "font-weight: 600",
          "text-transform: uppercase",
          "letter-spacing: 0.04em",
          "color: #6C757D",
          "margin-bottom: 6px"
        ].join("; ")
      end

      def keyboard_hint_styles
        "font-size: 11px; color: #ADB5BD; margin-top: 6px;"
      end
    end
  end
end
