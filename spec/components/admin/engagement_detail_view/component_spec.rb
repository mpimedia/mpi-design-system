# frozen_string_literal: true

require "spec_helper"

RSpec.describe Admin::EngagementDetailView::Component, type: :component do
  it "renders three-panel layout with breadcrumb bar, main, and sidebar columns" do
    render_inline(described_class.new) do |view|
      view.with_breadcrumb { "Breadcrumb here".html_safe }
      view.with_main_content { "Main content here".html_safe }
      view.with_sidebar { "Sidebar here".html_safe }
    end

    expect(page).to have_text("Breadcrumb here")
    expect(page).to have_text("Main content here")
    expect(page).to have_text("Sidebar here")
  end

  it "renders breadcrumb in a white bar with bottom border" do
    render_inline(described_class.new) do |view|
      view.with_breadcrumb { "Nav".html_safe }
    end

    expect(page).to have_css("div[style*='background: #fff'][style*='border-bottom: 1px solid #DEE2E6']",
                             text: "Nav")
  end

  it "renders main content in col-md-8" do
    render_inline(described_class.new) do |view|
      view.with_main_content { "<div id='email-body'>Email content</div>".html_safe }
    end

    expect(page).to have_css("div.col-md-8 #email-body", text: "Email content")
  end

  it "renders sidebar in col-md-4" do
    render_inline(described_class.new) do |view|
      view.with_sidebar { "<div id='linked'>Linked records</div>".html_safe }
    end

    expect(page).to have_css("div.col-md-4 #linked", text: "Linked records")
  end

  it "renders main panel with white card styling" do
    render_inline(described_class.new) do |view|
      view.with_main_content { "Content".html_safe }
    end

    expect(page).to have_css("div[style*='background: #fff'][style*='border-radius: 8px']",
                             text: "Content")
  end

  it "renders sidebar panel with white card styling" do
    render_inline(described_class.new) do |view|
      view.with_sidebar { "Sidebar".html_safe }
    end

    expect(page).to have_css("div.col-md-4 div[style*='background: #fff'][style*='border-radius: 8px']",
                             text: "Sidebar")
  end

  it "renders container with light gray background" do
    render_inline(described_class.new)

    expect(page).to have_css("div[style*='background: #F5F7FA']")
  end

  it "hides breadcrumb bar when no breadcrumb slot" do
    render_inline(described_class.new) do |view|
      view.with_main_content { "Content only".html_safe }
    end

    expect(page).not_to have_css("div[style*='border-bottom: 1px solid #DEE2E6'][style*='padding: 0 24px']")
  end

  it "renders default header bar when title is provided" do
    render_inline(described_class.new(title: "Follow-up Email", date: "Feb 25, 2026", status: "Sent"))

    expect(page).to have_css("h4", text: "Follow-up Email")
    expect(page).to have_css("span[style*='color: #2E75B6']", text: "EMAIL")
    expect(page).to have_text("Feb 25, 2026")
    expect(page).to have_text("Sent")
  end

  it "renders custom header bar slot" do
    render_inline(described_class.new) do |view|
      view.with_header_bar { "<div id='custom-header'>Custom Header</div>".html_safe }
      view.with_main_content { "Content".html_safe }
    end

    expect(page).to have_css("#custom-header", text: "Custom Header")
  end

  it "renders tabs slot" do
    render_inline(described_class.new) do |view|
      view.with_tabs { "<nav id='tabs'>Content / Thread / Activity</nav>".html_safe }
      view.with_main_content { "Content".html_safe }
    end

    expect(page).to have_css("#tabs", text: "Content / Thread / Activity")
  end

  it "defaults to email engagement type" do
    component = described_class.new
    expect(component.instance_variable_get(:@engagement_type)).to eq(:email)
  end

  it "accepts meeting engagement type" do
    component = described_class.new(engagement_type: :meeting)
    expect(component.instance_variable_get(:@engagement_type)).to eq(:meeting)
  end

  it "falls back to email for invalid engagement type" do
    component = described_class.new(engagement_type: :invalid)
    expect(component.instance_variable_get(:@engagement_type)).to eq(:email)
  end

  it "composes with BreadcrumbNav in breadcrumb slot" do
    breadcrumb_html = render_inline(
      Admin::BreadcrumbNav::Component.new(
        back_path: "/crm/engagements",
        back_label: "Engagements",
        current_title: "Email: Follow-up"
      )
    ).to_html

    render_inline(described_class.new) do |view|
      view.with_breadcrumb { breadcrumb_html.html_safe }
      view.with_main_content { "Content".html_safe }
    end

    expect(page).to have_css("nav[aria-label='Breadcrumb']")
    expect(page).to have_text("Engagements")
    expect(page).to have_text("Email: Follow-up")
  end

  it "composes with EmailThread in main content slot" do
    thread_html = render_inline(
      Admin::EmailThread::Component.new(
        subject: "Re: Screening",
        messages: [
          { sender: "Sarah Chen", timestamp: "Feb 21", body: "Hello", read: true }
        ]
      )
    ).to_html

    render_inline(described_class.new) do |view|
      view.with_main_content { thread_html.html_safe }
    end

    expect(page).to have_text("Re: Screening")
    expect(page).to have_text("Sarah Chen")
  end

  it "renders all slots simultaneously" do
    render_inline(described_class.new) do |view|
      view.with_breadcrumb { "<nav>Back</nav>".html_safe }
      view.with_header_bar { "<div>Header</div>".html_safe }
      view.with_tabs { "<nav>Tabs</nav>".html_safe }
      view.with_main_content { "<div>Email body</div>".html_safe }
      view.with_sidebar { "<div>Contacts list</div>".html_safe }
    end

    expect(page).to have_text("Back")
    expect(page).to have_text("Header")
    expect(page).to have_text("Tabs")
    expect(page).to have_text("Email body")
    expect(page).to have_text("Contacts list")
  end

  it "renders empty layout without errors" do
    render_inline(described_class.new)

    expect(page).to have_css("div[style*='background: #F5F7FA']")
  end
end
