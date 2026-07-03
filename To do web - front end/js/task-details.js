/* ==========================================================================
   Task Details page — timeline, comments, activity, progress, history
   ========================================================================== */

let TD_TASK = null;
let TD_COMMENTS = [];

document.addEventListener("DOMContentLoaded", () => {
  MDG_SHELL.mount("Task Details", "Everything about this task in one place.");
  const params = new URLSearchParams(location.search);
  const id = params.get("id");
  TD_TASK = MDG.tasks.find(t => t.id === id) || MDG.tasks[0];

  bindIconButtons();
  renderHeader();
  renderProgress();
  renderSubtasks();
  renderTimeline();
  renderComments();
  renderActivity();
  renderHistory();
  renderSidebar();
  bindTabs();
  bindActions();
});

function bindIconButtons() {
  document.getElementById("tdFavIcon").innerHTML = ICON.starOutline;
  document.getElementById("tdEditIcon").innerHTML = ICON.edit;
  document.getElementById("tdDeleteIcon").innerHTML = ICON.trash;
  document.getElementById("commentAvatarInit").textContent = MDG.user.avatarInitials;
}

const STATUS_META = {
  pending: { label: "Pending", cls: "badge-sky" },
  "in-progress": { label: "In progress", cls: "badge-indigo" },
  completed: { label: "Completed", cls: "badge-mint" },
  overdue: { label: "Overdue", cls: "badge-coral" },
};

function renderHeader() {
  const t = TD_TASK;
  const sm = STATUS_META[t.status];
  document.title = `${t.title} — Magadige Task`;
  document.getElementById("tdTitle").textContent = t.title;
  const badge = document.getElementById("tdStatusBadge");
  badge.textContent = sm.label;
  badge.className = "badge " + sm.cls;
  document.getElementById("tdPriorityDot").className = "priority-dot priority-" + t.priority;
  document.getElementById("tdPriorityLabel").textContent = t.priority;
  document.getElementById("tdCategoryLabel").textContent = MDG.categoryOf(t.category).label;
  document.getElementById("tdDue").textContent = t.due;
  document.getElementById("tdDescription").textContent = t.description || "No description added for this task yet.";
  document.getElementById("tdFavBtn").classList.toggle("btn-accent", t.favorite);
}

function renderProgress() {
  document.getElementById("tdProgressPct").textContent = TD_TASK.progress + "%";
  document.getElementById("tdProgressFill").style.width = TD_TASK.progress + "%";
}

function subtasksFor(task) {
  const bank = task.subtasks || ["Research & plan approach", "Execute the core work", "Review with a peer", "Polish & finalize", "Mark as complete"];
  const doneCount = Math.round((task.progress / 100) * bank.length);
  return bank.map((title, i) => ({ title, done: i < doneCount }));
}

function renderSubtasks() {
  const subs = subtasksFor(TD_TASK);
  document.getElementById("subtaskChecklist").innerHTML = subs.map((s, i) => `
    <div class="subtask-item ${s.done ? "is-done" : ""}" data-i="${i}">
      <input type="checkbox" class="checkbox" ${s.done ? "checked" : ""} />
      <span class="subtitle">${s.title}</span>
    </div>`).join("");

  document.querySelectorAll(".subtask-item input").forEach(box => {
    box.addEventListener("change", () => {
      const row = box.closest(".subtask-item");
      row.classList.toggle("is-done", box.checked);
      const total = document.querySelectorAll(".subtask-item").length;
      const done = document.querySelectorAll(".subtask-item.is-done").length;
      TD_TASK.progress = Math.round((done / total) * 100);
      TD_TASK.status = TD_TASK.progress === 100 ? "completed" : (TD_TASK.progress > 0 ? "in-progress" : "pending");
      MDG.saveState();
      renderProgress();
      renderHeader();
      MDG_SHELL.toast("Progress updated", "success");
    });
  });
}

function renderTimeline() {
  const t = TD_TASK;
  const items = [
    { title: "Task created", time: t.createdAt, done: true },
    { title: "Work started", time: shiftDate(t.createdAt, 1), done: t.progress > 0 },
    { title: "Halfway checkpoint", time: shiftDate(t.createdAt, 3), done: t.progress >= 50 },
    { title: t.status === "completed" ? "Task completed" : "Due date", time: t.due, done: t.status === "completed", pending: t.status !== "completed" },
  ];
  document.getElementById("timelineList").innerHTML = items.map(it => `
    <div class="timeline-item ${it.done ? "is-done" : it.pending ? "is-pending" : ""}">
      <span class="timeline-dot"></span>
      <div class="timeline-title">${it.title}</div>
      <div class="timeline-time">${it.time}</div>
    </div>`).join("");
}
function shiftDate(dateStr, days) {
  const d = new Date(dateStr + "T00:00:00");
  d.setDate(d.getDate() + days);
  return d.toISOString().slice(0, 10);
}

function renderComments() {
  TD_COMMENTS = [
    { author: MDG.user.name, initials: MDG.user.avatarInitials, time: "2 days ago", text: "Let's make sure this aligns with the Q3 roadmap before we finalize." },
    { author: "Tunde Bakare", initials: "TB", time: "1 day ago", text: "Looks solid — left a couple of notes on the draft doc." },
  ];
  paintComments();
  document.getElementById("postCommentBtn").addEventListener("click", () => {
    const input = document.getElementById("newCommentInput");
    if (!input.value.trim()) return;
    TD_COMMENTS.push({ author: MDG.user.name, initials: MDG.user.avatarInitials, time: "Just now", text: input.value.trim() });
    input.value = "";
    paintComments();
    MDG_SHELL.toast("Comment posted", "success");
  });
}
function paintComments() {
  document.getElementById("commentList").innerHTML = TD_COMMENTS.map(c => `
    <div class="comment-item">
      <div class="avatar-text" style="width:36px;height:36px;font-size:11px;">${c.initials}</div>
      <div class="comment-bubble">
        <div class="comment-head"><strong>${c.author}</strong><span>${c.time}</span></div>
        <div class="comment-text">${c.text}</div>
      </div>
    </div>`).join("");
}

function renderActivity() {
  const items = [
    `Task created by ${MDG.user.name}`,
    `Priority set to ${TD_TASK.priority}`,
    `Category assigned: ${MDG.categoryOf(TD_TASK.category).label}`,
    TD_TASK.progress > 0 ? `Progress updated to ${TD_TASK.progress}%` : null,
    TD_TASK.favorite ? "Marked as favorite" : null,
  ].filter(Boolean);
  document.getElementById("tdActivityList").innerHTML = items.map(text => `
    <div class="td-activity-item"><span class="dot"></span><span>${text}</span></div>`).join("");
}

function renderHistory() {
  let seed = 0;
  for (const ch of TD_TASK.id) seed += ch.charCodeAt(0);
  let cells = "";
  for (let i = 0; i < 56; i++) {
    const v = (seed * (i + 1) * 9301 + 49297) % 233280 / 233280;
    const level = v > 0.85 ? 3 : v > 0.65 ? 2 : v > 0.4 ? 1 : 0;
    cells += `<div class="history-cell level-${level}"></div>`;
  }
  document.getElementById("historyStrip").innerHTML = cells;
}

function renderSidebar() {
  const t = TD_TASK;
  const sm = STATUS_META[t.status];
  document.getElementById("sideStatus").textContent = sm.label;
  document.getElementById("sidePriority").textContent = t.priority[0].toUpperCase() + t.priority.slice(1);
  document.getElementById("sideCategory").textContent = MDG.categoryOf(t.category).label;
  document.getElementById("sideDue").textContent = t.due;
  document.getElementById("sideEstimate").textContent = t.estimate;
  document.getElementById("sideCreated").textContent = t.createdAt;
  document.getElementById("sideTags").innerHTML = t.tags.length
    ? t.tags.map(tag => `<span class="chip">#${tag}</span>`).join("")
    : `<span class="text-tertiary" style="font-size:12px;">No tags added</span>`;

  const dream = MDG.dreams.find(d => d.relatedTaskIds.includes(t.id));
  if (dream) {
    document.getElementById("relatedDreamCard").hidden = false;
    document.getElementById("relatedDreamContent").innerHTML = `
      <span class="dream-nudge-emoji">${dream.emoji}</span>
      <div style="flex:1;">
        <strong style="font-size:var(--fs-sm);display:block;margin-bottom:6px;">${dream.title}</strong>
        <div class="progress-bar"><div class="progress-bar-fill" style="width:${dream.progress}%"></div></div>
      </div>`;
  }
}

function bindTabs() {
  document.querySelectorAll("#tdTabs .tab").forEach(tab => {
    tab.addEventListener("click", () => {
      document.querySelectorAll("#tdTabs .tab").forEach(t => t.classList.remove("is-active"));
      tab.classList.add("is-active");
      document.querySelectorAll(".tab-panel").forEach(p => p.hidden = true);
      document.getElementById("panel-" + tab.dataset.tab).hidden = false;
    });
  });
}

function bindActions() {
  document.getElementById("tdFavBtn").addEventListener("click", () => {
    TD_TASK.favorite = !TD_TASK.favorite;
    MDG.saveState();
    document.getElementById("tdFavBtn").classList.toggle("btn-accent", TD_TASK.favorite);
    MDG_SHELL.toast(TD_TASK.favorite ? "Added to favorites" : "Removed from favorites", "success");
  });
  document.getElementById("tdEditBtn").addEventListener("click", () => {
    location.href = "tasks.html";
  });
  document.getElementById("tdDeleteBtn").addEventListener("click", () => {
    const idx = MDG.tasks.indexOf(TD_TASK);
    if (idx > -1) MDG.tasks.splice(idx, 1);
    MDG.saveState();
    MDG_SHELL.toast("Task deleted", "warn");
    setTimeout(() => location.href = "tasks.html", 600);
  });
}
