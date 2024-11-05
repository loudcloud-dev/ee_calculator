import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["text", "icon"];

  connect() {
    this.expanded = false;
  }

  toggle() {
    this.expanded = !this.expanded;

    this.textTarget.textContent = this.expanded ? "Show less" : "Show more";
    this.iconTarget.className = this.expanded ? "bi bi-arrow-up-short" : "bi bi-arrow-down-short";
  }
}
