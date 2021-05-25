import Sortable from 'sortablejs';

export const menuSortable = () => {
  const csrfToken = document.querySelector('meta[name="csrf-token"]').content;
  new Sortable(menu, {
    draggable: '.menu-draggable',
    animation: 150,
    ghostClass: 'blue-background-class',
    onUpdate: (e) => {
      const params = {
        name: e.item.querySelector('.menu-name').textContent,
        new_index: e.newIndex,
      };
      fetch(`/menus/${e.oldIndex}`, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': csrfToken,
        },
        body: JSON.stringify(params),
      })
        .then((response) => {
          if (response.ok) {
          } else {
            return response.json();
          }
        })
        .then((data) => {
          if (data?.error) {
            alert(data.error);
            location.href = '/admin/menus';
          }
        });
    },
  });
};
