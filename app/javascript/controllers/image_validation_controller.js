import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["fileInput", "imageTypeErrorMessage", "fileSizeErrorMessage"];

  connect() {
    this.fileInputTarget.addEventListener("change", this.validate.bind(this));
  }

  validate(event) {
    const file = event.target.files[0];
    const fileSize = file.size / 1024 / 1024;
    const imageTypeErrorMessage = this.imageTypeErrorMessageTarget;
    const fileSizeErrorMessage = this.fileSizeErrorMessageTarget;

    imageTypeErrorMessage.classList.toggle("d-block", file && !file.type.startsWith("image/"));
    fileSizeErrorMessage.classList.toggle("d-block", fileSize > 10)

    if (file && (!file.type.startsWith("image/") || fileSize > 10)) {
      this.fileInputTarget.value = "";
    }
  }
}
