import { Controller } from "@hotwired/stimulus";
import * as bootstrap from "bootstrap";

// Connects to data-controller="tooltip"
export default class extends Controller {
  connect() {
    this.initializeTooltips();
  }

  initializeTooltips() {
    const tooltipTriggerList = document.querySelectorAll(
      '[data-bs-toggle="tooltip"]',
    );
    const tooltipList = [...tooltipTriggerList].map(
      (tooltipTriggerEl) => new bootstrap.Tooltip(tooltipTriggerEl),
    );
  }
}
