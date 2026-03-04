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
        { name: "Jane Cooper", title: "VP of Acquisitions", match: "Email: jane@example.com", tags: [ { group: :buyers } ] },
        { name: "Robert Fox", title: "Festival Director", match: "Company: Fox Films", tags: [ { group: :festivals } ] }
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
      { name: "Jane Cooper", title: "VP of Acquisitions", tags: [ { group: :buyers, role: "Lead" } ], last_engagement: "2 days ago", account_name: "Acme Films", account_path: "#" },
      { name: "Robert Fox", title: "Festival Director", tags: [ { group: :festivals, role: "Director" } ], last_engagement: "1 week ago", account_name: "Berlin Film Fest", account_path: "#" },
      { name: "Emily Chen", title: "Press Manager", tags: [ { group: :press, role: "Contact" } ], last_engagement: "3 days ago", account_name: "Film Weekly", account_path: "#" },
      { name: "Marcus Johnson", title: "Sales Rep", tags: [ { group: :sellers, role: "Rep" } ], last_engagement: "Yesterday", account_name: "Global Distribution", account_path: "#" }
    ]
  end
end
