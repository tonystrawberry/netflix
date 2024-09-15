import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="avatar-preview"
export default class extends Controller {
  static targets = [ "input", "preview" ]

  connect() {
  }

  // Trigger the file input click
  // when the user clicks on the preview image
  triggerFileUpload() {
    this.inputTarget.click();
  }

  // Preview the image when the user selects a file
  // from the file input
  preview() {
    const input = this.inputTarget;
    const preview = this.previewTarget;

    let file = input.files[0];
    let reader = new FileReader();

    reader.onloadend = function () {
      preview.src = reader.result;
    }

    if (file) {
      reader.readAsDataURL(file);
    } else {
      preview.src = "";
    }
  }
}
