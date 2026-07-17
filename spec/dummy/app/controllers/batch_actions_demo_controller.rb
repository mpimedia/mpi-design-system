# frozen_string_literal: true

# Renders a real MpiDesignSystem::Admin::TableForIndex (batch: true) inside a form on a
# page so the browser-level feature spec can boot Stimulus and exercise the
# `mpi--batch-actions` controller end to end (initial disabled state, per-row selection,
# clear, and toggle-all).
class BatchActionsDemoController < ApplicationController
  def show; end
end
