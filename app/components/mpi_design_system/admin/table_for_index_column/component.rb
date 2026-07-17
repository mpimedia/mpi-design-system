# frozen_string_literal: true

module MpiDesignSystem
  module Admin
    module TableForIndexColumn
      # A single column of MpiDesignSystem::Admin::TableForIndex.
      #
      # This is a slot data-holder, not a rendered component: the parent table reads
      # +header+, the presentation options, and either the captured +td_block+ or the
      # +value+ extractor to build each <th>/<td>. It is never rendered on its own (the
      # +call+ below only exists so the class compiles without a template).
      #
      # Two coexisting cell forms:
      #   (a) block  — table.with_column(header) { |record| arbitrary_html }
      #   (b) helper — table.with_column(header, value: :name, cell: :text)
      #
      # Presentation options are pure Bootstrap utilities (no inline styles): +align+,
      # +nowrap+, +width+. +cell+ selects a lightweight renderer (:text/:boolean/:date).
      # +sortable+/+sort_key+ opt a column into the table's Ransack-free sortable headers.
      class Component < ViewComponent::Base
        ALIGNMENTS = { start: "text-start", center: "text-center", end: "text-end" }.freeze
        WIDTHS = { sm: "w-25", md: "w-50", lg: "w-75" }.freeze
        CELL_TYPES = %i[text boolean date].freeze

        attr_reader :header, :td_block

        # @param header [String, ActiveSupport::SafeBuffer, nil] Header content — a plain
        #   string (escaped) or pre-rendered HTML such as a Ransack sort_link (emitted verbatim).
        #   Also the visible label for a first-class sortable column.
        # @param value [Symbol, Proc, nil] Helper-form cell extractor (method name or callable).
        #   Ignored when a block is given.
        # @param cell [Symbol] :text (default), :boolean (renders a filled Badge), :date.
        # @param align [Symbol, nil] :start, :center, :end — Bootstrap alignment on <th> and <td>.
        # @param nowrap [Boolean] adds text-nowrap.
        # @param width [Symbol, nil] :sm, :md, :lg — whitelisted Bootstrap width utility.
        # @param sortable [Boolean] opt into first-class sortable headers (needs the table's sort_url + sort_key).
        # @param sort_key [Symbol, String, nil] the sort param key for this column.
        def initialize(header = nil, value: nil, cell: :text, align: nil, nowrap: false,
                       width: nil, sortable: false, sort_key: nil, &block)
          @header = header
          @value = value
          @cell = CELL_TYPES.include?(cell) ? cell : :text
          @align = align
          @nowrap = nowrap
          @width = width
          @sortable = sortable
          @sort_key = sort_key
          @td_block = block
        end

        # Never rendered as a component — the parent table reads this column's attributes.
        # Present only so the class compiles without a template.
        def call
          ""
        end

        def block?
          @td_block.present?
        end

        def cell_type
          @cell
        end

        def sortable?
          @sortable
        end

        def sort_key
          @sort_key
        end

        def th_classes
          utility_classes.presence
        end

        def td_classes
          classes = []
          classes << ALIGNMENTS[@align] if @align && ALIGNMENTS.key?(@align)
          classes << "text-nowrap" if @nowrap
          classes.join(" ").presence
        end

        # Extract the cell value for +record+ in the helper form (nil in the block form).
        def value_for(record)
          case @value
          when Symbol then record.public_send(@value)
          when Proc   then @value.call(record)
          end
        end

        # Render a :date cell — accepts an already-formatted string, or formats via to_fs(:long).
        def formatted_date(record)
          raw = value_for(record)
          return if raw.nil?

          raw.respond_to?(:to_fs) ? raw.to_fs(:long) : raw.to_s
        end

        private

        def utility_classes
          classes = []
          classes << ALIGNMENTS[@align] if @align && ALIGNMENTS.key?(@align)
          classes << "text-nowrap" if @nowrap
          classes << WIDTHS[@width] if @width && WIDTHS.key?(@width)
          classes.join(" ")
        end
      end
    end
  end
end
