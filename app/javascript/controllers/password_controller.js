import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="password"
export default class extends Controller {
  static targets = [ "password" ]

  connect() {
  }

  // Show the password by changing the input type to text
  showPassword() {
    this.passwordTarget.type = "text"
  }

  // Hide the password by changing the input type to password
  hidePassword() {
    this.passwordTarget.type = "password"
  }
}
