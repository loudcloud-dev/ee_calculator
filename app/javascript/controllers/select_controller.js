import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["employee"];

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
    this.element.tomselect = new TomSelect(this.element, {
      onItemAdd: function() {
        this.setTextboxValue('');
        this.refreshOptions();
      },
      onDropdownClose: () => this.validate(),
      onItemRemove: () => this.validate(),
    });
  }

  validate() {
    const selectedCount = this.element.tomselect.items.length;

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
