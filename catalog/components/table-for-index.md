# TableForIndex

**Category:** Component
**Issue:** harvest#692 (shared-engine adoption epic)
**Status:** Approved

## Description

Neutral, slot/block-based admin **index & association listing** table. Generalizes the
byte-identical local `Admin::TableForIndex` shared by the MPI apps (Optimus/Garden/Harvest) into
the design system, so all consumers share one table primitive instead of drifting copies.

This is deliberately **not** `DataTable` — `DataTable` is a fixed-schema CRM component (contacts /
search results, `:name`/`:tags`/`:account`/`:status`). `TableForIndex` hosts arbitrary admin
listings: each cell is host-supplied HTML, so the gem takes **no** Ransack/Pundit/Pagy/route-helper
dependency.

## Design Decisions

- **Block-first cells:** `table.with_column(header) { |record| … }` — the block returns arbitrary
  `SafeBuffer` HTML (links, `mail_to`, action buttons, badges, multi-value). This is the default
  and covers everything app-coupled.
- **Opt-in helper cells:** `table.with_column(header, value:, cell: :text|:boolean|:date)` for pure
  presentation. `:boolean` renders the filled `Badge` (`text-bg-success`/`text-bg-secondary`).
- **Presentation-only column keywords:** `align:` (`:start`/`:center`/`:end`), `nowrap:`, `width:`
  (`:sm`/`:md`/`:lg`, whitelisted → `w-25`/`w-50`/`w-75`). All pure Bootstrap utilities — **no
  inline hex, no `[style]`**.
- **Headers:** a plain string (escaped) or pre-rendered HTML (e.g. a Ransack `sort_link`) emitted
  verbatim.
- **First-class sortable headers (Ransack-free):** a column opts in with `sortable:`/`sort_key:`;
  the table renders the clickable link, caret, and `aria-sort` from a host-supplied
  `sort_url: ->(key, dir) { … }` lambda + `current_sort_key:`/`current_sort_dir:`.
- **Empty state:** renders the shipped `EmptyState` with a title-derived heading and a monotonic
  heading level (`:h5` under a `title:` section, `:h3` for a bare index).
- **Batch selection:** opt-in `batch:` checkbox column + `BatchActionButton`/`BatchActionModalButton`
  slots, driven by the `mpi--batch-actions` Stimulus controller. The consuming app owns the
  `<form>`; the gem owns the checkbox UI, the slots, and the controller.
- **Table shell:** `table table-striped table-hover table-sm` + `thead.table-dark` — preserved from
  the apps so adoption is visually identical.

## States

| State | Description |
|---|---|
| Populated | Striped, hoverable rows; optional batch checkbox column |
| Empty | Renders `EmptyState` (no table, no batch toolbar) |
| Sortable header (active) | Clickable link with ↑/↓ caret and `aria-sort` |
| Sortable header (inactive) | Clickable link with ↕ caret, `aria-sort="none"` |

## Props / API

```ruby
# MpiDesignSystem::Admin::TableForIndex::Component
class MpiDesignSystem::Admin::TableForIndex::Component < ViewComponent::Base
  renders_many :columns              # via with_column(header, **opts, &block)
  renders_many :batch_action_buttons        # BatchActionButton::Component
  renders_many :batch_action_modal_buttons  # BatchActionModalButton::Component

  # @param data [Enumerable] rows (AR relation or array)
  # @param title [String, nil] section heading (<h4>) + drives empty-state heading/level
  # @param batch [Boolean] opt-in checkbox-selection column (needs an app <form> + mpi--batch-actions)
  # @param empty_heading [String, nil] override the derived empty-state heading
  # @param empty_icon [String] Bootstrap icon for the empty state (default "bi-inbox")
  # @param sort_url [Proc, nil] ->(key, dir) { host-built href } for first-class sortable columns
  # @param current_sort_key [Symbol, String, nil] the currently-sorted key
  # @param current_sort_dir [Symbol] :asc (default) or :desc
end

# MpiDesignSystem::Admin::TableForIndexColumn::Component
#   initialize(header = nil, value: nil, cell: :text, align: nil, nowrap: false,
#              width: nil, sortable: false, sort_key: nil, &block)
```

## Batch Contract

The gem renders the checkbox UI, the button/modal slots, and ships the `mpi--batch-actions`
Stimulus controller (registered by `registerMpiControllers`). The **consuming app** wraps the table
in a `<form>` (submit URL + `data-controller="mpi--batch-actions"`), owns the route, and reads
`params[:ids]` dispatching on the submit button's `name`, with its own authorization. Batch is inert
until a consumer wires the gem's JS substrate (esbuild alias + `registerMpiControllers`).

## Usage Guidelines

- **Use** for admin index tables and show-page association tables.
- **Use** the block form for any cell that needs a link, a policy-gated action button, or
  conditional/multi-value markup.
- **Do not** reach for `DataTable` for admin listings — that is the CRM contacts/search component.
- **Do not** add inline hex or custom classes — Bootstrap utilities only.
- Combine with `Pagination` below and a filter form above (both app-owned).
