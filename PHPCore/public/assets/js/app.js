const deleteModal = document.getElementById('deleteModal');

if (deleteModal) {
    deleteModal.addEventListener('show.bs.modal', event => {
        const button = event.relatedTarget;

        document.getElementById('deleteForm').action = button.dataset.deleteUrl;
        document.getElementById('deletePersonName').textContent = button.dataset.personName;
    });
}

document.querySelectorAll('form[data-confirm]').forEach(form => {
    form.addEventListener('submit', event => {
        if (!window.confirm(form.dataset.confirm)) {
            event.preventDefault();
        }
    });
});

const sidebarOffcanvas = document.getElementById('sidebarOffcanvas');
if (sidebarOffcanvas) {
    const bsSidebar = bootstrap.Offcanvas.getOrCreateInstance(sidebarOffcanvas);
    document.querySelectorAll('.sidebar-link').forEach(link => {
        link.addEventListener('click', () => {
            bsSidebar.hide();
        });
    });
}

