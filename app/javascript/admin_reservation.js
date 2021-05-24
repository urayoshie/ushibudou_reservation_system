// カレンダー
require('flatpickr');
require('flatpickr/dist/l10n/ja');
// カレンダーの色を変更
require('flatpickr/dist/themes/material_orange.css');

document.addEventListener('turbolinks:load', () => {
  const calendar = document.getElementById('flatpickr');
  const numBox = document.getElementById('guest_num');
  const timeBox = document.getElementById('time-box');

  let config = {
    locale: 'ja',
    disableMobile: 'true',
  };
  flatpickr('#flatpickr', config);

  const insertAvailableTime = (availableTime) => {
    // 現在選択している時間 (time) を取得
    const time = timeBox.value;
    let str = '';
    if (availableTime.length > 0) {
      str += '<option disabled selected value> -- 選択して下さい -- </option>';
      for (let list of availableTime) {
        str += `<option>${list}</option>`;
      }
    }
    timeBox.innerHTML = str;
    // 選択していた時間 (time) が availableTime に含まれるときは選択済みにする
    const index = availableTime.indexOf(time);
    if (index >= 0) {
      timeBox.selectedIndex = index + 1;
    }
  };

  const changeAvailableTime = () => {
    const guestNumber = numBox.value;
    const date = calendar.value;
    fetch(`/reservations/available_time?guest_number=${guestNumber}&date=${date}`)
      .then((response) => response.json())
      .then((data) => {
        insertAvailableTime(data.availableTime);
      });
  };

  calendar.addEventListener('change', changeAvailableTime);
});
