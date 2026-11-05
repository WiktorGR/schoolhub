import { Controller } from "@hotwired/stimulus"

// Shows and hides the navigation links on small screens.
// On wider screens the links are always visible (see the sm: classes in the markup).
export default class extends Controller {
  static targets = [ "links", "button" ]

  toggle() {
    const opened = this.linksTarget.classList.toggle("hidden") === false
    this.buttonTarget.setAttribute("aria-expanded", opened)
  }
}
