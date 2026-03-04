# frozen_string_literal: true

class Admin::ListCardToggle::ComponentPreview < ApplicationComponentPreview
  # @label Default (List Active)
  def default
    render Admin::ListCardToggle::Component.new(
      result_count: 156,
      result_label: "contacts",
      active_view: :list,
      sort_options: [ [ "Name A-Z", "name_asc" ], [ "Name Z-A", "name_desc" ], [ "Last Engaged", "engaged" ] ],
      list_url: "#list",
      card_url: "#card"
    )
  end

  # @label Card Active
  def card_active
    render Admin::ListCardToggle::Component.new(
      result_count: 156,
      result_label: "contacts",
      active_view: :card,
      sort_options: [ [ "Name A-Z", "name_asc" ], [ "Name Z-A", "name_desc" ] ],
      list_url: "#list",
      card_url: "#card"
    )
  end

  # @label With Search Query
  def with_search
    render Admin::ListCardToggle::Component.new(
      result_count: 12,
      result_label: "contacts",
      active_view: :list,
      search_query: "Jane",
      list_url: "#list",
      card_url: "#card"
    )
  end
end
