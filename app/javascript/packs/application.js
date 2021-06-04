// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import Rails from '@rails/ujs';
import Turbolinks from 'turbolinks';
import { reservationSystem } from '../reservation';
import { menuSortable } from '../menu_sortable';
import { rangeSlider } from '../day_condition';

Rails.start();
Turbolinks.start();

document.addEventListener('turbolinks:load', () => {
  if (location.pathname == '/admin/menus') {
    menuSortable();
  } else if (document.getElementById('num-box')) {
    reservationSystem();
  } else if (document.querySelector('.slider')) {
    rangeSlider();
  }

  const monthForm = document.getElementById('month-form');
  if (monthForm) {
    const chosenMonth = document.getElementById('chosen_month');
    chosenMonth.addEventListener('change', () => {
      monthForm.submit();
    });
  }
});
