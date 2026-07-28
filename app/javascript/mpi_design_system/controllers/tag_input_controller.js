import { Controller } from "@hotwired/stimulus"

// Mirror of `TagChip::Component::GROUP_VARIANTS` (Ruby cannot be read from here, so
// the two must be kept in step — the component spec pins the Ruby side, and the
// Stimulus feature spec pins what this renders).
//
// This REPLACES a frozen hex map keyed on a stale vocabulary — `buyers`, `press`,
// `festivals`, `sellers`, `institutional`, `organizations` — which never matched the
// group names the server actually sends via `available_tags_value` (`production`,
// `distribution`, `finance`, `press_festival`, `internal`, `vendors`, `outreach`).
// Only `internal` overlapped, so six of the seven groups silently fell through to the
// grey fallback: a tag added after page load painted grey while the same tag rendered
// by the server painted its category colour. Keying on the vocabulary the server sends
// fixes that, and emitting semantic classes keeps interactively-added chips
// theme-adaptive and AA-clean like their server-rendered counterparts. (#168)
const GROUP_VARIANTS = {
  press_festival: "primary",
  production: "primary",
  vendors: "primary",
  outreach: "success",
  finance: "warning",
  distribution: "danger",
  internal: "secondary"
}

const variantFor = group => GROUP_VARIANTS[group] || "secondary"

export default class extends Controller {
  static targets = ["input", "dropdown", "selectedTags", "wrapper", "tag"]
  static values = {
    availableTags: Array,
    fieldName: String
  }

  connect() {
    this.activeIndex = -1
    this._onClickOutside = this.onClickOutside.bind(this)
    document.addEventListener("click", this._onClickOutside)
  }

  disconnect() {
    document.removeEventListener("click", this._onClickOutside)
  }

  filter() {
    const query = this.inputTarget.value.trim().toLowerCase()
    if (query.length === 0) {
      this.hideDropdown()
      return
    }

    const selected = this.selectedTagLabels()
    const matches = this.availableTagsValue.filter(tag =>
      tag.label.toLowerCase().includes(query) && !selected.includes(tag.label)
    )

    this.renderDropdown(matches)
  }

  showDropdown() {
    const query = this.inputTarget.value.trim().toLowerCase()
    if (query.length > 0) {
      this.filter()
    }
  }

  hideDropdown() {
    this.dropdownTarget.style.display = "none"
    this.activeIndex = -1
  }

  onKeydown(event) {
    const items = this.dropdownTarget.querySelectorAll("[role='option']")

    switch (event.key) {
      case "ArrowDown":
        event.preventDefault()
        if (this.dropdownTarget.style.display === "none") {
          this.filter()
          return
        }
        this.activeIndex = Math.min(this.activeIndex + 1, items.length - 1)
        this.highlightItem(items)
        break
      case "ArrowUp":
        event.preventDefault()
        this.activeIndex = Math.max(this.activeIndex - 1, 0)
        this.highlightItem(items)
        break
      case "Enter":
        event.preventDefault()
        if (this.activeIndex >= 0 && items[this.activeIndex]) {
          const label = items[this.activeIndex].dataset.tagLabel
          const group = items[this.activeIndex].dataset.tagGroup
          this.selectTag(label, group)
        }
        break
      case "Escape":
        this.hideDropdown()
        break
      case "Backspace":
        if (this.inputTarget.value === "" && this.tagTargets.length > 0) {
          this.removeLastTag()
        }
        break
    }
  }

  selectTag(label, group) {
    this.addTagChip(label, group)
    this.inputTarget.value = ""
    this.hideDropdown()
    this.inputTarget.focus()
  }

  removeTag(event) {
    const tagEl = event.currentTarget.closest("[data-mpi--tag-input-target='tag']")
    if (!tagEl) return

    const hiddenInput = tagEl.nextElementSibling
    if (hiddenInput && hiddenInput.type === "hidden") {
      hiddenInput.remove()
    }
    tagEl.remove()
  }

  removeLastTag() {
    const tags = this.tagTargets
    if (tags.length === 0) return

    const lastTag = tags[tags.length - 1]
    const hiddenInput = lastTag.nextElementSibling
    if (hiddenInput && hiddenInput.type === "hidden") {
      hiddenInput.remove()
    }
    lastTag.remove()
  }

  onClickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.hideDropdown()
    }
  }

  // Private

  selectedTagLabels() {
    return this.tagTargets.map(el => el.dataset.tagLabel)
  }

  renderDropdown(matches) {
    if (matches.length === 0) {
      this.hideDropdown()
      return
    }

    this.activeIndex = -1

    this.dropdownTarget.innerHTML = matches.map(tag => {
      const variant = variantFor(tag.group)
      // The dropdown panel paints a hardcoded white background (`dropdown_styles`), so
      // the option keeps the frozen navy: 14.22:1 on that fixed surface in both colour
      // modes, where an adaptive `text-body` would drop to 1.30:1 in dark mode. The
      // category DOT below is a solid semantic fill, which is a fixed hue and therefore
      // safe on white. Converting the panel itself is ISS#142 §3. (#168)
      return `<div role="option"
                   style="padding: 8px 12px; cursor: pointer; font-size: 13px; color: #1B2A4A;"
                   data-tag-label="${this.escapeHtml(tag.label)}"
                   data-tag-group="${this.escapeHtml(tag.group)}"
                   data-action="click->mpi--tag-input#onDropdownItemClick mouseover->mpi--tag-input#onDropdownItemHover">
        <span class="d-inline-block bg-${variant}" style="width: 8px; height: 8px; border-radius: 50%; margin-right: 8px;"></span>
        ${this.escapeHtml(tag.label)}
      </div>`
    }).join("")

    this.dropdownTarget.style.display = "block"
  }

  onDropdownItemClick(event) {
    const item = event.currentTarget
    this.selectTag(item.dataset.tagLabel, item.dataset.tagGroup)
  }

  // A FIXED light neutral, deliberately — the dropdown panel paints a hardcoded white
  // background and its option text is frozen navy, so the hover surface has to be frozen
  // too or the pair desynchronises. An earlier revision made this
  // `var(--bs-tertiary-bg)`, which resolves to ~#2B3035 in dark mode and left navy text
  // at 1.07:1 on a hovered option — fixing the resting state while breaking the
  // interactive one. Navy on this neutral measures 13.25:1. The whole dropdown converts
  // together, or not at all; doing that is ISS#142 §3. (#168)
  static ACTIVE_SURFACE = "#F5F7FA"

  onDropdownItemHover(event) {
    const items = this.dropdownTarget.querySelectorAll("[role='option']")
    items.forEach(el => el.style.background = "")
    event.currentTarget.style.background = this.constructor.ACTIVE_SURFACE
    this.activeIndex = Array.from(items).indexOf(event.currentTarget)
  }

  highlightItem(items) {
    items.forEach((el, i) => {
      el.style.background = i === this.activeIndex ? this.constructor.ACTIVE_SURFACE : ""
    })
    if (items[this.activeIndex]) {
      items[this.activeIndex].scrollIntoView({ block: "nearest" })
    }
  }

  addTagChip(label, group) {
    const variant = variantFor(group)

    const chip = document.createElement("span")
    // Must match the server-rendered chip in `component.html.erb` exactly, so a tag
    // added after load is indistinguishable from one present at load. (#168)
    chip.className = `d-inline-flex align-items-center gap-1 fw-semibold rounded-pill bg-${variant}-subtle text-${variant}-emphasis`
    chip.style.cssText = "font-size: 13px; padding: 0.25em 0.75em; line-height: 1.4;"
    chip.setAttribute("data-mpi--tag-input-target", "tag")
    chip.dataset.tagLabel = label
    chip.dataset.tagGroup = group
    chip.innerHTML = `${this.escapeHtml(label)}
      <button type="button"
              class="text-reset bg-transparent border-0"
              style="padding: 0; font-size: inherit; line-height: 1; cursor: pointer;"
              aria-label="Remove ${this.escapeHtml(label)}"
              data-action="mpi--tag-input#removeTag">
        <i class="bi bi-x-lg" aria-hidden="true"></i>
      </button>`

    const hidden = document.createElement("input")
    hidden.type = "hidden"
    hidden.name = this.fieldNameValue
    hidden.value = label

    this.selectedTagsTarget.appendChild(chip)
    this.selectedTagsTarget.appendChild(hidden)
  }

  escapeHtml(text) {
    const div = document.createElement("div")
    div.textContent = text
    return div.innerHTML
  }
}
