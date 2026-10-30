function showSubmenu(count, open, hover) {
    if (hover && !window.matchMedia('(hover: hover)').matches) return;
    const submenu = document.getElementById('submenu-' + count);
    if (!submenu) return;
    submenu.classList.toggle('hide', !open);
    const button = submenu.parentElement.querySelector('.spread-btn');
    if (button) button.setAttribute('aria-expanded', String(open));
    const icon = document.getElementById('spread-icon-' + count);
    if (icon) icon.textContent = open ? 'arrow_drop_down' : 'arrow_right';
    if (open) {
        submenu.style.transform = '';
        const height = window.visualViewport ? window.visualViewport.height : window.innerHeight;
        submenu.style.maxHeight = `${Math.max(96, height - 32)}px`;
        const rect = submenu.getBoundingClientRect();
        const shift = Math.max(16 - rect.top, Math.min(0, height - 16 - rect.bottom));
        submenu.style.transform = `translateY(${shift}px)`;
    }
}

function spread(count) {
    const submenu = document.getElementById('submenu-' + count);
    if (submenu) showSubmenu(count, submenu.classList.contains('hide'));
}
