# frozen_string_literal: true

module Admin
  module AppShell
    class Component < ViewComponent::Base
      renders_one :sidebar
      renders_one :body

      # @param current_section [Symbol] :dashboard, :content, :crm, :rights_avails, :releases, :screenings
      # @param current_subsection [Symbol] Section-specific (e.g., :contacts, :accounts for CRM)
      # @param user_name [String] Current user name (for avatar)
      # @param search_url [String] Global search action URL
      # @param show_sidebar [Boolean] Whether to show the content sidebar (default: false)
      def initialize(current_section: :dashboard, current_subsection: nil, user_name: nil,
                     search_url: nil, show_sidebar: false)
        @current_section = current_section
        @current_subsection = current_subsection
        @user_name = user_name
        @search_url = search_url
        @show_sidebar = show_sidebar
      end

      private

      def shell_styles
        "min-height: 100vh; display: flex; flex-direction: column;"
      end

      def content_wrapper_styles
        "flex: 1; display: flex;"
      end

      def sidebar_styles
        [
          "width: 180px",
          "border-right: 1px solid #DEE2E6",
          "background: #fff",
          "padding: 16px",
          "overflow-y: auto"
        ].join("; ")
      end

      def content_area_styles
        [
          "flex: 1",
          "padding: 24px",
          "background: #F5F7FA"
        ].join("; ")
      end

      def show_sidebar?
        @show_sidebar && sidebar?
      end
    end
  end
end
