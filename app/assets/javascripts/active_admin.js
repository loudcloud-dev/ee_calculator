//= require arctic_admin/base

document.addEventListener("DOMContentLoaded", function () {
    document.querySelectorAll(".tom-select").forEach((element) => {
      new TomSelect(element, {
        placeholder: "Select Employee",
        onItemAdd:function(){
          this.setTextboxValue('');
          this.refreshOptions();
        }
      });
    });
});  
