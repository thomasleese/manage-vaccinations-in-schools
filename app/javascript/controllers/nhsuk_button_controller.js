import { Controller } from "@hotwired/stimulus";
import { Button } from "govuk-frontend";

// Connects to data-module="nhsuk-button"
export default class extends Controller {
  connect() {
    new Button(this.element);
  }
}
