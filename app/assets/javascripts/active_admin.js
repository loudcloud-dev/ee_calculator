//= require arctic_admin/base

document.addEventListener("DOMContentLoaded", function () {
  document.querySelectorAll(".tom-select").forEach((element) => {
    const tomSelectInstance = new TomSelect(element, {
      placeholder: "Select Employee",
      onItemAdd: function() {
        this.setTextboxValue('');
        this.refreshOptions();
        validate(tomSelectInstance);
      },
      onDropdownClose: () => validate(tomSelectInstance),
      onItemRemove: () => validate(tomSelectInstance),
    });
  });

  function validate(tomSelectInstance) {
    const selectedCount = tomSelectInstance.items.length;
    const submitBtn = document.getElementById("reimbursement_submit_action");

    if (submitBtn) submitBtn.classList.toggle("disabled", selectedCount < 2);
  }
});
