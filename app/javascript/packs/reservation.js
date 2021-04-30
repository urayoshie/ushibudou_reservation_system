// カレンダー
require("flatpickr");
require("flatpickr/dist/l10n/ja");
// カレンダーの色を変更
require("flatpickr/dist/themes/material_orange.css");

document.addEventListener("turbolinks:load", () => {
  const calendar = document.getElementById("flatpickr");
  const numBox = document.getElementById("num-box");
  // const checkBox = document.getElementById("check");
  const minimumPrivateNumber = 6;

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

  // const changeDisabled = (guestNumber, date) => {
  //   fetch(
  //     `/reservations/available_time?guest_number=${guestNumber}&date=${date}`
  //   )
  //     .then((response) => response.json())
  //     .then((data) => {
  //       debugger;
  //       // if (check.disabled == true) {
  //       //   check.disabled = false; //Enableに設定
  //       // } else {
  //       //   check.disabled = true; //Disableに設定
  //       // }
  //     });
  // };

  // 初期表示時カレンダーの選択できる日付を取得
  changeAvaliableDates(numBox.value);

  // 貸切予約の初期設定で6人以上の場合はチェックボックスに事前にチェックが入る為のデータ取得
  // changeDisabled(numBox.value,,checkBox.checked);

  // 予約人数を選択した時カレンダーの選択できる日付を取得
  numBox.addEventListener("change", (e) => {
    const guestNumber = e.target.value;
    // if (guestNumber >= minimumPrivateNumber) {
    //   checkBox.removeAttribute("disabled");
    //   checkBox.setAttribute("checked", "checked");
    // } else {
    //   checkBox.setAttribute("disabled", "disabled");
    //   checkBox.removeAttribute("checked");
    // }
    changeAvaliableDates(guestNumber);
  });

  // checkBox.addEventListener("change", () => {
  //   if (checkBox.checked) {
  //   }
  // });

  calendar.addEventListener("change", (e) => {
    const numBox = document.getElementById("num-box");
    const guestNumber = numBox.value;
    const date = e.target.value;
    // const checked = checkBox.checked ? "1" : "";
    changeAvaliableTime(guestNumber, date);
  });
});
