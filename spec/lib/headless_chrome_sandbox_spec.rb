# frozen_string_literal: true

require "spec_helper"

# The test browser keeps Chrome's sandbox locally; only CI runners, which need
# it, get --no-sandbox (Playwright/Chromium exposure scan 2026-11-03, P6). The
# driver reads ENV when it is built, so each case stubs CI.
RSpec.describe Capybara, ".drivers" do
  def chrome_args_with_ci(value)
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with("CI").and_return(value)
    described_class.drivers[:mpi_headless_chrome].call(nil).options.fetch(:options).args
  end

  it "passes --no-sandbox to :mpi_headless_chrome on CI" do
    expect(chrome_args_with_ci("true")).to include("--no-sandbox")
  end

  it "keeps the sandbox for :mpi_headless_chrome off CI" do
    expect(chrome_args_with_ci(nil)).not_to include("--no-sandbox")
  end

  it "treats an empty CI variable as off CI" do
    expect(chrome_args_with_ci("")).not_to include("--no-sandbox")
  end
end
