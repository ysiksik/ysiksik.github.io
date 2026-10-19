(() => {
  'use strict';

  function initialize() {
    const root = document.documentElement;
    const drawer = document.getElementById('_drawer');
    const toggle = document.getElementById('_sidebar-panel-toggle');
    const menu = document.getElementById('_menu');
    if (!drawer || !toggle) return;

    const breakpoint = getComputedStyle(root).getPropertyValue('--break-point-3').trim() || '64em';
    const desktop = window.matchMedia(`(min-width: ${breakpoint})`);
    const storageKey = 'sidebar-panel-collapsed';
    let collapsed = false;
    try { collapsed = localStorage.getItem(storageKey) === 'true'; }
    catch (_) { /* The toggle also works without browser storage. */ }

    function update() {
      const hidden = desktop.matches && collapsed;
      root.classList.toggle('sidebar-panel-collapsed', hidden);
      toggle.hidden = !desktop.matches;
      root.style.setProperty('--sidebar-panel-width', `${drawer.getBoundingClientRect().width}px`);
      toggle.setAttribute('aria-expanded', String(!hidden));
      toggle.setAttribute('aria-label', hidden ? '사이드바 펼치기' : '사이드바 접기');
      toggle.title = toggle.getAttribute('aria-label');
      toggle.querySelector('span').textContent = hidden ? '›' : '‹';
      drawer.toggleAttribute('inert', hidden);
      if (hidden) drawer.setAttribute('aria-hidden', 'true');
      else drawer.removeAttribute('aria-hidden');
      if (menu && desktop.matches) {
        menu.setAttribute('aria-controls', '_drawer');
        menu.setAttribute('aria-expanded', String(!hidden));
        menu.setAttribute('aria-label', toggle.title);
      } else if (menu) {
        menu.removeAttribute('aria-expanded');
        menu.removeAttribute('aria-label');
      }
    }

    function togglePanel() {
      collapsed = !collapsed;
      // Keep the theme's full-screen drawer closed when using the desktop panel.
      if (drawer.hasAttribute('opened') && typeof drawer.close === 'function') drawer.close();
      try { localStorage.setItem(storageKey, String(collapsed)); }
      catch (_) { /* State persistence is optional. */ }
      update();
    }

    toggle.addEventListener('click', togglePanel);
    document.addEventListener('click', event => {
      if (!desktop.matches || !event.target.closest('#_menu')) return;
      event.preventDefault();
      event.stopImmediatePropagation();
      togglePanel();
    }, true);
    desktop.addEventListener('change', update);
    window.addEventListener('resize', update);
    drawer.addEventListener('hy-drawer-init', update);
    update();
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initialize, { once: true });
  } else { initialize(); }
})();
