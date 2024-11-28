import { Controller } from "@hotwired/stimulus";
import * as bootstrap from 'bootstrap';

export default class extends Controller {
  static targets = ["submit"];

  connect() {
    this.submitTarget.disabled = false;
  }

  validateForm(event) {
    const isValid = this.checkFormValidation();
    const toast = document.getElementById('liveToast');
    const toastTitle = toast.querySelector('.toast-title');
    const toastBody = toast.querySelector('.toast-body');
    const toastHeader = toast.querySelector('.toast-header');

    if (!isValid) {
      const toastBootstrap = bootstrap.Toast.getOrCreateInstance(toast);

      // Set toast
      toastTitle.textContent = "Error"
      toastBody.textContent = "Please fix the errors before submitting.";
      toastHeader.classList.add("bg-danger");

      event.preventDefault();
      toastBootstrap.show();
    }
  }

  checkFormValidation() {
    const validationControllers = ['select', 'image-validation']; // Add controllers to validate
    const controllersToValidate = this.application.controllers.filter(controller =>
      validationControllers.includes(controller.identifier)
    );

    const isValid = controllersToValidate.every(controller => controller.validate() === true);

    return isValid;
  }
}
