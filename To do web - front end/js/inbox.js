/* ==========================================================================
   Inbox page — full notification center
   ========================================================================== */

let INBOX_FILTER = "all";

const INBOX_META = {
  reminder: { icon: "bell", color: ["hsl(0 90% 95%)", "var(--coral-600)"] },
  achievement: { icon: "trophy", color: ["var(--accent-soft)", "var(--amber-700)"] },
  dream: { icon: "dream", color: ["var(--brand-soft)", "var(--brand-strong)"] },
  summary: { icon: "analytics", color: ["var(--secondary-soft)", "var(--sky-700)"] },
  comment: { icon: "mail", color: ["var(--secondary-soft)", "var(--sky-700)"] },
  system: { icon: "bulb", color: ["hsl(155 65% 92%)", "var(--mint-600)"] },
};

document.addEventListener("DOMContentLoaded", () => {
  MDG_SHELL.mount("Inbox", "Everything Magadige Task wants you to know.");
  document.getElementById("checkIcon").innerHTML = ICON.check;
  bindTabs();
  document.getElementById("markAllReadBtn").addEventListener("click", () => {
    MDG.notifications.forEach(n => n.unread = false);
    MDG.saveState();
    MDG_SHELL.toast("All notifications marked as read", "success");
    render();
  });
  render();
});

function bindTabs() {
  document.querySelectorAll("#inboxTabs .tab").forEach(tab => {
    tab.addEventListener("click", () => {
      document.querySelectorAll("#inboxTabs .tab").forEach(t => t.classList.remove("is-active"));
      tab.classList.add("is-active");
      INBOX_FILTER = tab.dataset.filter;
      render();
    });
  });
}

function getFiltered() {
  if (INBOX_FILTER === "all") return MDG.notifications;
  if (INBOX_FILTER === "unread") return MDG.notifications.filter(n => n.unread);
  return MDG.notifications.filter(n => n.type === INBOX_FILTER);
}

function render() {
  const list = getFiltered();
  document.getElementById("inboxEmptyState").hidden = list.length > 0;
  document.getElementById("inboxList").hidden = list.length === 0;

  const unread = list.filter(n => n.unread);
  const read = list.filter(n => !n.unread);

  let html = "";
  if (unread.length) html += `<div class="inbox-section-label">New</div>` + unread.map(itemHtml).join("");
  if (read.length) html += `<div class="inbox-section-label">Earlier</div>` + read.map(itemHtml).join("");
  document.getElementById("inboxList").innerHTML = html;

  document.querySelectorAll(".inbox-item").forEach(el => {
    el.addEventListener("click", (e) => {
      if (e.target.closest("button")) return;
      const n = MDG.notifications.find(x => x.id === el.dataset.id);
      if (n && n.unread) { n.unread = false; MDG.saveState(); render(); }
    });
  });
  document.querySelectorAll("[data-inbox-delete]").forEach(btn => {
    btn.addEventListener("click", (e) => {
      e.stopPropagation();
      const idx = MDG.notifications.findIndex(n => n.id === btn.dataset.inboxDelete);
      if (idx > -1) MDG.notifications.splice(idx, 1);
      MDG.saveState();
      MDG_SHELL.toast("Notification removed", "info");
      render();
    });
  });
}

function itemHtml(n) {
  const meta = INBOX_META[n.type] || INBOX_META.system;
  return `
    <div class="inbox-item ${n.unread ? "is-unread" : ""}" data-id="${n.id}">
      ${n.unread ? '<span class="inbox-item-unread-dot"></span>' : ""}
      <div class="inbox-item-icon" style="background:${meta.color[0]};color:${meta.color[1]}">${ICON[meta.icon]}</div>
      <div class="inbox-item-body">
        <div class="inbox-item-title">${n.title}</div>
        <div class="inbox-item-text">${n.body}</div>
        <div class="inbox-item-time">${n.time}</div>
      </div>
      <div class="inbox-item-actions">
        <button data-inbox-delete="${n.id}" data-tooltip="Remove">${ICON.trash}</button>
      </div>
    </div>`;
}
