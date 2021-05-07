// カレンダー
require("flatpickr");
require("flatpickr/dist/l10n/ja");
// カレンダーの色を変更
require("flatpickr/dist/themes/material_orange.css");

document.addEventListener("turbolinks:load", () => {
  const calendar = document.getElementById("flatpickr");
  const numBox = document.getElementById("num-box");
  const timeBox = document.getElementById("time-box");
  // const checkBox = document.getElementById("check");
  const minimumPrivateNumber = 6;

  let config = {
    locale: "ja",
    // enable: JSON.parse(calendar.dataset.arr),
    minDate: "today",
  };

  let fp = flatpickr("#flatpickr", config);

  const insertAvailableTime = (availableTime) => {
    // 現在選択している時間 (time) を取得
    const time = timeBox.value
    let str = "";
    if (availableTime.length > 0) {
      str += "<option disabled selected value> -- 選択して下さい -- </option>";
      for (let list of availableTime) {
        str += `<option>${list}</option>`;
      }
    }
    timeBox.innerHTML = str;
    // 選択していた時間 (time) が availableTime に含まれるときは選択済みにする
    const index = availableTime.indexOf(time)
    if (index >= 0) {
      timeBox.selectedIndex = index + 1
    }
  };

  const changeAvailableDates = () => {
    const guestNumber = numBox.value;
    const date = calendar.value;
    fetch(
      `/reservations/available_dates?guest_number=${guestNumber}&date=${date}`
    )
      .then((response) => response.json())
      .then((data) => {
        // カレンダーの選択できる日付を更新
        config.enable = data.availableDates;
        fp = flatpickr("#flatpickr", config);
        // 予約時間の更新
        insertAvailableTime(data.availableTime);
        if (data.availableTime.length === 0) {
          //  予約日を選択していない、または、選択した日付が予約できないとき

          // カレンダーの日付選択を取り消す
          calendar.value = "";
          // カレンダーを開く
          fp.open();
        } else {
          // const timeBox = document.getElementById("time-box");
          // let str = "";
          // for (let list of data.availableTime) {
          //   str += `<option>${list}</option>`;
          // }
          // timeBox.innerHTML = str;
        }
      });
  };

  const changeAvailableTime = () => {
    const guestNumber = numBox.value;
    const date = calendar.value;
    fetch(
      `/reservations/available_time?guest_number=${guestNumber}&date=${date}`
    )
      .then((response) => response.json())
      .then((data) => {
        insertAvailableTime(data.availableTime);

        // const timeBox = document.getElementById("time-box");
        // let str = "";
        // for (let list of data.availableTime) {
        //   str += `<option>${list}</option>`;
        // }
        // timeBox.innerHTML = str;

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
  changeAvailableDates();

  // 貸切予約の初期設定で6人以上の場合はチェックボックスに事前にチェックが入る為のデータ取得
  // changeDisabled(numBox.value,,checkBox.checked);

  // 予約人数を選択した時カレンダーの選択できる日付を取得
  numBox.addEventListener("change", () => {
    // if (guestNumber >= minimumPrivateNumber) {
    //   checkBox.removeAttribute("disabled");
    //   checkBox.setAttribute("checked", "checked");
    // } else {
    //   checkBox.setAttribute("disabled", "disabled");
    //   checkBox.removeAttribute("checked");
    // }
    changeAvailableDates();
  });

  // checkBox.addEventListener("change", () => {
  //   if (checkBox.checked) {
  //   }
  // });

  calendar.addEventListener("change", changeAvailableTime);
});
