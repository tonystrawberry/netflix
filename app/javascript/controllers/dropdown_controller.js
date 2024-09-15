import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="dropdown"
export default class extends Controller {
  static targets = ["desktopMenu", "mobileMenu"];

  connect() {
    this.isOpen = false;
  }

  toggleDesktop(event) {
    event.stopPropagation();
    this.isOpen = !this.isOpen;
    if (this.isOpen) {
      this.desktopMenuTarget.classList.remove("hidden", "opacity-0", "scale-95");
      this.desktopMenuTarget.classList.add("opacity-100", "scale-100");
    } else {
      this.desktopMenuTarget.classList.remove("opacity-100", "scale-100");
      this.desktopMenuTarget.classList.add("opacity-0", "scale-95");
      setTimeout(() => {
        if (!this.isOpen) {
          this.desktopMenuTarget.classList.add("hidden");
        }
      }, 200); // Match duration of ease-out transition
    }
  }

  toggleMobile(event) {
    event.stopPropagation();
    this.isOpen = !this.isOpen;
    if (this.isOpen) {
      this.mobileMenuTarget.classList.remove("hidden");
    } else {
      this.mobileMenuTarget.classList.add("hidden");
    }
  }

  close(event) {
    if (this.element.contains(event.target)) return;

    this.isOpen = false;

    this.desktopMenuTarget.classList.remove("opacity-100", "scale-100");
    this.desktopMenuTarget.classList.add("opacity-0", "scale-95");

    this.mobileMenuTarget.classList.add("hidden");

    setTimeout(() => {
      if (!this.isOpen) {
        this.desktopMenuTarget.classList.add("hidden");
      }
    }, 200); // Match duration of ease-in transition
  }
}
