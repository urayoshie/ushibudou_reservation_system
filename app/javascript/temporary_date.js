import noUiSlider from 'nouislider';
import 'flatpickr';
import 'flatpickr/dist/l10n/ja';

export const temporaryDateRangeSlider = () => {
  const minDate = document.getElementById('flatpickr').dataset.min_date;
  const defaultDate = document.getElementById('flatpickr').dataset.default_date;
  let config = {
    locale: 'ja',
    // enable: JSON.parse(calendar.dataset.arr),
    minDate: minDate,
    defaultDate: defaultDate || 'today',
    disableMobile: 'true',
  };

  flatpickr('#flatpickr', config);

  const range = document.querySelector('.slider');
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

  const sliderSetup = (range) => {
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
    const openCheck = document.getElementById('temporary_date-open');
    const start = document.getElementById('temporary_date-start');
    const end = document.getElementById('temporary_date-end');

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
  };
  sliderSetup(range);
};
