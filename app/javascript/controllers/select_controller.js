import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["employee"];

  connect() {
    this.initializeTomSelect();
  }

  initializeTomSelect() {
    new TomSelect(this.element, {
      onItemAdd: () => this.validate(),
      onItemRemove: () => this.validate(),
    });
  }

  validate() {
    const selectedOptions = this.element.selectedOptions;
    const selectedCount = selectedOptions.length;

    const validationMessage = document.getElementById("participated_employees_validation");
    const submitBtn = document.getElementById("submit_btn");

    if (selectedCount < 2) {
      validationMessage.classList.add("d-block");
      submitBtn.classList.add("disabled");
      return false;
    } else {
      validationMessage.classList.remove("d-block");
      submitBtn.classList.remove("disabled");
      return true;
    }
  }
}
