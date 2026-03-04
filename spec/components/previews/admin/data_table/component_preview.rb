# frozen_string_literal: true

class Admin::DataTable::ComponentPreview < ApplicationComponentPreview
  # @label Default (Contacts)
  def default
    render Admin::DataTable::Component.new(
      columns: [
        { key: :name, label: "Name", sortable: true },
        { key: :title, label: "Title", sortable: true },
        { key: :tags, label: "Tags" },
        { key: :last_engagement, label: "Last Engagement", sortable: true },
        { key: :account, label: "Account", sortable: true }
      ],
      rows: sample_contacts,
      sort_by: :name,
      sort_dir: :asc
    )
  end

  # @label Search Results
  def search_results
    render Admin::DataTable::Component.new(
      variant: :search_results,
      columns: [
        { key: :name, label: "Name", sortable: true },
        { key: :title, label: "Title" },
        { key: :match, label: "Match" }
      ],
      rows: [
        { name: "Jane Cooper", title: "VP of Acquisitions", match: "Email: jane@example.com", tags: [ { group: :buyers, label: "Buyers" } ] },
        { name: "Robert Fox", title: "Festival Director", match: "Company: Fox Films", tags: [ { group: :festivals, label: "Festivals" } ] }
      ]
    )
  end

  # @label Empty
  def empty
    render Admin::DataTable::Component.new(
      columns: [
        { key: :name, label: "Name", sortable: true },
        { key: :title, label: "Title" }
      ],
      rows: []
    )
  end

  private

  def sample_contacts
    [
      { name: "Jane Cooper", title: "VP of Acquisitions", tags: [ { group: :buyers, label: "Lead" } ], last_engagement: "2 days ago", account: "Acme Films", account_href: "#" },
      { name: "Robert Fox", title: "Festival Director", tags: [ { group: :festivals, label: "Director" } ], last_engagement: "1 week ago", account: "Berlin Film Fest", account_href: "#" },
      { name: "Emily Chen", title: "Press Manager", tags: [ { group: :press, label: "Contact" } ], last_engagement: "3 days ago", account: "Film Weekly", account_href: "#" },
      { name: "Marcus Johnson", title: "Sales Rep", tags: [ { group: :sellers, label: "Rep" } ], last_engagement: "Yesterday", account: "Global Distribution", account_href: "#" }
    ]
  end
end
