import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.preserveExpandedState()
  }

  preserveExpandedState() {
    document.addEventListener("turbo:submit-start", (event) => {
      if (event.target.action?.includes("/efforts")) {
        const form = event.target
        const parentIdField = form.querySelector('input[name="parent_id"], input[id="effort_parent_id"]')
        const parentId = parentIdField?.value || null
        this.saveExpandedState(parentId)
      }
    })

    document.addEventListener("turbo:submit-end", (event) => {
      if (event.target.action?.includes("/efforts")) {
        setTimeout(() => {
          this.restoreExpandedState()
        }, 10)
      }
    })
  }

  saveExpandedState(parentId) {
    const expandedIds = []
    if (parentId !== null) {
      expandedIds.push(parentId)
    }
    const detailsElements = document.querySelectorAll("#effort_tree details[open]")

    detailsElements.forEach(details => {
      const effortId = details.dataset.effortId
      if (effortId) {
        expandedIds.push(effortId)
      }
    })

    sessionStorage.setItem("effort_tree_expanded", JSON.stringify(expandedIds))
  }

  restoreExpandedState() {
    const expandedIds = JSON.parse(sessionStorage.getItem("effort_tree_expanded") || "[]")

    expandedIds.forEach(effortId => {
      const detailsElement = document.querySelector(`#effort_tree details[data-effort-id="${effortId}"]`)
      if (detailsElement) {
        detailsElement.open = true
      }
    })
  }
}