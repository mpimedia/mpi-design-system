# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Lookbook preview rendering", type: :component do
  ViewComponent::Preview.all.each do |preview|
    preview.examples.each do |scenario|
      it "renders #{preview}##{scenario} without error" do
        expect { render_preview(scenario, from: preview) }.not_to raise_error
      end
    end
  end
end
