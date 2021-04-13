// カレンダー
require("flatpickr");
require("flatpickr/dist/l10n/ja");
// カレンダーの色を変更
require("flatpickr/dist/themes/material_orange.css");

document.addEventListener("turbolinks:load", () => {
  const calendar = document.getElementById("flatpickr");
  let config = {
    locale: "ja",
    enable: JSON.parse(calendar.dataset.arr),
    minDate: "today",
  };
  let fp = flatpickr("#flatpickr", config);

  const num_box = document.getElementById("num_box");

  num_box.addEventListener(
    "change",
    function () {
      config.enable = ["2021-04-20", "2021-04-26"];
      fp = flatpickr("#flatpickr", config);
      fp.open();
    },
    false
  );
});
