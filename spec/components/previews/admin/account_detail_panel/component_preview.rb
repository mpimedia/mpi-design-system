# frozen_string_literal: true

class Admin::AccountDetailPanel::ComponentPreview < ApplicationComponentPreview
  # @label Default
  def default
    render Admin::AccountDetailPanel::Component.new(
      name: "Acme Films",
      account_type: "Distributor",
      account_type_color: :primary,
      contacts: [
        { name: "Jane Cooper", title: "VP of Acquisitions", path: "#" },
        { name: "Robert Fox", title: "Sales Director", path: "#" },
        { name: "Emily Chen", title: "Marketing Lead", path: "#" }
      ],
      email: "info@acmefilms.com",
      phone: "+1 (555) 020-0200",
      location: "Los Angeles, CA",
      created_date: "Jan 10, 2025",
      owner: { name: "Sarah Williams", path: "#" }
    )
  end

  # @label Minimal
  def minimal
    render Admin::AccountDetailPanel::Component.new(
      name: "Berlin Film Fest",
      account_type: "Festival",
      account_type_color: :success
    )
  end

  # @label With Many Contacts
  def many_contacts
    render Admin::AccountDetailPanel::Component.new(
      name: "Global Distribution Inc.",
      account_type: "Sales Agency",
      account_type_color: :warning,
      contacts: [
        { name: "Marcus Johnson", title: "Sales Rep", path: "#" },
        { name: "Sarah Williams", title: "Account Manager", path: "#" },
        { name: "David Kim", title: "VP Sales", path: "#" },
        { name: "Lisa Park", title: "Operations", path: "#" },
        { name: "Tom Wilson", title: "Finance", path: "#" }
      ],
      email: "sales@globaldist.com",
      phone: "+1 (555) 030-0300",
      location: "London, UK",
      created_date: "Mar 15, 2024",
      owner: { name: "Jane Cooper", path: "#" }
    )
  end
end
