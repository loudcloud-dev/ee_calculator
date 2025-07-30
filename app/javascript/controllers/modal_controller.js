import { Controller } from "@hotwired/stimulus";
import * as bootstrap from "bootstrap";

// Connects to data-controller="modal"
export default class extends Controller {
  static targets = ["modal"];

  connect() {
    this.modal = new bootstrap.Modal(this.modalTarget);
  }

  open() {
    this.modal.show();
  }

  close() {
    this.modal.hide();
  }
}
