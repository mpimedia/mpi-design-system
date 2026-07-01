# frozen_string_literal: true

require "selenium-webdriver"

# Headless Chrome driver for browser-level (`js: true`) feature specs.
#
# selenium-webdriver 4's Selenium Manager resolves a matching chromedriver
# automatically, so no extra gem or committed binary is needed beyond a Chrome
# install — present on the GitHub `ubuntu-latest` runner and on local dev machines.
Capybara.register_driver :mpi_headless_chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument("--headless=new")
  options.add_argument("--no-sandbox")
  options.add_argument("--disable-dev-shm-usage")
  options.add_argument("--disable-gpu")
  options.add_argument("--window-size=1400,1200")
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

Capybara.javascript_driver = :mpi_headless_chrome
Capybara.default_max_wait_time = 5
Capybara.server = :puma, { Silent: true }

# The dummy host renders a Propshaft-served esbuild/dart-sass bundle
# (spec/dummy/app/assets/builds/*), which is gitignored — so a feature spec that
# boots a real page must ensure the bundle exists first, or Stimulus never loads.
# CI builds the assets in the workflow and sets MDS_ASSETS_PREBUILT=1 to skip this.
module FeatureAssets
  ENGINE_ROOT = File.expand_path("../..", __dir__)
  BUILT_JS = File.join(ENGINE_ROOT, "spec/dummy/app/assets/builds/application.js")

  def self.ensure_built!
    return if @ensured

    @ensured = true
    return if ENV["MDS_ASSETS_PREBUILT"] == "1"

    Dir.chdir(ENGINE_ROOT) do
      system("yarn build", exception: true)
      system("yarn build:css", exception: true)
    end
  end
end

RSpec.configure do |config|
  config.include Capybara::DSL, type: :feature

  config.before(:each, type: :feature) do |example|
    FeatureAssets.ensure_built!
    Capybara.current_driver =
      example.metadata.fetch(:js, false) ? Capybara.javascript_driver : Capybara.default_driver
  end

  config.after(:each, type: :feature) do
    Capybara.reset_sessions!
    Capybara.use_default_driver
  end
end
