import Sortable from 'sortablejs';

export const menuSortable = () => {
  const csrfToken = document.querySelector('meta[name="csrf-token"]').content;
  const sortableTarget = document.querySelector('.menu');
  new Sortable(sortableTarget, {
    draggable: '.menu-draggable',
    animation: 150,
    ghostClass: 'blue-background-class',
    onUpdate: async (e) => {
      const params = {
        name: e.item.querySelector('.menu-name').textContent,
        new_index: e.newIndex,
      };
      const uri = `/admin/sortable_menus/${e.oldIndex}`;
      const headers = {
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrfToken,
      };
      try {
        const response = await fetch(uri, {
          method: 'PATCH',
          headers: headers,
          body: JSON.stringify(params),
        });
        const data = await response.json();
        if (!response.ok && data.error) {
          throw new Error(data.error);
        }
      } catch (error) {
        alert(error);
        location.reload();
      }
    },
  });
};
