# frozen_string_literal: true

module MpiDesignSystem
  module Admin
    module ActionButton
      class Component < ViewComponent::Base
        COLORS = %i[primary success danger warning info secondary].freeze
        VARIANTS = %i[filled outline].freeze
        SIZES = %i[sm md lg].freeze

        # HTTP verbs that make an href-driven element an *action* rather than navigation.
        ACTION_METHODS = %i[post put patch delete].freeze

        # @param label [String] Button text
        # @param color [Symbol] :primary (default), :success, :danger, :warning, :info, :secondary
        # @param variant [Symbol] :filled (default), :outline
        # @param size [Symbol] :sm, :md (default), :lg
        # @param icon [String] Bootstrap Icon class (e.g., "bi-plus-lg")
        # @param icon_only [Boolean] Hide label, show only icon (default: false)
        # @param disabled [Boolean] Disable the button (default: false)
        # @param href [String] Optional — renders as <a> instead of <button>
        # @param method [Symbol] HTTP method for Turbo (:get, :post, :put, :patch, :delete)
        # @param data [Hash] data-* attributes (Turbo/Stimulus)
        # @param classes_append [String, Array<String>] Extra layout utility classes (e.g. "float-end me-2")
        # @param role [String] Optional ARIA role override (defaults to "button" for non-GET links)
        def initialize(label:, color: :primary, variant: :filled, size: :md, icon: nil,
                       icon_only: false, disabled: false, href: nil, method: nil, data: {},
                       classes_append: nil, role: nil)
          @label = label
          @color = COLORS.include?(color) ? color : :primary
          @variant = VARIANTS.include?(variant) ? variant : :filled
          @size = SIZES.include?(size) ? size : :md
          @icon = icon
          @icon_only = icon_only
          @disabled = disabled
          @href = href
          @method = method
          @data = data
          @classes_append = classes_append
          @role = role
        end

        def call
          if @href
            link_to(@href, **tag_attributes) { inner_content }
          else
            content_tag(:button, inner_content, **tag_attributes)
          end
        end

        private

        def tag_attributes
          attrs = { class: css_classes, data: turbo_data }
          attrs[:aria] = { label: @label } if @icon_only
          attrs[:role] = resolved_role if resolved_role

          if @disabled
            if @href
              attrs[:tabindex] = "-1"
              attrs[:aria] = (attrs[:aria] || {}).merge(disabled: true)
              attrs[:data] = {} # suppress turbo method on disabled links
            else
              attrs[:disabled] = "disabled"
              attrs[:aria] = (attrs[:aria] || {}).merge(disabled: true)
            end
          end

          attrs
        end

        def css_classes
          token_list(
            "btn",
            btn_color_class,
            ("btn-#{@size}" unless @size == :md),
            ("disabled" if @disabled && @href),
            @classes_append
          )
        end

        # An href-driven element with a non-GET verb is an *action*, so it gets role="button".
        # An href with :get (or no verb) is navigation and deliberately gets no role — consumers
        # such as Harvest pass method: :get on every navigation button. An explicit role: wins,
        # covering anchors driven by data: alone (data-bs-toggle / Stimulus) with no HTTP verb.
        # role: is override-only: it can add or change a role, but cannot suppress the derived
        # one, since a non-GET action link announced as a plain link is the bug this prevents.
        #
        # The verb is normalized rather than compared raw, so a String ("delete") or a shouty
        # one ("DELETE") derives the role the same as :delete. Comparing raw would silently drop
        # the role — no error, just a missing a11y attribute. Never raises on odd input, per
        # `.claude/rules/frontend.md`: fall back to a safe default, don't blow up a render.
        def resolved_role
          return @role if @role.present?

          "button" if @href && ACTION_METHODS.include?(@method.to_s.downcase.to_sym)
        end

        def btn_color_class
          if @variant == :outline
            "btn-outline-#{@color}"
          else
            "btn-#{@color}"
          end
        end

        def turbo_data
          d = @data.dup
          d[:turbo_method] = @method if @method
          d
        end

        def inner_content
          parts = []
          if @icon
            icon_classes = @icon.start_with?("bi ") ? @icon : "bi #{@icon}"
            icon_classes = "#{icon_classes} me-1" unless @icon_only
            parts << content_tag(:i, "", class: icon_classes, aria: { hidden: true })
          end
          parts << @label unless @icon_only
          safe_join(parts)
        end
      end
    end
  end
end
