# frozen_string_literal: true

# Renders a single MpiDesignSystem::Admin::TagInput::Component on a real page so
# the browser-level feature spec can boot Stimulus and exercise the
# `mpi--tag-input` controller end to end (typing, add-chip, remove-chip).
class TagInputDemoController < ApplicationController
  def show; end
end
