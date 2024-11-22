import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    new TomSelect(this.element, {
      onItemAdd:function(){
        this.setTextboxValue('');
        this.refreshOptions();
      }
    });
  }
}
