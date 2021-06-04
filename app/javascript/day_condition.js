import noUiSlider from 'nouislider';
import 'flatpickr';
import 'flatpickr/dist/l10n/ja';

export const rangeSlider = () => {
  const isNew = document.getElementById('day-conditions-0-edit');
  let config = {
    locale: 'ja',
    // enable: JSON.parse(calendar.dataset.arr),
    defaultDate: 'today',
    disableMobile: 'true',
  };
  const minDate = document.getElementById('flatpickr').dataset.min_date;
  if (minDate) config.minDate = minDate;

  flatpickr('#flatpickr', config);

  const ranges = document.querySelectorAll('.slider');
  const rangeMin = 0,
    rangeMax = 1680,
    limit = 1440,
    step = 15;

  const zeroPadding = (value) => {
    return ('00' + value).slice(-2);
  };

  const inputTime = (value) => {
    const minute = parseInt(value);
    const hour = zeroPadding(Math.floor(minute / 60));
    const min = zeroPadding(minute % 60);
    return `${hour}:${min}`;
  };

  // 0 = initial minutes from start of day
  // 1440 = maximum minutes in a day
  // step: 30 = amount of minutes to step by.

  ranges.forEach((range) => {
    const startMin = range.dataset.start;
    const startMax = range.dataset.end;

    const slider = noUiSlider.create(range, {
      start: [startMin, startMax],
      connect: true,
      // behaviour: 'tap',
      tooltips: {
        from: Number,
        to: inputTime,
      },
      limit: limit,
      step: step,
      range: {
        min: rangeMin,
        max: rangeMax,
      },
    });

    const wday = range.dataset.wday;
    const openCheck = document.getElementById(`day-conditions-${wday}-open`);
    const start = document.getElementById(`day-conditions-${wday}-start`);
    const end = document.getElementById(`day-conditions-${wday}-end`);

    slider.on('update', function (values, handle) {
      if (handle === 0) {
        start.value = Math.floor(values[0]);
      } else {
        end.value = Math.floor(values[1]);
      }
    });

    openCheck.addEventListener('click', (e) => {
      if (e.target.checked) {
        range.removeAttribute('disabled');
      } else {
        range.setAttribute('disabled', true);
        // slider.set([900, 1500]);
      }
    });
    if (isNew) {
      const editCheck = document.getElementById(`day-conditions-${wday}-edit`);
      editCheck.addEventListener('click', (e) => {
        if (e.target.checked) {
          openCheck.removeAttribute('disabled');
          if (openCheck.checked) range.removeAttribute('disabled');
        } else {
          openCheck.setAttribute('disabled', true);
          range.setAttribute('disabled', true);
        }
      });
    }
  });
};
