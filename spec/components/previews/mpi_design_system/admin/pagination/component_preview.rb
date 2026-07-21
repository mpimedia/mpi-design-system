# frozen_string_literal: true

class MpiDesignSystem::Admin::Pagination::ComponentPreview < ApplicationComponentPreview
  # @label Default
  def default
    render MpiDesignSystem::Admin::Pagination::Component.new(
      current_page: 1,
      total_pages: 10,
      total_count: 247,
      per_page: 25,
      url_builder: ->(page) { "?page=#{page}" }
    )
  end

  # @label Middle Page
  def middle_page
    render MpiDesignSystem::Admin::Pagination::Component.new(
      current_page: 5,
      total_pages: 10,
      total_count: 247,
      per_page: 25,
      url_builder: ->(page) { "?page=#{page}" }
    )
  end

  # @label Last Page
  def last_page
    render MpiDesignSystem::Admin::Pagination::Component.new(
      current_page: 10,
      total_pages: 10,
      total_count: 247,
      per_page: 25,
      url_builder: ->(page) { "?page=#{page}" }
    )
  end

  # @label Single Page
  def single_page
    render MpiDesignSystem::Admin::Pagination::Component.new(
      current_page: 1,
      total_pages: 1,
      total_count: 15,
      per_page: 25,
      url_builder: ->(page) { "?page=#{page}" }
    )
  end

  # The point of the #149 conversion: the same component, no variant flag, following
  # Bootstrap's colour mode. Side-by-side so a designer can compare the two surfaces
  # in one view rather than toggling a theme.
  #
  # @label Dark Mode
  def dark_mode
    render_with_template
  end

  # @label Windowed (many pages)
  def windowed
    render MpiDesignSystem::Admin::Pagination::Component.new(
      current_page: 20,
      total_pages: 47,
      total_count: 1175,
      per_page: 25,
      url_builder: ->(page) { "?page=#{page}" },
      max_links: 7
    )
  end
end
