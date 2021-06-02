// カレンダー
import 'flatpickr';
import 'flatpickr/dist/l10n/ja';

export const reservationSystem = () => {
  const calendar = document.getElementById('flatpickr');
  const numBox = document.getElementById('num-box');
  const timeBox = document.getElementById('time-box');
  const modalElement = document.querySelector('.modal');
  const modalButton = document.getElementById('modal-button');
  const returnButton = document.getElementById('return_button');
  const reservationDetails = document.querySelector('.reservation_details');
  const reservationButton = document.getElementById('reservation_button');

  const csrfToken = document.querySelector('meta[name="csrf-token"]').content;

  const modalForm = document.getElementById('modal-form');
  const guestName = document.querySelector('.guest_name');
  const guestMail = document.querySelector('.guest_mail');
  const guestPhone = document.querySelector('.guest_phone');
  const guestRequest = document.querySelector('.guest_request');
  // const checkBox = document.getElementById("check");
  // const minimumPrivateNumber = 6;

  // if (!reservationButton) return;

  let config = {
    locale: 'ja',
    // enable: JSON.parse(calendar.dataset.arr),
    minDate: 'today',
    disableMobile: 'true',
  };

  let fp = flatpickr('#flatpickr', config);

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
    } else {
      modalButton.disabled = true;
    }
  };

  const buildUri = (baseUri) => {
    const guestNumber = numBox.value;
    const date = calendar.value;

    const regex = /\/admin\/reservations\/(\d+)\/edit/;
    const matched = location.pathname.match(regex);

    let uri = `${baseUri}?guest_number=${guestNumber}`;

    if (date) uri += `&date=${date}`;
    if (matched) uri += `&exclude_reservation_id=${matched[1]}`;
    return uri;
  };

  const changeAvailableDates = (open = true) => {
    const uri = buildUri('/reservations/available_dates');

    fetch(uri)
      .then((response) => response.json())
      .then((data) => {
        // カレンダーの選択できる日付を更新
        config.enable = data.availableDates;
        fp = flatpickr('#flatpickr', config);
        // 予約時間の更新
        insertAvailableTime(data.availableTime);
        if (data.availableTime.length === 0) {
          //  予約日を選択していない、または、選択した日付が予約できないとき

          // カレンダーの日付選択を取り消す
          calendar.value = '';
          // カレンダーの日付が空の時はmodalButtonを選択不可にする
          if (modalButton) modalButton.disabled = true;
          // カレンダーを開く
          if (open) fp.open();
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
    const uri = buildUri('/reservations/available_time');

    fetch(uri)
      .then((response) => response.json())
      .then((data) => {
        insertAvailableTime(data.availableTime);
        // 予約時間のボックスが空の時はmodalButtonを選択不可にする
        if (modalButton && data.availableTime.length === 0) {
          modalButton.disabled = true;
        }
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

  // checkBox.addEventListener("change", () => {
  //   if (checkBox.checked) {
  //   }
  // });

  const convertDate = (value) => {
    // let date = Date.parse(calendar.value);
    let date = new Date(value);
    let dayOfWeek = date.getDay();
    let dayOfWeekStr = ['日', '月', '火', '水', '木', '金', '土'][dayOfWeek];

    return `${date.getFullYear()}年${date.getMonth() + 1}月${date.getDate()}日(${dayOfWeekStr})`;
  };

  const appearModal = () => {
    modalElement.style.display = 'block';

    // if (e.target.checked) {

    // }
    // if (!e.target.checked) return;

    // let date = new Date(calendar.value);
    // let dayOfWeek = date.getDay();
    // let dayOfWeekStr = ['日', '月', '火', '水', '木', '金', '土'][dayOfWeek];

    // date = `${date.getFullYear()}年${date.getMonth() + 1}月${date.getDate()}日(${dayOfWeekStr})`;
    // let str = `${numBox.value}名様 / ${date} / ${timeBox.value}`;
    let str = `${numBox.value}名様 / ${convertDate(calendar.value)} / ${timeBox.value}`;
    reservationDetails.textContent = str;
  };

  const disappearModal = () => {
    modalElement.style.display = 'none';
  };

  const appearButton = () => {
    modalButton.disabled = false;
  };

  const sendReservationInfo = (e) => {
    e.preventDefault();
    if (!modalForm.checkValidity()) {
      modalForm.reportValidity();
      return;
    }

    const reservationParams = {
      reservation: {
        name: guestName.value,
        email: guestMail.value,
        phone_number: guestPhone.value,
        request: guestRequest.value,
        guest_number: numBox.value,
        // date: calendar.value,
        // time: timeBox.value,
        start_at: `${calendar.value} ${timeBox.value}`,
      },
    };

    fetch(`/reservations`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrfToken,
      },
      body: JSON.stringify(reservationParams),
    })
      .then((response) => {
        if (response.ok) {
          // alert('予約に成功しました!');
          location.href = '/reservations/confirmation';
        } else {
          return response.json();
        }
      })
      .then((data) => {
        alert(data.error);
        // 戻るボタンをクリックした時と同じ処理
        disappearModal();
        changeAvailableDates();
      });
  };

  // 初期表示時カレンダーの選択できる日付を取得
  changeAvailableDates(false);

  // 貸切予約の初期設定で6人以上の場合はチェックボックスに事前にチェックが入る為のデータ取得
  // changeDisabled(numBox.value,,checkBox.checked);

  // 予約人数を選択した時カレンダーの選択できる日付を取得
  numBox.addEventListener('change', () => {
    // if (guestNumber >= minimumPrivateNumber) {
    //   checkBox.removeAttribute("disabled");
    //   checkBox.setAttribute("checked", "checked");
    // } else {
    //   checkBox.setAttribute("disabled", "disabled");
    //   checkBox.removeAttribute("checked");
    // }
    changeAvailableDates();
  });

  calendar.addEventListener('change', changeAvailableTime);
  if (modalButton) {
    modalButton.addEventListener('click', appearModal);
    // 戻るボタンをクリックしたら、disappearModalが起動
    returnButton.addEventListener('click', disappearModal);
    // カレンダーと予約時間の両方が選択されれば modalButton の disabled を削る
    timeBox.addEventListener('change', appearButton);
    // 「予約する」ボタンをクリックしたらcreateアクションにリクエストを出す
    reservationButton.addEventListener('click', sendReservationInfo, { passive: false });
  }
};
