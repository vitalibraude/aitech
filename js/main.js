// ===== DMS MAIN JS =====

function showModal(id) {
  document.getElementById(id).classList.add('open');
}
function closeModal(id) {
  document.getElementById(id).classList.remove('open');
}

// Close modals with ESC key
document.addEventListener('keydown', e => {
  if (e.key === 'Escape') {
    document.querySelectorAll('.modal-overlay.open').forEach(m => m.classList.remove('open'));
  }
});

// Global search shortcut Ctrl+K
document.addEventListener('keydown', e => {
  if ((e.ctrlKey || e.metaKey) && e.key === 'k') {
    e.preventDefault();
    const s = document.getElementById('globalSearch');
    if (s) s.focus();
  }
});

// Global search redirect on Enter
const gs = document.getElementById('globalSearch');
if (gs) {
  gs.addEventListener('keydown', e => {
    if (e.key === 'Enter' && gs.value.trim()) {
      window.location.href = `search.html?q=${encodeURIComponent(gs.value.trim())}`;
    }
  });
}

// ===== SIDEBAR COLLAPSE TOGGLE =====
(function() {
  const sidebar     = document.getElementById('sidebar');
  const mainContent = document.getElementById('mainContent');
  const toggleBtn   = document.getElementById('sidebarToggle');
  if (!sidebar || !toggleBtn) return;

  // Restore saved state
  const saved = localStorage.getItem('sidebarCollapsed');
  if (saved === 'true') {
    sidebar.classList.add('collapsed');
    if (mainContent) mainContent.classList.add('collapsed');
  }

  toggleBtn.addEventListener('click', () => {
    const isCollapsed = sidebar.classList.toggle('collapsed');
    if (mainContent) mainContent.classList.toggle('collapsed', isCollapsed);
    localStorage.setItem('sidebarCollapsed', isCollapsed);
  });
})();

// Toast notification utility
function showToast(message, type = 'success') {
  const icons  = { success: 'check-circle', error: 'times-circle', info: 'info-circle', warning: 'exclamation-triangle' };
  const colors = { success: '#107c10', error: '#c50f1f', info: '#0078d4', warning: '#d83b01' };
  const toast = document.createElement('div');
  toast.innerHTML = `<i class="fas fa-${icons[type] || 'info-circle'}"></i> ${message}`;
  toast.style.cssText = `
    position: fixed; bottom: 24px; right: 24px;
    background: ${colors[type] || '#0078d4'};
    color: white; padding: 12px 20px; border-radius: 10px;
    font-size: 0.86rem; font-family: 'Inter', sans-serif;
    box-shadow: 0 4px 20px rgba(0,0,0,0.2);
    display: flex; align-items: center; gap: 10px;
    z-index: 9999; animation: toastIn 0.3s ease;
    max-width: 360px; line-height: 1.4;
  `;
  document.body.appendChild(toast);
  setTimeout(() => {
    toast.style.opacity = '0';
    toast.style.transition = 'opacity 0.3s';
    setTimeout(() => toast.remove(), 300);
  }, 3500);
}

// Add animation keyframe
const style = document.createElement('style');
style.textContent = `@keyframes toastIn { from { transform: translateX(30px); opacity: 0; } to { transform: translateX(0); opacity: 1; } }`;
document.head.appendChild(style);

console.log('DMS SharePoint VSS v1.0 loaded ✓');
