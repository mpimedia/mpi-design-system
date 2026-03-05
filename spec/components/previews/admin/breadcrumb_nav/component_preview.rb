# frozen_string_literal: true

class Admin::BreadcrumbNav::ComponentPreview < ApplicationComponentPreview
  # @label Default
  def default
    render Admin::BreadcrumbNav::Component.new(
      back_path: "/crm/engagements",
      back_label: "Engagements",
      current_title: "Email: Follow-up on screening request"
    )
  end

  # @label Contact Detail
  def contact_detail
    render Admin::BreadcrumbNav::Component.new(
      back_path: "/crm/contacts",
      back_label: "Contacts",
      current_title: "Sarah Chen"
    )
  end

  # @label Account Detail
  def account_detail
    render Admin::BreadcrumbNav::Component.new(
      back_path: "/crm/accounts",
      back_label: "Accounts",
      current_title: "Sony Pictures Classics"
    )
  end
end
