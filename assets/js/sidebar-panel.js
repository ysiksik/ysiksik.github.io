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
    const wideBreakpoint = getComputedStyle(root).getPropertyValue('--break-point-dynamic').trim() || '1664px';
    const wide = window.matchMedia(`(min-width: ${wideBreakpoint})`);
    const storageKey = 'sidebar-panel-collapsed';
    let collapsed = false;
    let readingAnchor = null;
    let anchoredScrollY = 0;
    try { collapsed = localStorage.getItem(storageKey) === 'true'; }
    catch (_) { /* The toggle also works without browser storage. */ }

    function update() {
      const hidden = desktop.matches && collapsed;
      root.classList.toggle('sidebar-panel-mobile', !desktop.matches);
      root.classList.toggle('sidebar-panel-collapsed', hidden);
      const toc = document.getElementById('markdown-toc');
      root.classList.toggle('sidebar-toc-docked', !!toc && !document.body.classList.contains('no-toc') &&
        desktop.matches && (hidden || wide.matches));
      toggle.hidden = !desktop.matches;
      root.style.setProperty('--sidebar-panel-width', `${drawer.getBoundingClientRect().width}px`);
      toggle.setAttribute('aria-expanded', String(!hidden));
      toggle.setAttribute('aria-label', hidden ? '사이드바 펼치기' : '사이드바 접기');
      toggle.title = toggle.getAttribute('aria-label');
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

    function captureReadingPosition() {
      const main = document.getElementById('_main');
      if (!main || window.scrollY < 80) return null;
      const y = Math.min(144, window.innerHeight / 4);
      const blocks = main.querySelectorAll('h1, h2, h3, h4, h5, h6, p, pre, li, figure, table');
      for (const element of blocks) {
        if (element.closest('#markdown-toc, .coupang-partners-ad, .sidebar-social')) continue;
        const rect = element.getBoundingClientRect();
        if (!rect.width || rect.bottom <= y || rect.top >= window.innerHeight) continue;
        const x = Math.max(0, rect.left) + Math.min(40, rect.width / 4);
        const lineY = Math.max(y, rect.top + 4);
        let range;
        if (document.caretRangeFromPoint) range = document.caretRangeFromPoint(x, lineY);
        else if (document.caretPositionFromPoint) {
          const caret = document.caretPositionFromPoint(x, lineY);
          if (caret) {
            range = document.createRange();
            range.setStart(caret.offsetNode, caret.offset);
          }
        }
        if (range && element.contains(range.startContainer) && range.startContainer.nodeType === Node.TEXT_NODE) {
          const text = range.startContainer;
          const offset = Math.min(range.startOffset, Math.max(0, text.length - 1));
          range.setStart(text, offset);
          range.setEnd(text, Math.min(offset + 1, text.length));
          return { range, top: range.getBoundingClientRect().top };
        }
        return { element, top: rect.top };
      }
      return null;
    }

    function restoreReadingPosition(anchor) {
      if (!anchor) return;
      const rect = anchor.range ? anchor.range.getBoundingClientRect() : anchor.element.getBoundingClientRect();
      window.scrollBy(0, rect.top - anchor.top);
    }

    function togglePanel() {
      const connected = readingAnchor && (readingAnchor.range ?
        readingAnchor.range.startContainer.isConnected : readingAnchor.element.isConnected);
      const anchor = connected && Math.abs(window.scrollY - anchoredScrollY) < 2 ?
        readingAnchor : captureReadingPosition();
      root.classList.add('sidebar-panel-changing');
      collapsed = !collapsed;
      // Keep the theme's full-screen drawer closed when using the desktop panel.
      if (drawer.hasAttribute('opened') && typeof drawer.close === 'function') drawer.close();
      try { localStorage.setItem(storageKey, String(collapsed)); }
      catch (_) { /* State persistence is optional. */ }
      update();
      restoreReadingPosition(anchor);
      requestAnimationFrame(() => {
        restoreReadingPosition(anchor);
        requestAnimationFrame(() => {
          root.classList.remove('sidebar-panel-changing');
          readingAnchor = anchor;
          anchoredScrollY = window.scrollY;
        });
      });
    }

    toggle.addEventListener('click', togglePanel);
    document.addEventListener('click', event => {
      if (!desktop.matches || !event.target.closest('#_menu')) return;
      event.preventDefault();
      event.stopImmediatePropagation();
      togglePanel();
    }, true);
    desktop.addEventListener('change', update);
    wide.addEventListener('change', update);
    window.addEventListener('resize', update);
    drawer.addEventListener('hy-drawer-init', update);
    document.addEventListener('hy-push-state-after', update, true);
    document.addEventListener('hy-push-state-load', update, true);
    update();
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initialize, { once: true });
  } else { initialize(); }
})();
