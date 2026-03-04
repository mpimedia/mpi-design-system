# frozen_string_literal: true

module Admin
  module EmailThread
    class Component < ViewComponent::Base
      # @param messages [Array<Hash>] Each message hash:
      #   - sender [String] Sender name
      #   - timestamp [String] Display timestamp (e.g., "Feb 21, 2025 10:42 AM")
      #   - body [String] Message body text (HTML-safe)
      #   - attachments [Array<Hash>] Each: { name: String, size: String, type: String }
      #   - staff_notes [String] Internal staff note (rendered in amber highlight)
      #   - read [Boolean] Whether the message has been read (default: true)
      # @param subject [String] Email thread subject line
      def initialize(messages:, subject: nil)
        @messages = messages || []
        @subject = subject
      end

      private

      def subject_styles
        "font-size: 18px; font-weight: 600; color: #1B2A4A; margin-bottom: 16px;"
      end

      def message_card_styles(read)
        border_color = read ? "#DEE2E6" : "#2E75B6"
        [
          "background: #fff",
          "border: 1px solid #{border_color}",
          "border-radius: 8px",
          "padding: 16px 20px",
          "margin-bottom: 12px"
        ].join("; ")
      end

      def sender_styles
        "font-weight: 600; color: #1B2A4A; font-size: 14px;"
      end

      def timestamp_styles
        "font-size: 12px; color: #6C757D;"
      end

      def body_styles
        "font-size: 14px; color: #1B2A4A; line-height: 1.6; margin-top: 8px;"
      end

      def unread_dot_styles
        [
          "width: 8px",
          "height: 8px",
          "border-radius: 50%",
          "background: #2E75B6",
          "display: inline-block",
          "flex-shrink: 0"
        ].join("; ")
      end

      def staff_note_styles
        [
          "background: #FFF8E1",
          "border: 1px solid #FFE082",
          "border-radius: 6px",
          "padding: 10px 14px",
          "font-size: 13px",
          "color: #6D4C00",
          "margin-top: 8px"
        ].join("; ")
      end

      def staff_note_label_styles
        "font-weight: 600; font-size: 11px; text-transform: uppercase; letter-spacing: 0.04em; color: #9E7600;"
      end

      def attachment_styles
        [
          "display: inline-flex",
          "align-items: center",
          "gap: 6px",
          "background: #F8F9FA",
          "border: 1px solid #DEE2E6",
          "border-radius: 6px",
          "padding: 6px 10px",
          "font-size: 12px",
          "color: #1B2A4A",
          "text-decoration: none"
        ].join("; ")
      end

      def attachment_size_styles
        "color: #6C757D; font-size: 11px;"
      end

      def attachment_icon(type)
        case type&.downcase
        when "pdf" then "file-earmark-pdf"
        when "xls", "xlsx" then "file-earmark-spreadsheet"
        when "doc", "docx" then "file-earmark-word"
        when "jpg", "jpeg", "png", "gif" then "file-earmark-image"
        else "file-earmark"
        end
      end

      def message_read?(message)
        message.fetch(:read, true)
      end
    end
  end
end
