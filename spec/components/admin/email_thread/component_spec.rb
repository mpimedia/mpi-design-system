# frozen_string_literal: true

require "spec_helper"

RSpec.describe Admin::EmailThread::Component, type: :component do
  let(:messages) do
    [
      {
        sender: "Sarah Chen",
        timestamp: "Feb 21, 2025 10:42 AM",
        body: "Hi, I wanted to follow up on the screening request for the upcoming festival.",
        read: true
      },
      {
        sender: "James Park",
        timestamp: "Feb 21, 2025 11:15 AM",
        body: "Thanks Sarah. Let me check with the team and get back to you.",
        read: false
      }
    ]
  end

  it "renders subject when provided" do
    render_inline(described_class.new(messages: messages, subject: "Re: Screening Request"))

    expect(page).to have_css("div[style*='font-size: 18px'][style*='font-weight: 600']",
                             text: "Re: Screening Request")
  end

  it "renders without subject" do
    render_inline(described_class.new(messages: messages))

    expect(page).not_to have_css("div[style*='font-size: 18px']")
  end

  it "renders sender avatars" do
    render_inline(described_class.new(messages: messages))

    expect(page).to have_css("span.rounded-circle", text: "SC")
    expect(page).to have_css("span.rounded-circle", text: "JP")
  end

  it "renders sender names" do
    render_inline(described_class.new(messages: messages))

    expect(page).to have_css("span[style*='font-weight: 600']", text: "Sarah Chen")
    expect(page).to have_css("span[style*='font-weight: 600']", text: "James Park")
  end

  it "renders timestamps" do
    render_inline(described_class.new(messages: messages))

    expect(page).to have_text("Feb 21, 2025 10:42 AM")
    expect(page).to have_text("Feb 21, 2025 11:15 AM")
  end

  it "renders message body text" do
    render_inline(described_class.new(messages: messages))

    expect(page).to have_text("I wanted to follow up on the screening request")
    expect(page).to have_text("Let me check with the team")
  end

  it "renders unread indicator for unread messages" do
    render_inline(described_class.new(messages: messages))

    expect(page).to have_css("span[aria-label='Unread'][style*='background: #2E75B6']")
  end

  it "uses blue border for unread messages" do
    render_inline(described_class.new(messages: messages))

    expect(page).to have_css("article[style*='border: 1px solid #2E75B6']")
  end

  it "uses gray border for read messages" do
    render_inline(described_class.new(messages: messages))

    expect(page).to have_css("article[style*='border: 1px solid #DEE2E6']")
  end

  it "renders attachments with file icon" do
    messages_with_attachments = [
      {
        sender: "Sarah Chen",
        timestamp: "Feb 21, 2025",
        body: "Please see attached.",
        attachments: [
          { name: "schedule.pdf", size: "2.4 MB", type: "pdf" },
          { name: "contacts.xlsx", size: "156 KB", type: "xlsx" }
        ]
      }
    ]
    render_inline(described_class.new(messages: messages_with_attachments))

    expect(page).to have_text("schedule.pdf")
    expect(page).to have_text("2.4 MB")
    expect(page).to have_css("i.bi.bi-file-earmark-pdf")
    expect(page).to have_text("contacts.xlsx")
    expect(page).to have_css("i.bi.bi-file-earmark-spreadsheet")
  end

  it "renders staff notes in amber highlight" do
    messages_with_notes = [
      {
        sender: "James Park",
        timestamp: "Feb 22, 2025",
        body: "Sounds good.",
        staff_notes: "Follow up next week about rights availability."
      }
    ]
    render_inline(described_class.new(messages: messages_with_notes))

    expect(page).to have_css("div[style*='background: #FFF8E1']", text: /Follow up next week/)
    expect(page).to have_text("Staff Note")
  end

  it "defaults messages to read" do
    messages_no_read = [ { sender: "Test User", timestamp: "Jan 1", body: "Hello" } ]
    render_inline(described_class.new(messages: messages_no_read))

    expect(page).not_to have_css("span[aria-label='Unread']")
  end

  it "renders empty thread without errors" do
    render_inline(described_class.new(messages: []))

    expect(page).to have_css("div.email-thread")
  end
end
