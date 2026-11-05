# frozen_string_literal: true

require "spec_helper"

# The test browser keeps Chrome's sandbox locally; only CI runners, which need
# it, get --no-sandbox (Playwright/Chromium exposure scan 2026-11-03, P6).
RSpec.describe Capybara, ".drivers" do
  [ :mpi_headless_chrome ].each do |name|
    it "passes --no-sandbox to #{name} only on CI" do
      args = described_class.drivers[name].call(nil).options.fetch(:options).args

      if ENV["CI"].present?
        expect(args).to include("--no-sandbox")
      else
        expect(args).not_to include("--no-sandbox")
      end
    end
  end
end
