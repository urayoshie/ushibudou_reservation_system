// カレンダー
require("flatpickr");
require("flatpickr/dist/l10n/ja");
// カレンダーの色を変更
require("flatpickr/dist/themes/material_orange.css");

document.addEventListener("turbolinks:load", () => {
  const calendar = document.getElementById("flatpickr");
  const numBox = document.getElementById("num-box");

  let config = {
    locale: "ja",
    // enable: JSON.parse(calendar.dataset.arr),
    minDate: "today",
  };

  let fp = flatpickr("#flatpickr", config);

  const changeAvaliableDates = (guestNumber) => {
    fetch(`/reservations/available_dates?guest_number=${guestNumber}`)
      .then((response) => response.json())
      .then((data) => {
        config.enable = data.availableDates;
        fp = flatpickr("#flatpickr", config);
        fp.open();
      });
  };

  const changeAvaliableTime = (guestNumber, date) => {
    fetch(
      `/reservations/available_time?guest_number=${guestNumber}&date=${date}`
    )
      .then((response) => response.json())
      .then((data) => {
        const timeBox = document.getElementById("time-box");
        let str = "";
        for (let list of data.availableTime) {
          str += `<option>${list}</option>`;
        }
        timeBox.innerHTML = str;
        // debugger;
        // timeBox.textContent = "";
        // timeBox.appendChild(new Option("15:30"));

        // data に含まれる時間帯を選択できるようにする
        // str = "";
      });
  };

  // 初期表示時カレンダーの選択できる日付を取得
  changeAvaliableDates(numBox.value);

  // 予約人数を選択した時カレンダーの選択できる日付を取得
  numBox.addEventListener("change", (e) => {
    const guestNumber = e.target.value;
    changeAvaliableDates(guestNumber);
  });

  calendar.addEventListener("change", (e) => {
    const numBox = document.getElementById("num-box");
    const guestNumber = numBox.value;
    const date = e.target.value;
    changeAvaliableTime(guestNumber, date);
  });
});
