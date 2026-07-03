/* ==========================================================================
   App shell renderer — sidebar, topbar, AI FAB, toasts, notification panel.
   Shared across dashboard / tasks / task-details / dreams / profile / settings.
   ========================================================================== */

const MDG_SHELL = (() => {
  const NAV_GROUPS = [
    {
      label: "Main",
      items: [
        { href: "dashboard.html", icon: "home", label: "Dashboard" },
        { href: "tasks.html", icon: "tasks", label: "Tasks", badge: () => MDG.taskStats().pending },
        { href: "calendar.html", icon: "calendar", label: "Calendar" },
        { href: "dreams.html", icon: "dream", label: "Dream Board" },
      ],
    },
    {
      label: "Workspace",
      items: [
        { href: "analytics.html", icon: "analytics", label: "Analytics" },
        { href: "achievements.html", icon: "trophy", label: "Achievements" },
        { href: "inbox.html", icon: "inbox", label: "Inbox", badge: () => MDG.notifications.filter(n => n.unread).length },
        { href: "profile.html", icon: "profile", label: "Profile" },
        { href: "settings.html", icon: "settings", label: "Settings" },
      ],
    },
  ];

  function currentPage() {
    return location.pathname.split("/").pop() || "dashboard.html";
  }

  function renderSidebar() {
    const page = currentPage();
    const stats = MDG.taskStats();
    const groupsHtml = NAV_GROUPS.map(group => {
      const itemsHtml = group.items.map(item => {
        const active = item.href === page;
        const badge = item.badge ? item.badge() : null;
        return `
          <a class="nav-item ${active ? "is-active" : ""}" href="${item.href}">
            ${ICON[item.icon]}
            <span>${item.label}</span>
            ${badge ? `<span class="badge badge-indigo">${badge}</span>` : ""}
          </a>`;
      }).join("");
      return `
        <nav class="nav-group">
          <div class="nav-group-label">${group.label}</div>
          ${itemsHtml}
        </nav>`;
    }).join("");

    return `
      <aside class="sidebar" id="sidebar">
        <div class="brand">
          <div class="brand-mark">M</div>
          <div class="brand-name">Magadige <span>Task</span></div>
        </div>

        ${groupsHtml}

        <div class="sidebar-footer">
          <div class="dream-reminder-card">
            <strong>✦ Daily reminder</strong>
            <p>"Today's work builds tomorrow's dream."</p>
            <a href="dreams.html" class="btn btn-sm" style="background:rgba(255,255,255,.18);color:#fff;backdrop-filter:blur(6px);">View dreams ${ICON.arrowRight}</a>
          </div>
          <div class="user-pod" style="position:relative;">
            <div class="avatar-text" style="width:36px;height:36px;">${MDG.user.avatarInitials}</div>
            <div style="min-width:0;">
              <div class="user-pod-name">${MDG.user.name}</div>
              <div class="user-pod-role user-plan-badge">${ICON.crown} Premium Plan</div>
            </div>
            <button class="user-pod-chevron" id="userPodChevron" data-tooltip="Account">${ICON.chevronUpDown}</button>
            <div class="user-pod-menu" id="userPodMenu" hidden>
              <a href="profile.html">${ICON.profile} View Profile</a>
              <a href="settings.html">${ICON.settings} Settings</a>
              <div class="user-pod-menu-stat">${stats.completionRate}% productive today</div>
              <a href="login.html" class="user-pod-menu-danger">${ICON.logout} Sign out</a>
            </div>
          </div>
        </div>
      </aside>`;
  }

  function renderTopbar(pageTitle, pageSubtitle) {
    const unread = MDG.notifications.filter(n => n.unread).length;
    return `
      <header class="topbar">
        <div class="topbar-title-block flex items-center gap-4">
          <button class="icon-btn mobile-nav-toggle" id="mobileNavToggle" aria-label="Open menu">${ICON.menu}</button>
          <div class="topbar-title-text">
            <h1 class="topbar-title">${pageTitle || ""}</h1>
            ${pageSubtitle ? `<p class="topbar-subtitle">${pageSubtitle}</p>` : ""}
          </div>
        </div>
        <div class="topbar-search">
          ${ICON.search}
          <input type="text" placeholder="Search tasks, dreams, notes…" id="globalSearch" />
        </div>
        <div class="topbar-actions">
          <div class="theme-toggle" data-theme-toggle>
            <button data-theme-set="day" data-tooltip="Day" data-tooltip-pos="bottom">${ICON.sun}</button>
            <button data-theme-set="auto" data-tooltip="Auto" data-tooltip-pos="bottom">${ICON.auto}</button>
            <button data-theme-set="night" data-tooltip="Night" data-tooltip-pos="bottom">${ICON.moon}</button>
          </div>
          <button class="icon-btn" id="notifBtn" data-tooltip="Notifications" data-tooltip-pos="bottom">${ICON.bell}${unread ? '<span class="dot"></span>' : ""}</button>
          <a class="avatar-text" href="profile.html" style="width:40px;height:40px;font-size:var(--fs-xs);">${MDG.user.avatarInitials}</a>
        </div>
      </header>`;
  }

  function renderNotifPanel() {
    const items = MDG.notifications.slice(0, 5).map(n => `
      <div class="notif-item ${n.unread ? "is-unread" : ""}">
        <div class="notif-dot"></div>
        <div>
          <p style="margin:0;font-weight:700;font-size:var(--fs-xs);color:var(--text-primary);">${n.title}</p>
          <p style="margin:2px 0 0;font-size:var(--fs-2xs);">${n.body}</p>
          <span style="font-size:var(--fs-2xs);color:var(--text-tertiary);">${n.time}</span>
        </div>
      </div>`).join("") || `<p style="padding:var(--sp-4);font-size:var(--fs-xs);color:var(--text-tertiary);">You're all caught up.</p>`;
    return `
      <div class="notif-panel" id="notifPanel" hidden>
        <div class="flex items-center justify-between" style="padding:var(--sp-4) var(--sp-4) var(--sp-2);">
          <strong style="font-size:var(--fs-sm);">Notifications</strong>
          <button class="link-more" id="notifMarkAllBtn" style="font-size:11px;">Mark all read</button>
        </div>
        <div class="notif-list">${items}</div>
        <a href="inbox.html" class="link-more" style="justify-content:center;padding:var(--sp-3);border-top:1px solid var(--border-subtle);">View all in Inbox ${ICON.arrowRight}</a>
      </div>`;
  }

  function renderAIFab() {
    return `
      <button class="ai-fab" id="aiFabBtn">${ICON.sparkles} <span>AI Assistant</span></button>
      <div class="ai-panel" id="aiPanel" hidden>
        <div class="ai-panel-head">
          <div class="flex items-center gap-2">
            <div class="ai-panel-icon">${ICON.sparkles}</div>
            <div>
              <strong style="font-size:var(--fs-sm);">AI Assistant</strong>
              <p style="margin:0;font-size:var(--fs-2xs);">Break down tasks, suggest priorities, write better descriptions.</p>
            </div>
          </div>
          <button class="icon-btn" id="aiCloseBtn" style="width:32px;height:32px;">${ICON.close}</button>
        </div>
        <div class="ai-panel-body" id="aiPanelBody">
          <div class="ai-msg ai-msg-bot">👋 Hi ${MDG.user.name.split(" ")[0]}! Paste a task and I can break it into subtasks, suggest a priority, or tighten the description. Try one of these:</div>
          <div class="ai-suggest-row">
            <button class="chip" data-ai="breakdown">${ICON.list} Break into subtasks</button>
            <button class="chip" data-ai="priority">${ICON.flame} Suggest priority</button>
            <button class="chip" data-ai="rewrite">${ICON.edit} Improve description</button>
            <button class="chip" data-ai="checklist">${ICON.check} Generate checklist</button>
          </div>
        </div>
        <div class="ai-panel-input">
          <input type="text" placeholder="Ask AI Assistant anything…" id="aiInput" />
          <button class="btn btn-primary btn-icon" id="aiSendBtn">${ICON.send}</button>
        </div>
      </div>`;
  }

  function renderToastStack() {
    return `<div class="toast-stack" id="toastStack"></div>`;
  }

  function toast(message, type = "success") {
    const stack = document.getElementById("toastStack");
    if (!stack) return;
    const icons = { success: ICON.check, info: ICON.bulb, warn: ICON.flame };
    const colors = { success: "badge-mint", info: "badge-sky", warn: "badge-amber" };
    const el = document.createElement("div");
    el.className = "toast";
    el.innerHTML = `<span class="toast-icon ${colors[type]}">${icons[type] || ICON.check}</span><span>${message}</span>`;
    stack.appendChild(el);
    setTimeout(() => {
      el.style.transition = "opacity .3s ease, transform .3s ease";
      el.style.opacity = "0";
      el.style.transform = "translateX(20px)";
      setTimeout(() => el.remove(), 300);
    }, 3400);
  }

  function bindShellEvents() {
    const mobileToggle = document.getElementById("mobileNavToggle");
    const sidebar = document.getElementById("sidebar");
    if (mobileToggle && sidebar) {
      mobileToggle.addEventListener("click", () => sidebar.classList.toggle("is-open"));
      document.addEventListener("click", (e) => {
        if (sidebar.classList.contains("is-open") && !sidebar.contains(e.target) && e.target !== mobileToggle && !mobileToggle.contains(e.target)) {
          sidebar.classList.remove("is-open");
        }
      });
    }

    const userPodChevron = document.getElementById("userPodChevron");
    const userPodMenu = document.getElementById("userPodMenu");
    if (userPodChevron && userPodMenu) {
      userPodChevron.addEventListener("click", (e) => {
        e.stopPropagation();
        userPodMenu.hidden = !userPodMenu.hidden;
      });
      document.addEventListener("click", (e) => {
        if (!userPodMenu.hidden && !userPodMenu.contains(e.target) && e.target !== userPodChevron) userPodMenu.hidden = true;
      });
    }

    const notifBtn = document.getElementById("notifBtn");
    const notifPanel = document.getElementById("notifPanel");
    if (notifBtn && notifPanel) {
      notifBtn.addEventListener("click", (e) => {
        e.stopPropagation();
        notifPanel.hidden = !notifPanel.hidden;
      });
      document.addEventListener("click", (e) => {
        if (!notifPanel.hidden && !notifPanel.contains(e.target) && e.target !== notifBtn) notifPanel.hidden = true;
      });
      const markAllBtn = document.getElementById("notifMarkAllBtn");
      if (markAllBtn) {
        markAllBtn.addEventListener("click", () => {
          MDG.notifications.forEach(n => n.unread = false);
          MDG.saveState();
          notifBtn.querySelector(".dot")?.remove();
          document.querySelector('.nav-item[href="inbox.html"] .badge')?.remove();
          notifPanel.querySelectorAll(".notif-item.is-unread").forEach(el => el.classList.remove("is-unread"));
          toast("All notifications marked as read", "success");
        });
      }
    }

    const aiFabBtn = document.getElementById("aiFabBtn");
    const aiPanel = document.getElementById("aiPanel");
    const aiCloseBtn = document.getElementById("aiCloseBtn");
    if (aiFabBtn && aiPanel) {
      aiFabBtn.addEventListener("click", () => { aiPanel.hidden = !aiPanel.hidden; });
      aiCloseBtn.addEventListener("click", () => { aiPanel.hidden = true; });
    }

    const aiBody = document.getElementById("aiPanelBody");
    const aiInput = document.getElementById("aiInput");
    const aiSendBtn = document.getElementById("aiSendBtn");

    function aiRespond(userText, presetKey) {
      const responses = {
        breakdown: "Here's a subtask breakdown:<br>1. Define scope & success criteria<br>2. Draft first version<br>3. Get feedback from a peer<br>4. Revise & finalize<br>5. Mark complete",
        priority: "Based on the due date and impact, I'd suggest <strong>High priority</strong> — it's time-sensitive and blocks downstream work.",
        rewrite: "Improved description:<br><em>“Deliver a polished, review-ready version by end of day, covering the core flow and edge cases discussed in standup.”</em>",
        checklist: "Checklist generated:<br>☐ Research<br>☐ Draft<br>☐ Review<br>☐ Refine<br>☐ Ship",
      };
      const botText = presetKey ? responses[presetKey] : "Got it — I'd break that into smaller, testable steps and tackle the highest-impact one first. Want me to draft subtasks?";
      const userBubble = userText ? `<div class="ai-msg ai-msg-user">${userText}</div>` : "";
      aiBody.insertAdjacentHTML("beforeend", `${userBubble}<div class="ai-msg ai-msg-bot">${botText}</div>`);
      aiBody.scrollTop = aiBody.scrollHeight;
    }

    if (aiBody) {
      aiBody.addEventListener("click", (e) => {
        const chip = e.target.closest("[data-ai]");
        if (chip) aiRespond(chip.textContent.trim(), chip.dataset.ai);
      });
    }
    if (aiSendBtn && aiInput) {
      const send = () => {
        if (!aiInput.value.trim()) return;
        aiRespond(aiInput.value.trim(), null);
        aiInput.value = "";
      };
      aiSendBtn.addEventListener("click", send);
      aiInput.addEventListener("keydown", (e) => { if (e.key === "Enter") send(); });
    }
  }

  function mount(pageTitle, pageSubtitle) {
    const shellRoot = document.getElementById("appShell");
    if (!shellRoot) return;
    shellRoot.insertAdjacentHTML("afterbegin", renderSidebar());
    const main = shellRoot.querySelector("#mainContent") || shellRoot;
    const topbarWrap = document.getElementById("topbarSlot");
    if (topbarWrap) topbarWrap.outerHTML = renderTopbar(pageTitle, pageSubtitle) + renderNotifPanel();
    document.body.insertAdjacentHTML("beforeend", renderAIFab() + renderToastStack());
    bindShellEvents();
    // The topbar (and its theme-toggle) was just injected, so wire it up now —
    // theme.js's own DOMContentLoaded binding already ran before this markup existed.
    if (typeof MDG_THEME !== "undefined") {
      MDG_THEME.bindToggle();
      MDG_THEME.apply();
    }
  }

  return { mount, toast, renderSidebar, renderTopbar, currentPage };
})();
