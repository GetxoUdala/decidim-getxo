import TomSelect from "tom-select/dist/cjs/tom-select.popular";

const urlZones = "/admin/getxo/zones";

document.addEventListener("DOMContentLoaded", () => {
  const initializeTomSelect = () => {
    document.querySelectorAll('input[tabs_prefix="zones_tabs_prefix"]').forEach((input) => {
      const select = document.createElement("select");
      select.className = input.className;
      select.multiple = true;

      input.parentNode.insertBefore(select, input.nextSibling);
      input.style.display = "none";

      const tomSelect = new TomSelect(select, {
        plugins: ["remove_button", "dropdown_input"],
        allowEmptyOption: true,
        load: (query, callback) => {
          if (!query.length) {
            callback([]);
            return;
          }

          fetch(`${urlZones}?query=${query}`, {
            headers: { "Accept": "application/json" }
          }).
            then((response) => response.json()).
            then((data) => {
              const results = data.map((item) => ({
                value: item.id,
                text: item.text
              }));
              callback(results);
            }).
            catch(() => callback([]));
        }
      });

      tomSelect.on("change", () => {
        const selectedOptions = tomSelect.getValue();

        if (selectedOptions.includes("all") && selectedOptions.length > 1) {
          tomSelect.setValue(["all"]);
        }
      });
    });
  };

  initializeTomSelect();
});
