import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="video-preview"
export default class extends Controller {
  static targets = [ "video", "input", "preview" ]

  connect() {
    const form = this.element.closest("form")
    const submit = this.element.closest("form").querySelector("[type=submit]")

    form.addEventListener("direct-upload:start", event => {
      submit.disabled = true
      submit.value = "Uploading... (0%)"
    })

    form.addEventListener("direct-upload:progress", event => {
      console.log("direct-upload:progress", event)
      const progress = Math.round(event.detail.progress)
      submit.value = `Uploading... (${progress}%)`
    })
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
    const video = this.videoTarget;

    let file = input.files[0];
    let reader = new FileReader();

    reader.onloadend = function () {
      preview.src = reader.result;
      video.load();
    }

    if (file) {
      reader.readAsDataURL(file);
    } else {
      preview.src = "";
    }
  }
}
