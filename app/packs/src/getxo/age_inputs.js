const AGE_INPUT_SELECTOR = 'input[name$="[minimum_age]"], input[name$="[maximum_age]"]';
const NON_NEGATIVE_INTEGER_PATTERN = "^\\d+$";

document.addEventListener("DOMContentLoaded", () => {
  document.querySelectorAll(AGE_INPUT_SELECTOR).forEach((input) => {
    input.setAttribute("min", "0");
    input.setAttribute("step", "1");
    input.setAttribute("data-pattern", NON_NEGATIVE_INTEGER_PATTERN);
  });
});
