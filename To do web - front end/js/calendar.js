/* ==========================================================================
   Calendar page — month grid with task chips + day detail panel
   ========================================================================== */

let CAL_YEAR, CAL_MONTH, CAL_SELECTED;
const CAL_PRIORITY_BADGE = { high: "badge-coral", medium: "badge-amber", low: "badge-mint" };

document.addEventListener("DOMContentLoaded", () => {
  MDG_SHELL.mount("Calendar", "Every task, mapped to a day.");
  document.getElementById("calPrevIcon").innerHTML = ICON.chevronLeft;
  document.getElementById("calNextIcon").innerHTML = ICON.chevronRight;
  document.getElementById("calPlusIcon").innerHTML = ICON.plus;
  document.getElementById("calQuickPlusIcon").innerHTML = ICON.plus;

  const today = new Date();
  CAL_YEAR = today.getFullYear();
  CAL_MONTH = today.getMonth();
  CAL_SELECTED = today.toISOString().slice(0, 10);

  document.getElementById("calPrevBtn").addEventListener("click", () => shiftMonth(-1));
  document.getElementById("calNextBtn").addEventListener("click", () => shiftMonth(1));
  document.getElementById("calTodayBtn").addEventListener("click", () => {
    const t = new Date();
    CAL_YEAR = t.getFullYear(); CAL_MONTH = t.getMonth(); CAL_SELECTED = t.toISOString().slice(0, 10);
    render();
  });
  document.getElementById("calNewTaskBtn").addEventListener("click", () => quickAdd(true));
  document.getElementById("calQuickAddBtn").addEventListener("click", () => quickAdd(false));
  document.getElementById("calQuickAddInput").addEventListener("keydown", (e) => { if (e.key === "Enter") quickAdd(false); });

  render();
});

function shiftMonth(delta) {
  CAL_MONTH += delta;
  if (CAL_MONTH < 0) { CAL_MONTH = 11; CAL_YEAR--; }
  if (CAL_MONTH > 11) { CAL_MONTH = 0; CAL_YEAR++; }
  render();
}

function tasksByDate() {
  const map = {};
  MDG.tasks.forEach(t => { (map[t.due] = map[t.due] || []).push(t); });
  return map;
}

function render() {
  const monthLabel = new Date(CAL_YEAR, CAL_MONTH, 1).toLocaleDateString([], { month: "long", year: "numeric" });
  document.getElementById("calMonthLabel").textContent = monthLabel;

  const map = tasksByDate();
  const firstDay = new Date(CAL_YEAR, CAL_MONTH, 1).getDay();
  const daysInMonth = new Date(CAL_YEAR, CAL_MONTH + 1, 0).getDate();
  const prevDays = new Date(CAL_YEAR, CAL_MONTH, 0).getDate();
  const todayStr = new Date().toISOString().slice(0, 10);

  let html = "";
  for (let i = firstDay - 1; i >= 0; i--) {
    html += `<div class="cal-day is-muted"><span class="cal-day-num">${prevDays - i}</span></div>`;
  }
  for (let d = 1; d <= daysInMonth; d++) {
    const dateStr = `${CAL_YEAR}-${String(CAL_MONTH + 1).padStart(2, "0")}-${String(d).padStart(2, "0")}`;
    const dayTasks = map[dateStr] || [];
    const isToday = dateStr === todayStr;
    const isSelected = dateStr === CAL_SELECTED;
    const chips = dayTasks.slice(0, 3).map(t => `<span class="cal-day-chip ${CAL_PRIORITY_BADGE[t.priority]}">${t.title}</span>`).join("");
    const more = dayTasks.length > 3 ? `<span class="cal-day-more">+${dayTasks.length - 3} more</span>` : "";
    html += `
      <div class="cal-day ${isToday ? "is-today" : ""} ${isSelected ? "is-selected" : ""}" data-date="${dateStr}">
        <span class="cal-day-num">${d}</span>
        <div class="cal-day-chips">${chips}${more}</div>
      </div>`;
  }
  const totalCells = firstDay + daysInMonth;
  const remainder = totalCells % 7;
  if (remainder) for (let i = 1; i <= 7 - remainder; i++) html += `<div class="cal-day is-muted"><span class="cal-day-num">${i}</span></div>`;

  const grid = document.getElementById("calDays");
  grid.innerHTML = html;
  grid.querySelectorAll(".cal-day:not(.is-muted)").forEach(cell => {
    cell.addEventListener("click", () => { CAL_SELECTED = cell.dataset.date; render(); });
  });

  renderSidePanel(map);
}

function renderSidePanel(map) {
  const dateObj = new Date(CAL_SELECTED + "T00:00:00");
  const todayStr = new Date().toISOString().slice(0, 10);
  document.getElementById("calSideDate").textContent = dateObj.toLocaleDateString([], { weekday: "long", month: "long", day: "numeric" });
  document.getElementById("calSideSub").textContent = CAL_SELECTED === todayStr ? "Today" : (CAL_SELECTED < todayStr ? "Past day" : "Upcoming");

  const dayTasks = (map[CAL_SELECTED] || []).slice().sort((a, b) => (a.status === "completed") - (b.status === "completed"));
  const wrap = document.getElementById("calSideTasks");
  if (!dayTasks.length) {
    wrap.innerHTML = `<div class="empty-state" style="padding:var(--sp-8) var(--sp-2);">
      <img src="assets/illustrations/empty-tasks.svg" style="width:96px;margin-bottom:var(--sp-2);" alt="" />
      <p style="font-size:var(--fs-xs);">No tasks scheduled for this day.</p>
    </div>`;
    return;
  }
  wrap.innerHTML = dayTasks.map(t => `
    <div class="cal-side-task" data-task-id="${t.id}">
      <span class="focus-check ${t.status === "completed" ? "is-done" : ""}">${t.status === "completed" ? ICON.check : ""}</span>
      <div style="flex:1;">
        <div class="focus-title ${t.status === "completed" ? "is-done" : ""}">${t.title}</div>
        <div class="focus-meta"><span class="priority-dot priority-${t.priority}"></span>${MDG.categoryOf(t.category).label} · ${t.estimate}</div>
      </div>
      <a class="icon-btn" style="width:30px;height:30px;" href="task-details.html?id=${t.id}">${ICON.chevronRight}</a>
    </div>`).join("");

  wrap.querySelectorAll(".focus-check").forEach(el => {
    el.addEventListener("click", () => {
      const id = el.closest(".cal-side-task").dataset.taskId;
      const task = MDG.tasks.find(t => t.id === id);
      task.status = task.status === "completed" ? "pending" : "completed";
      task.progress = task.status === "completed" ? 100 : 40;
      MDG.saveState();
      MDG_SHELL.toast(task.status === "completed" ? "Task completed" : "Marked as pending", "success");
      render();
    });
  });
}

function quickAdd(useMonthDefault) {
  const input = document.getElementById("calQuickAddInput");
  const val = input.value.trim();
  if (!val) { input.focus(); return; }
  MDG.tasks.unshift({
    id: "t" + Date.now(), title: val, description: "", category: "work", priority: "medium",
    status: "pending", due: CAL_SELECTED, tags: [], estimate: "30m", progress: 0, favorite: false,
    createdAt: new Date().toISOString().slice(0, 10),
  });
  MDG.saveState();
  input.value = "";
  MDG_SHELL.toast(`Task added to ${CAL_SELECTED}`, "success");
  render();
}
