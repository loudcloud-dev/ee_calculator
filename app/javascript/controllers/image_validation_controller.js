// app/javascript/controllers/image_validation_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["fileInput", "errorMessage"];

  connect() {
    this.fileInputTarget.addEventListener("change", this.validateFile.bind(this));
  }

  validateFile(event) {
    const file = event.target.files[0];
    const errorMessage = this.errorMessageTarget;

    if (file && !file.type.startsWith("image/")) {
      errorMessage.classList.add("d-block");
      this.fileInputTarget.classList.add("is-invalid");
      this.fileInputTarget.value = "";
    } else {
      errorMessage.classList.remove("d-block");
      this.fileInputTarget.classList.remove("is-invalid");
    }
  }
}
