# frozen_string_literal: true

module Admin
  module AppShell
    class Component < ViewComponent::Base
      renders_one :breadcrumb
      renders_one :sidebar
      renders_one :body

      # @param current_section [Symbol] Active top-level section key
      # @param current_subsection [Symbol] Active subsection key
      # @param user_name [String] Current user name (for avatar)
      # @param search_url [String] Global search action URL
      # @param show_sidebar [Boolean] Whether to show the content sidebar (default: false)
      # @param sections [Array<Hash>] Custom top-level sections (overrides NavBar defaults)
      # @param subsections [Hash{Symbol => Array<Hash>}] Custom subsections (overrides NavBar defaults)
      # @param environment [Symbol] :development, :staging, :production (for nav color-coding)
      # @param system_url [String] URL for system admin gear icon
      # @param sign_out_url [String] URL for sign-out action
      # @param sign_out_method [Symbol] HTTP method for sign-out (default: :delete)
      # @param profile_url [String] Optional URL for user profile link
      # @param logo_text [String] Logo text (default: "MARKAZ")
      # @param logo_href [String] Logo link URL
      def initialize(current_section: :dashboard, current_subsection: nil, user_name: nil,
                     search_url: nil, show_sidebar: false, sections: nil, subsections: nil,
                     environment: nil, system_url: nil, sign_out_url: nil,
                     sign_out_method: :delete, profile_url: nil,
                     logo_text: "MARKAZ", logo_href: nil)
        @current_section = current_section
        @current_subsection = current_subsection
        @user_name = user_name
        @search_url = search_url
        @show_sidebar = show_sidebar
        @sections = sections
        @subsections = subsections
        @environment = environment
        @system_url = system_url
        @sign_out_url = sign_out_url
        @sign_out_method = sign_out_method
        @profile_url = profile_url
        @logo_text = logo_text
        @logo_href = logo_href
      end

      private

      def nav_bar_options
        opts = {
          current_section: @current_section,
          current_subsection: @current_subsection,
          user_name: @user_name,
          search_url: @search_url,
          logo_text: @logo_text
        }
        opts[:sections] = @sections if @sections
        opts[:subsections] = @subsections if @subsections
        opts[:environment] = @environment if @environment
        opts[:system_url] = @system_url if @system_url
        opts[:sign_out_url] = @sign_out_url if @sign_out_url
        opts[:sign_out_method] = @sign_out_method if @sign_out_method != :delete
        opts[:profile_url] = @profile_url if @profile_url
        opts[:logo_href] = @logo_href if @logo_href
        opts
      end

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
