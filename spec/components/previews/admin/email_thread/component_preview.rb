# frozen_string_literal: true

class Admin::EmailThread::ComponentPreview < ApplicationComponentPreview
  # @label Default Thread
  def default
    render Admin::EmailThread::Component.new(
      subject: "Re: Screening Request — Berlin Film Festival 2025",
      messages: [
        {
          sender: "Sarah Chen",
          timestamp: "Feb 21, 2025 10:42 AM",
          body: "Hi James, I wanted to follow up on the screening request we discussed last week. We have availability for the Thursday evening slot. Would that work for your team?",
          read: true
        },
        {
          sender: "James Park",
          timestamp: "Feb 21, 2025 11:15 AM",
          body: "Thanks Sarah! Thursday evening works perfectly. Can you send over the technical specs for the venue? We need to confirm the DCP format.",
          read: true,
          attachments: [
            { name: "venue_specs.pdf", size: "2.4 MB", type: "pdf" }
          ]
        },
        {
          sender: "Sarah Chen",
          timestamp: "Feb 22, 2025 9:30 AM",
          body: "Here are the specs. DCP is fine — they support both flat and scope. Let me know if you need anything else.",
          read: false,
          attachments: [
            { name: "technical_requirements.pdf", size: "1.1 MB", type: "pdf" },
            { name: "screen_schedule.xlsx", size: "156 KB", type: "xlsx" }
          ],
          staff_notes: "Follow up next week about rights availability for German territory."
        }
      ]
    )
  end

  # @label Single Message
  def single_message
    render Admin::EmailThread::Component.new(
      subject: "Introduction — New Distribution Contact",
      messages: [
        {
          sender: "Maria Lopez",
          timestamp: "Mar 1, 2025 2:00 PM",
          body: "Hi team, I'd like to introduce myself as the new acquisitions contact for Latin American distribution. Looking forward to working with you.",
          read: true
        }
      ]
    )
  end

  # @label With Staff Notes
  def with_staff_notes
    render Admin::EmailThread::Component.new(
      subject: "Re: Contract Renewal",
      messages: [
        {
          sender: "Tom Harris",
          timestamp: "Feb 28, 2025 3:45 PM",
          body: "Please review the attached renewal terms. We'd like to extend for another 2 years.",
          read: true,
          attachments: [
            { name: "renewal_terms.doc", size: "340 KB", type: "doc" }
          ],
          staff_notes: "Legal team approved the terms. Proceed with signature."
        }
      ]
    )
  end
end
