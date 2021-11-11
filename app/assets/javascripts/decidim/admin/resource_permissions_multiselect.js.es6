// = require select2
// = require_self

$(() => {
  /**
   * Used to override simple inputs in the resource permissions controller
   * Allows to use more than one street when configuring :census_authorization_handler
   * */
  const url_streets = "/admin/getxo/streets";
  
  const select2InputTags = (queryStr) => {
    const $input = $(queryStr)

    const $select = $('<select class="'+ $input.attr('class') + '" style="width:100%" multiple="multiple"><select>');
    if ($input.val() != "") {
      const values = $input.val().split(',');
      values.forEach((item) =>  {
        $select.append('<option value="' + item + '" selected="selected">' + item + '</option>')
      })
      ;
      // load text via ajax
      $.get(url_streets, { ids: values }, (data) => {
        $select.val("");
        $select.contents("option").remove()
        data.forEach((item) => {
         $select.append(new Option(item.text, item.id, true, true));
        });
        $select.trigger("change");
      }, "json");
    }
    $select.insertAfter($input);
    $input.hide();

    $select.change(() => {
      $input.val($select.val().join(","));
    });

    return $select;
  };

  $("input[name$='[authorization_handlers_options][census_authorization_handler][streets]'").each((idx, input) => {
    select2InputTags(input).select2({
      ajax: {
        url: url_streets,
        delay: 100,
        dataType: "json",
        processResults: (data) => {
          return {
            results: data
          }
        }
      },
      multiple: true,
      theme: "foundation"
    });
  });   
});
