// = require_self

$(() => {
  $("#projects .budget-list__item .budget-list__data form.button_to").on("submit", function () {
    $(".getxo-budget-vote-button").attr("disabled", true);
  });
});
