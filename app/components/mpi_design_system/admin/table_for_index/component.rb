# frozen_string_literal: true

module MpiDesignSystem
  module Admin
    module TableForIndex
      # Neutral, slot/block-based admin index & association listing table.
      #
      # Generalizes the byte-identical local Admin::TableForIndex shared by the MPI apps
      # (Optimus/Garden/Harvest) into the design system. The block column form is the default
      # escape hatch — a column's cell is arbitrary host HTML (links, mail_to, action buttons,
      # badges), so the gem takes no Ransack/Pundit/Pagy/route-helper dependency. Opt-in
      # presentation keywords and first-class sortable headers layer on top; see
      # TableForIndexColumn::Component.
      #
      # Batch selection is opt-in via +batch:+ and the batch-action slots. The consuming app
      # owns the surrounding <form> (submit URL + route + authorization) and the gem ships the
      # +mpi--batch-actions+ Stimulus controller that drives the checkboxes/buttons.
      class Component < ViewComponent::Base
        renders_many :columns, lambda { |header = nil, **options, &block|
          MpiDesignSystem::Admin::TableForIndexColumn::Component.new(header, **options, &block)
        }
        renders_many :batch_action_buttons, MpiDesignSystem::Admin::BatchActionButton::Component
        renders_many :batch_action_modal_buttons, MpiDesignSystem::Admin::BatchActionModalButton::Component

        # @param data [Enumerable] rows to render (an ActiveRecord relation or array).
        # @param title [String, nil] optional section heading (<h4>); also drives the empty-state
        #   heading text and keeps the outline monotonic (:h5 under a title, :h3 for a bare index).
        # @param batch [Boolean] opt-in checkbox-selection column. Requires an app-supplied <form>
        #   carrying data-controller="mpi--batch-actions".
        # @param batch_row_label [Proc, nil] ->(record) { accessible name } for each row's select
        #   checkbox. Defaults to "Select row #{record.id}" — pass a proc for a meaningful name.
        # @param empty_heading [String, nil] override the derived empty-state heading.
        # @param empty_icon [String] Bootstrap icon for the empty state.
        # @param sort_url [Proc, nil] ->(key, dir) { host-built href } for first-class sortable columns.
        # @param current_sort_key [Symbol, String, nil] the currently-sorted key.
        # @param current_sort_dir [Symbol] :asc (default) or :desc.
        def initialize(data:, title: nil, batch: false, batch_row_label: nil, empty_heading: nil,
                       empty_icon: "bi-inbox", sort_url: nil, current_sort_key: nil, current_sort_dir: :asc)
          @data = data
          @title = title
          @batch = batch
          @batch_row_label = batch_row_label
          @empty_heading = empty_heading
          @empty_icon = empty_icon
          @sort_url = sort_url
          @current_sort_key = current_sort_key
          @current_sort_dir = current_sort_dir&.to_sym == :desc ? :desc : :asc
        end

        private

        def rows
          @rows ||= @data.to_a
        end

        def empty_heading
          @empty_heading.presence || (@title.present? ? "No #{@title.downcase} found" : "No records found")
        end

        def empty_heading_level
          @title.present? ? :h5 : :h3
        end

        # First-class sortable-header resolution — Ransack-free: the host supplies sort_url and
        # the current sort state; the gem only renders the link, caret, and aria-sort.
        def sortable?(column)
          column.sortable? && column.sort_key.present? && @sort_url.present?
        end

        def current?(column)
          @current_sort_key.present? && @current_sort_key.to_s == column.sort_key.to_s
        end

        def next_dir(column)
          current?(column) && @current_sort_dir == :asc ? :desc : :asc
        end

        def sort_href(column)
          @sort_url.call(column.sort_key, next_dir(column))
        end

        def aria_sort(column)
          return "none" unless current?(column)

          @current_sort_dir == :asc ? "ascending" : "descending"
        end

        def sort_glyph(column)
          return "↕" unless current?(column) # ↕ inactive

          @current_sort_dir == :asc ? "↑" : "↓" # ↑ / ↓
        end

        def batch_row_label(record)
          return @batch_row_label.call(record) if @batch_row_label

          "Select row #{record.id}"
        end

        def boolean_badge(value)
          MpiDesignSystem::Admin::Badge::Component.new(
            label: value ? "Yes" : "No",
            color: value ? :success : :secondary,
            variant: :filled
          )
        end
      end
    end
  end
end
