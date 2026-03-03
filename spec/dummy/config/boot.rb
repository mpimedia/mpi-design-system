# Point to the engine's Gemfile, not the dummy app's
ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../../../Gemfile", __dir__)

require "bundler/setup"
