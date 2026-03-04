import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "dropdown", "selectedTags", "wrapper", "tag"]
  static values = {
    availableTags: Array,
    selectedTags: Array,
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
    const tagEl = event.currentTarget.closest("[data-tag-input-target='tag']")
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
    const groupColors = {
      buyers: { color: "#E8733A", bg: "#FEF3EC" },
      press: { color: "#2DA67E", bg: "#ECF8F4" },
      festivals: { color: "#2E75B6", bg: "#EBF3FB" },
      sellers: { color: "#8B5CF6", bg: "#F3EFFE" },
      institutional: { color: "#D97706", bg: "#FEF9EC" },
      organizations: { color: "#6366F1", bg: "#EEEFFE" },
      internal: { color: "#64748B", bg: "#F1F5F9" }
    }

    this.dropdownTarget.innerHTML = matches.map(tag => {
      const colors = groupColors[tag.group] || groupColors.internal
      return `<div role="option"
                   style="padding: 8px 12px; cursor: pointer; font-size: 13px; color: #1B2A4A;"
                   data-tag-label="${this.escapeHtml(tag.label)}"
                   data-tag-group="${this.escapeHtml(tag.group)}"
                   data-action="click->tag-input#onDropdownItemClick mouseenter->tag-input#onDropdownItemHover">
        <span style="display: inline-block; width: 8px; height: 8px; border-radius: 50%; background: ${colors.color}; margin-right: 8px;"></span>
        ${this.escapeHtml(tag.label)}
      </div>`
    }).join("")

    this.dropdownTarget.style.display = "block"
  }

  onDropdownItemClick(event) {
    const item = event.currentTarget
    this.selectTag(item.dataset.tagLabel, item.dataset.tagGroup)
  }

  onDropdownItemHover(event) {
    const items = this.dropdownTarget.querySelectorAll("[role='option']")
    items.forEach(el => el.style.background = "")
    event.currentTarget.style.background = "#F5F7FA"
    this.activeIndex = Array.from(items).indexOf(event.currentTarget)
  }

  highlightItem(items) {
    items.forEach((el, i) => {
      el.style.background = i === this.activeIndex ? "#F5F7FA" : ""
    })
    if (items[this.activeIndex]) {
      items[this.activeIndex].scrollIntoView({ block: "nearest" })
    }
  }

  addTagChip(label, group) {
    const groupColors = {
      buyers: { color: "#E8733A", bg: "#FEF3EC" },
      press: { color: "#2DA67E", bg: "#ECF8F4" },
      festivals: { color: "#2E75B6", bg: "#EBF3FB" },
      sellers: { color: "#8B5CF6", bg: "#F3EFFE" },
      institutional: { color: "#D97706", bg: "#FEF9EC" },
      organizations: { color: "#6366F1", bg: "#EEEFFE" },
      internal: { color: "#64748B", bg: "#F1F5F9" }
    }

    const colors = groupColors[group] || groupColors.internal

    const chip = document.createElement("span")
    chip.className = "d-inline-flex align-items-center gap-1 fw-semibold"
    chip.style.cssText = `color: ${colors.color}; background-color: ${colors.bg}; font-size: 13px; padding: 0.25em 0.75em; border-radius: 999px; line-height: 1.4;`
    chip.dataset.tagInputTarget = "tag"
    chip.dataset.tagLabel = label
    chip.dataset.tagGroup = group
    chip.innerHTML = `${this.escapeHtml(label)}
      <button type="button"
              style="color: ${colors.color}; opacity: 0.6; background: none; border: none; padding: 0; font-size: inherit; line-height: 1; cursor: pointer;"
              aria-label="Remove ${this.escapeHtml(label)}"
              data-action="tag-input#removeTag">
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
