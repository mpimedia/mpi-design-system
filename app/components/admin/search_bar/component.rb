# frozen_string_literal: true

module Admin
  module SearchBar
    class Component < ViewComponent::Base
      # @param placeholder [String] Placeholder text (default: "Search...")
      # @param value [String] Current search value
      # @param name [String] Input name attribute (default: "q")
      # @param size [Symbol] :md (default), :lg (full-width variant)
      # @param show_button [Boolean] Show explicit "Search" button (default: false)
      # @param show_export [Boolean] Show "Export" secondary button (default: false)
      # @param export_url [String] URL for export action
      # @param url [String] Form action URL (for server-side search)
      # @param turbo_frame [String] Turbo Frame target for search results
      # @param data [Hash] data-* attributes for Stimulus controllers
      def initialize(placeholder: "Search...", value: nil, name: "q", size: :md,
                     show_button: false, show_export: false, export_url: nil,
                     url: nil, turbo_frame: nil, data: {})
        @placeholder = placeholder
        @value = value
        @name = name
        @size = %i[md lg].include?(size) ? size : :md
        @show_button = show_button
        @show_export = show_export
        @export_url = export_url
        @url = url
        @turbo_frame = turbo_frame
        @data = data
      end

      private

      def input_class
        @size == :lg ? "form-control form-control-lg" : "form-control"
      end

      def form_data
        d = @data.dup
        d[:turbo_frame] = @turbo_frame if @turbo_frame
        d
      end

      def has_value?
        @value.present?
      end

      def clear_url
        @url || "?"
      end
    end
  end
end
