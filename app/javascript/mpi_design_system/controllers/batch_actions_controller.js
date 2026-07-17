import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="mpi--batch-actions"
//
// Drives batch selection for MpiDesignSystem::Admin::TableForIndex: a toggle-all header
// checkbox, per-row checkboxes, and action buttons that enable only when a row is selected.
// Behavior-only — it flips `checked`/`disabled`, sets no styles. Generalized from SFA's
// working admin--batch-actions controller (the one proven live in the MPI apps).
export default class extends Controller {
  static targets = ["checkbox", "toggleCheckbox", "actionButton"]

  connect() {
    this.checkCheckboxes()
  }

  toggleCheckboxes(event) {
    if (event.target.checked) {
      this._updateAllCheckboxes(true)
      this._enableActionButtons()
    } else {
      this._updateAllCheckboxes(false)
      this._disableActionButtons()
    }
  }

  checkCheckboxes() {
    this.toggleCheckboxTarget.checked = false

    if (this.checkboxTargets.some((checkbox) => checkbox.checked)) {
      this._enableActionButtons()

      if (this.checkboxTargets.every((checkbox) => checkbox.checked)) {
        this.toggleCheckboxTarget.checked = true
      }
    } else {
      this._disableActionButtons()
    }
  }

  _updateAllCheckboxes(checked) {
    this.checkboxTargets.forEach((checkbox) => {
      checkbox.checked = checked
    })
  }

  _enableActionButtons() {
    this.actionButtonTargets.forEach((button) => {
      button.disabled = false
    })
  }

  _disableActionButtons() {
    this.actionButtonTargets.forEach((button) => {
      button.disabled = true
    })
  }
}
