import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    if (!this.element.tomselect) {
      this.initializeTomSelect();
    }
  }

  disconnect() {
    if (this.element.tomselect) {
      this.element.tomselect.destroy();
    }
  }

  initializeTomSelect() {
    this.element.tomselect = new TomSelect(this.element, {});
  }
}
