# frozen_string_literal: true

class Admin::Pagination::ComponentPreview < ApplicationComponentPreview
  # @label Default
  def default
    render Admin::Pagination::Component.new(
      current_page: 1,
      total_pages: 10,
      total_count: 247,
      per_page: 25,
      url_builder: ->(page) { "?page=#{page}" }
    )
  end

  # @label Middle Page
  def middle_page
    render Admin::Pagination::Component.new(
      current_page: 5,
      total_pages: 10,
      total_count: 247,
      per_page: 25,
      url_builder: ->(page) { "?page=#{page}" }
    )
  end

  # @label Last Page
  def last_page
    render Admin::Pagination::Component.new(
      current_page: 10,
      total_pages: 10,
      total_count: 247,
      per_page: 25,
      url_builder: ->(page) { "?page=#{page}" }
    )
  end

  # @label Single Page
  def single_page
    render Admin::Pagination::Component.new(
      current_page: 1,
      total_pages: 1,
      total_count: 15,
      per_page: 25,
      url_builder: ->(page) { "?page=#{page}" }
    )
  end
end
