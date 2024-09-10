import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="locale"
export default class extends Controller {
  // Connects to data-action="click->locale#switchLocale"
  // Switches the locale when the user selects a new one by changing the URL (from `/en/posts` to `/ja/posts`)
  // Example: <select data-action="change->locale#switchLocale">
  switchLocale(event) {
    const locale = event.target.value
    const url = new URL(window.location.href)
    const path = url.pathname.split("/")

    path[1] = locale
    url.pathname = path.join("/")

    Turbo.visit(url.href)
  }
}
