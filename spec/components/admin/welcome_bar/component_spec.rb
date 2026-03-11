# frozen_string_literal: true

require "spec_helper"

RSpec.describe Admin::WelcomeBar::Component, type: :component do
  it "renders title text" do
    render_inline(described_class.new(title: "Good morning, Badie"))

    expect(page).to have_css("h5", text: "Good morning, Badie")
  end

  it "renders subtitle when provided" do
    render_inline(described_class.new(title: "Hello", subtitle: "Here's your CRM snapshot for Tuesday, Feb 25"))

    expect(page).to have_text("Here's your CRM snapshot for Tuesday, Feb 25")
  end

  it "omits subtitle when nil" do
    render_inline(described_class.new(title: "Hello"))

    expect(page).to have_css("h5", text: "Hello")
    expect(page).not_to have_css("div[style*='color: #6C757D']")
  end

  it "renders actions slot content" do
    render_inline(described_class.new(title: "Hello")) do |bar|
      bar.with_actions { "<button>Click me</button>".html_safe }
    end

    expect(page).to have_button("Click me")
  end

  it "renders without actions slot" do
    render_inline(described_class.new(title: "Hello"))

    expect(page).to have_css("h5", text: "Hello")
    expect(page).to have_css(".d-flex.justify-content-between")
  end

  it "applies title styles from design tokens" do
    render_inline(described_class.new(title: "Greetings"))

    expect(page).to have_css("h5[style*='font-size: 20px']")
    expect(page).to have_css("h5[style*='color: #1B2A4A']")
  end
end
