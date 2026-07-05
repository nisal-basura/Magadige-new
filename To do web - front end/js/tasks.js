/* ==========================================================================
   Task Management page — grid/table/kanban views, filters, search, sort,
   drawer, create/edit modal, bulk actions, kanban drag-drop, swipe actions.
   ========================================================================== */

const TState = {
  view: "grid",
  sort: "due",
  search: "",
  statusFilter: "all",
  priorityFilter: null,
  favoriteOnly: false,
  selected: new Set(),
  editingId: null,
  subtasks: [],
};

document.addEventListener("DOMContentLoaded", () => {
  MDG_SHELL.mount("Tasks", "Everything you need to do, organized your way.");
  bindIcons();
  populateCategorySelect();
  populateDreamSelect();
  bindToolbar();
  bindModal();
  bindDrawerClose();
  render();
});

function bindIcons() {
  document.getElementById("plusIcon").innerHTML = ICON.plus;
  document.getElementById("searchIcon").innerHTML = ICON.search;
  document.getElementById("filterIcon").innerHTML = ICON.filter;
  document.getElementById("tabGrid").prepend(makeIconEl(ICON.grid));
  document.getElementById("tabTable").prepend(makeIconEl(ICON.list));
  document.getElementById("tabKanban").prepend(makeIconEl(ICON.columns));
  document.getElementById("tabGrid").append(document.createTextNode(" Grid"));
  document.getElementById("tabTable").append(document.createTextNode(" Table"));
  document.getElementById("tabKanban").append(document.createTextNode(" Kanban"));
  document.getElementById("bcIcon").innerHTML = ICON.check;
  document.getElementById("baIcon").innerHTML = ICON.archive;
  document.getElementById("bdIcon").innerHTML = ICON.copy;
  document.getElementById("btIcon").innerHTML = ICON.trash;
  document.getElementById("closeIcon").innerHTML = ICON.close;
  document.getElementById("addSubIcon").innerHTML = ICON.plus;
  document.getElementById("paperclipIcon").innerHTML = ICON.paperclip;
}
function makeIconEl(svg) { const s = document.createElement("span"); s.innerHTML = svg; s.style.display = "inline-flex"; return s; }

function populateCategorySelect() {
  document.getElementById("ctCategory").innerHTML = MDG.CATEGORIES.map(c => `<option value="${c.id}">${c.label}</option>`).join("");
}

function populateDreamSelect() {
  const options = MDG.dreams.map(d => `<option value="${d.id}">${d.emoji} ${d.title}</option>`).join("");
  document.getElementById("ctDream").innerHTML = `<option value="">No dream — general task</option>${options}`;
}

function bindToolbar() {
  document.querySelectorAll("#viewSwitch .tab").forEach(tab => {
    tab.addEventListener("click", () => {
      document.querySelectorAll("#viewSwitch .tab").forEach(t => t.classList.remove("is-active"));
      tab.classList.add("is-active");
      TState.view = tab.dataset.view;
      render();
    });
  });
  document.querySelectorAll("#sortSwitch .tab").forEach(tab => {
    tab.addEventListener("click", () => {
      document.querySelectorAll("#sortSwitch .tab").forEach(t => t.classList.remove("is-active"));
      tab.classList.add("is-active");
      TState.sort = tab.dataset.sort;
      render();
    });
  });
  document.getElementById("taskSearch").addEventListener("input", (e) => { TState.search = e.target.value.toLowerCase(); render(); });

  document.querySelectorAll("#filterRow .chip[data-filter-status]").forEach(chip => {
    chip.addEventListener("click", () => {
      document.querySelectorAll("#filterRow .chip[data-filter-status]").forEach(c => c.classList.remove("is-active"));
      chip.classList.add("is-active");
      TState.statusFilter = chip.dataset.filterStatus;
      render();
    });
  });
  const priorityChip = document.querySelector('[data-filter-priority]');
  priorityChip.addEventListener("click", () => {
    priorityChip.classList.toggle("is-active");
    TState.priorityFilter = priorityChip.classList.contains("is-active") ? "high" : null;
    render();
  });
  const favChip = document.querySelector('[data-filter-favorite]');
  favChip.addEventListener("click", () => {
    favChip.classList.toggle("is-active");
    TState.favoriteOnly = favChip.classList.contains("is-active");
    render();
  });
  document.getElementById("clearFiltersBtn").addEventListener("click", () => {
    TState.search = ""; TState.statusFilter = "all"; TState.priorityFilter = null; TState.favoriteOnly = false;
    document.getElementById("taskSearch").value = "";
    document.querySelectorAll("#filterRow .chip").forEach(c => c.classList.remove("is-active"));
    document.querySelector('[data-filter-status="all"]').classList.add("is-active");
    render();
  });

  document.getElementById("newTaskBtn").addEventListener("click", () => openTaskModal());
  document.getElementById("bulkComplete").addEventListener("click", () => bulkAction("complete"));
  document.getElementById("bulkArchive").addEventListener("click", () => bulkAction("archive"));
  document.getElementById("bulkDuplicate").addEventListener("click", () => bulkAction("duplicate"));
  document.getElementById("bulkDelete").addEventListener("click", () => bulkAction("delete"));
}

function getFilteredTasks() {
  let list = MDG.tasks.filter(t => !t.archived);
  if (TState.search) list = list.filter(t => t.title.toLowerCase().includes(TState.search) || t.tags.some(tag => tag.toLowerCase().includes(TState.search)));
  if (TState.statusFilter !== "all") list = list.filter(t => t.status === TState.statusFilter);
  if (TState.priorityFilter) list = list.filter(t => t.priority === TState.priorityFilter);
  if (TState.favoriteOnly) list = list.filter(t => t.favorite);

  const priorityRank = { high: 0, medium: 1, low: 2 };
  list.sort((a, b) => {
    if (TState.sort === "priority") return priorityRank[a.priority] - priorityRank[b.priority];
    if (TState.sort === "created") return b.createdAt.localeCompare(a.createdAt);
    return a.due.localeCompare(b.due);
  });
  return list;
}

function render() {
  const list = getFilteredTasks();
  document.getElementById("resultCount").textContent = `${list.length} task${list.length === 1 ? "" : "s"}`;
  document.getElementById("taskGrid").hidden = TState.view !== "grid";
  document.getElementById("taskTableWrap").hidden = TState.view !== "table";
  document.getElementById("kanbanWrap").hidden = TState.view !== "kanban";
  document.getElementById("emptyState").hidden = list.length > 0;

  if (TState.view === "grid") renderGrid(list);
  else if (TState.view === "table") renderTable(list);
  else renderKanban(list);

  renderBulkBar();
}

function statusMeta(status) {
  return {
    pending: { label: "Pending", cls: "badge-sky" },
    "in-progress": { label: "In progress", cls: "badge-indigo" },
    completed: { label: "Completed", cls: "badge-mint" },
    overdue: { label: "Overdue", cls: "badge-coral" },
  }[status];
}

function dueLabel(dateStr, status) {
  const d = new Date(dateStr + "T00:00:00");
  const label = d.toLocaleDateString([], { month: "short", day: "numeric" });
  return { label, overdue: status === "overdue" };
}

/* ---- Grid view --------------------------------------------------------- */
function renderGrid(list) {
  const grid = document.getElementById("taskGrid");
  grid.innerHTML = list.map(t => {
    const sm = statusMeta(t.status);
    const due = dueLabel(t.due, t.status);
    const cat = MDG.categoryOf(t.category);
    return `
    <div class="card task-card hover-lift ${TState.selected.has(t.id) ? "is-selected" : ""}" data-id="${t.id}">
      <div class="task-card-top">
        <div class="task-card-select">
          <input type="checkbox" class="checkbox card-select-box" data-id="${t.id}" ${TState.selected.has(t.id) ? "checked" : ""} />
          <span class="priority-dot priority-${t.priority}"></span>
        </div>
        <div class="task-card-actions">
          <button class="task-card-fav ${t.favorite ? "is-fav" : ""}" data-action="favorite" data-id="${t.id}" data-tooltip="Favorite">${ICON.starOutline}</button>
          <button data-action="duplicate" data-id="${t.id}" data-tooltip="Duplicate">${ICON.copy}</button>
          <button data-action="archive" data-id="${t.id}" data-tooltip="Archive">${ICON.archive}</button>
          <button data-action="delete" data-id="${t.id}" data-tooltip="Delete">${ICON.trash}</button>
        </div>
      </div>
      <div>
        <div class="task-card-title">${t.title}</div>
        <p class="task-card-desc">${t.description || "No description added."}</p>
      </div>
      <div class="task-card-tags">
        <span class="badge badge-${cat.color}">${cat.label}</span>
        <span class="badge ${sm.cls}">${sm.label}</span>
      </div>
      ${t.progress > 0 ? `<div class="progress-bar"><div class="progress-bar-fill" style="width:${t.progress}%"></div></div>` : ""}
      <div class="task-card-footer">
        <span class="task-card-due ${due.overdue ? "is-overdue" : ""}">${ICON.calendar} ${due.label}</span>
        <span style="font-size:var(--fs-2xs);color:var(--text-tertiary);">${t.estimate}</span>
      </div>
    </div>`;
  }).join("");

  grid.querySelectorAll(".task-card").forEach(card => {
    card.addEventListener("click", (e) => {
      if (e.target.closest("button") || e.target.closest("input")) return;
      openDrawer(card.dataset.id);
    });
    bindSwipe(card);
  });
  bindCardActions(grid);
}

/* ---- Table view --------------------------------------------------------- */
function renderTable(list) {
  const body = document.getElementById("taskTableBody");
  body.innerHTML = list.map(t => {
    const sm = statusMeta(t.status);
    const due = dueLabel(t.due, t.status);
    return `
    <tr data-id="${t.id}">
      <td onclick="event.stopPropagation()"><input type="checkbox" class="checkbox card-select-box" data-id="${t.id}" ${TState.selected.has(t.id) ? "checked" : ""} /></td>
      <td class="t-title">${t.title}</td>
      <td>${MDG.categoryOf(t.category).label}</td>
      <td><span class="priority-dot priority-${t.priority}"></span> ${t.priority}</td>
      <td><span class="badge ${sm.cls}">${sm.label}</span></td>
      <td class="${due.overdue ? "text-brand" : ""}" style="${due.overdue ? "color:var(--coral-600);font-weight:700;" : ""}">${due.label}</td>
      <td onclick="event.stopPropagation()">
        <div class="task-card-actions" style="opacity:1;">
          <button data-action="favorite" data-id="${t.id}">${ICON.starOutline}</button>
          <button data-action="delete" data-id="${t.id}">${ICON.trash}</button>
        </div>
      </td>
    </tr>`;
  }).join("");

  body.querySelectorAll("tr").forEach(row => row.addEventListener("click", () => openDrawer(row.dataset.id)));
  bindCardActions(body);

  document.querySelectorAll(".task-table th[data-sort-col]").forEach(th => {
    th.addEventListener("click", () => {
      const col = th.dataset.sortCol;
      if (col === "due" || col === "priority") { TState.sort = col === "due" ? "due" : "priority"; render(); }
    });
  });
  const selectAll = document.getElementById("selectAllRows");
  selectAll.checked = list.length > 0 && list.every(t => TState.selected.has(t.id));
  selectAll.onclick = () => {
    if (selectAll.checked) list.forEach(t => TState.selected.add(t.id));
    else list.forEach(t => TState.selected.delete(t.id));
    render();
  };
}

/* ---- Kanban view --------------------------------------------------------- */
function renderKanban(list) {
  const cols = [
    { key: "pending", label: "Pending" },
    { key: "in-progress", label: "In Progress" },
    { key: "completed", label: "Completed" },
    { key: "overdue", label: "Overdue" },
  ];
  const wrap = document.getElementById("kanbanWrap");
  wrap.innerHTML = cols.map(col => {
    const items = list.filter(t => t.status === col.key);
    return `
    <div class="kanban-col" data-status="${col.key}">
      <div class="kanban-col-head"><h4>${col.label}</h4><span class="badge badge-gray">${items.length}</span></div>
      <div class="kanban-cards" data-status="${col.key}">
        ${items.map(t => `
          <div class="kanban-card" draggable="true" data-id="${t.id}">
            <div class="kanban-card-title">${t.title}</div>
            <div class="task-card-tags"><span class="badge badge-gray">${MDG.categoryOf(t.category).label}</span></div>
            <div class="kanban-card-foot">
              <span class="priority-dot priority-${t.priority}"></span>
              <span style="font-size:11px;color:var(--text-tertiary);">${dueLabel(t.due, t.status).label}</span>
            </div>
          </div>`).join("")}
      </div>
    </div>`;
  }).join("");

  wrap.querySelectorAll(".kanban-card").forEach(card => {
    card.addEventListener("click", () => openDrawer(card.dataset.id));
    card.addEventListener("dragstart", () => card.classList.add("is-dragging"));
    card.addEventListener("dragend", () => card.classList.remove("is-dragging"));
  });
  wrap.querySelectorAll(".kanban-col").forEach(col => {
    col.addEventListener("dragover", (e) => { e.preventDefault(); col.classList.add("is-dragover"); });
    col.addEventListener("dragleave", () => col.classList.remove("is-dragover"));
    col.addEventListener("drop", (e) => {
      e.preventDefault();
      col.classList.remove("is-dragover");
      const dragging = wrap.querySelector(".is-dragging");
      if (!dragging) return;
      const task = MDG.tasks.find(t => t.id === dragging.dataset.id);
      task.status = col.dataset.status;
      MDG.saveState();
      MDG_SHELL.toast(`Moved "${task.title}" to ${col.dataset.status.replace("-", " ")}`, "success");
      render();
    });
  });
}

/* ---- Shared card action handling ------------------------------------------ */
function bindCardActions(root) {
  root.querySelectorAll(".card-select-box").forEach(box => {
    box.addEventListener("click", (e) => e.stopPropagation());
    box.addEventListener("change", () => {
      if (box.checked) TState.selected.add(box.dataset.id); else TState.selected.delete(box.dataset.id);
      renderBulkBar();
      root.closest(".task-card, tr")?.classList.toggle("is-selected", box.checked);
    });
  });
  root.querySelectorAll("[data-action]").forEach(btn => {
    btn.addEventListener("click", (e) => {
      e.stopPropagation();
      const id = btn.dataset.id;
      const task = MDG.tasks.find(t => t.id === id);
      const action = btn.dataset.action;
      if (action === "favorite") { task.favorite = !task.favorite; MDG.saveState(); MDG_SHELL.toast(task.favorite ? "Added to favorites" : "Removed from favorites", "success"); render(); }
      if (action === "duplicate") { duplicateTask(task); }
      if (action === "archive") { task.archived = true; MDG.saveState(); MDG_SHELL.toast("Task archived", "info"); render(); }
      if (action === "delete") { MDG.tasks.splice(MDG.tasks.indexOf(task), 1); MDG.saveState(); MDG_SHELL.toast("Task deleted", "warn"); render(); }
    });
  });
}

function duplicateTask(task) {
  const copy = { ...task, id: "t" + Date.now(), title: task.title + " (copy)", createdAt: new Date().toISOString().slice(0, 10) };
  MDG.tasks.unshift(copy);
  MDG.saveState();
  MDG_SHELL.toast("Task duplicated", "success");
  render();
}

/* ---- Bulk bar ------------------------------------------------------------- */
function renderBulkBar() {
  const bar = document.getElementById("bulkBar");
  bar.hidden = TState.selected.size === 0;
  document.getElementById("bulkCount").textContent = TState.selected.size;
}
function bulkAction(type) {
  const ids = Array.from(TState.selected);
  ids.forEach(id => {
    const task = MDG.tasks.find(t => t.id === id);
    if (!task) return;
    if (type === "complete") { task.status = "completed"; task.progress = 100; }
    if (type === "archive") task.archived = true;
    if (type === "delete") MDG.tasks.splice(MDG.tasks.indexOf(task), 1);
    if (type === "duplicate") duplicateTask(task);
  });
  MDG.saveState();
  TState.selected.clear();
  MDG_SHELL.toast(`Bulk ${type} applied to ${ids.length} task${ids.length === 1 ? "" : "s"}`, "success");
  render();
}

/* ---- Swipe actions (touch) -------------------------------------------------- */
function bindSwipe(card) {
  let startX = 0, deltaX = 0;
  card.addEventListener("touchstart", (e) => { startX = e.touches[0].clientX; }, { passive: true });
  card.addEventListener("touchmove", (e) => {
    deltaX = e.touches[0].clientX - startX;
    if (Math.abs(deltaX) > 8) card.style.transform = `translateX(${Math.max(-70, Math.min(70, deltaX))}px)`;
  }, { passive: true });
  card.addEventListener("touchend", () => {
    if (deltaX > 60) { card.style.transform = ""; document.querySelector(`[data-action="favorite"][data-id="${card.dataset.id}"]`)?.click(); }
    else if (deltaX < -60) { card.style.transform = ""; document.querySelector(`[data-action="archive"][data-id="${card.dataset.id}"]`)?.click(); }
    else card.style.transform = "";
    deltaX = 0;
  });
}

/* ---- Drawer ---------------------------------------------------------------- */
function openDrawer(id) {
  const task = MDG.tasks.find(t => t.id === id);
  if (!task) return;
  const sm = statusMeta(task.status);
  const cat = MDG.categoryOf(task.category);
  document.getElementById("taskDrawer").innerHTML = `
    <div class="drawer-head">
      <span class="badge ${sm.cls}">${sm.label}</span>
      <button class="icon-btn" id="drawerCloseBtn" style="width:32px;height:32px;">${ICON.close}</button>
    </div>
    <div class="drawer-body">
      <div>
        <h3 style="margin-bottom:8px;">${task.title}</h3>
        <p style="font-size:var(--fs-sm);">${task.description || "No description added yet."}</p>
      </div>
      <div>
        <div class="drawer-section-label">Details</div>
        <div class="score-detail-row"><span class="text-secondary">Category</span><strong>${cat.label}</strong></div>
        <div class="score-detail-row"><span class="text-secondary">Priority</span><strong style="text-transform:capitalize;">${task.priority}</strong></div>
        <div class="score-detail-row"><span class="text-secondary">Due date</span><strong>${task.due}</strong></div>
        <div class="score-detail-row"><span class="text-secondary">Estimated time</span><strong>${task.estimate}</strong></div>
      </div>
      <div>
        <div class="drawer-section-label">Progress</div>
        <div class="progress-bar" style="margin-bottom:6px;"><div class="progress-bar-fill" style="width:${task.progress}%"></div></div>
        <span style="font-size:var(--fs-xs);color:var(--text-tertiary);">${task.progress}% complete</span>
      </div>
      <div>
        <div class="drawer-section-label">Tags</div>
        <div class="task-card-tags">${task.tags.map(tag => `<span class="chip">#${tag}</span>`).join("") || '<span class="text-tertiary" style="font-size:12px;">No tags</span>'}</div>
      </div>
    </div>
    <div class="drawer-actions">
      <a href="task-details.html?id=${task.id}" class="btn btn-primary btn-block">Open full details</a>
      <button class="btn btn-secondary" id="drawerEditBtn">${ICON.edit}</button>
    </div>`;
  document.getElementById("drawerCloseBtn").addEventListener("click", closeDrawer);
  document.getElementById("drawerEditBtn").addEventListener("click", () => { closeDrawer(); openTaskModal(task.id); });
  document.getElementById("taskDrawer").hidden = false;
  document.getElementById("drawerOverlay").hidden = false;
}
function closeDrawer() {
  document.getElementById("taskDrawer").hidden = true;
  document.getElementById("drawerOverlay").hidden = true;
}
function bindDrawerClose() {
  document.getElementById("drawerOverlay").addEventListener("click", closeDrawer);
}

/* ---- Create / Edit modal ---------------------------------------------------- */
function bindModal() {
  document.getElementById("closeModalBtn").addEventListener("click", closeTaskModal);
  document.getElementById("cancelModalBtn").addEventListener("click", closeTaskModal);
  document.getElementById("modalOverlay").addEventListener("click", closeTaskModal);
  document.querySelectorAll(".color-swatch").forEach(sw => {
    sw.addEventListener("click", () => {
      document.querySelectorAll(".color-swatch").forEach(s => s.classList.remove("is-active"));
      sw.classList.add("is-active");
    });
  });
  document.getElementById("addSubtaskBtn").addEventListener("click", () => addSubtaskRow());
  document.getElementById("attachmentDrop").addEventListener("click", () => MDG_SHELL.toast("Attachment upload is a UI demo only.", "info"));
  document.getElementById("taskForm").addEventListener("submit", (e) => {
    e.preventDefault();
    saveTaskFromModal();
  });
}

function addSubtaskRow(value = "") {
  const list = document.getElementById("subtaskList");
  const row = document.createElement("div");
  row.className = "subtask-row";
  row.innerHTML = `<input type="checkbox" class="checkbox" /><input type="text" class="input" placeholder="Subtask title" value="${value}" /><button type="button" class="icon-btn" style="width:32px;height:32px;">${ICON.close}</button>`;
  row.querySelector("button").addEventListener("click", () => row.remove());
  list.appendChild(row);
}

function openTaskModal(id = null) {
  TState.editingId = id;
  const form = document.getElementById("taskForm");
  form.reset();
  document.getElementById("subtaskList").innerHTML = "";
  document.querySelectorAll(".color-swatch").forEach((s, i) => s.classList.toggle("is-active", i === 0));

  if (id) {
    const task = MDG.tasks.find(t => t.id === id);
    document.getElementById("taskModalTitle").textContent = "Edit Task";
    document.getElementById("ctTitle").value = task.title;
    document.getElementById("ctDescription").value = task.description || "";
    document.getElementById("ctPriority").value = task.priority;
    document.getElementById("ctCategory").value = task.category;
    document.getElementById("ctDeadline").value = task.due;
    document.getElementById("ctEstimate").value = task.estimate;
    const linkedDream = MDG.dreams.find(d => d.relatedTaskIds.includes(task.id));
    document.getElementById("ctDream").value = linkedDream ? linkedDream.id : "";
  } else {
    document.getElementById("taskModalTitle").textContent = "Create Task";
    document.getElementById("ctDeadline").value = new Date().toISOString().slice(0, 10);
    addSubtaskRow();
  }
  document.getElementById("createTaskModal").hidden = false;
  document.getElementById("modalOverlay").hidden = false;
}
function closeTaskModal() {
  document.getElementById("createTaskModal").hidden = true;
  document.getElementById("modalOverlay").hidden = true;
}

function saveTaskFromModal() {
  const title = document.getElementById("ctTitle").value.trim();
  if (!title) return;
  const data = {
    title,
    description: document.getElementById("ctDescription").value.trim(),
    priority: document.getElementById("ctPriority").value,
    category: document.getElementById("ctCategory").value,
    due: document.getElementById("ctDeadline").value || new Date().toISOString().slice(0, 10),
    estimate: document.getElementById("ctEstimate").value || "—",
  };
  const dreamId = document.getElementById("ctDream").value;
  let taskId;
  if (TState.editingId) {
    taskId = TState.editingId;
    Object.assign(MDG.tasks.find(t => t.id === taskId), data);
    MDG_SHELL.toast("Task updated", "success");
  } else {
    taskId = "t" + Date.now();
    MDG.tasks.unshift({
      id: taskId, ...data, status: "pending", tags: [], progress: 0, favorite: false,
      createdAt: new Date().toISOString().slice(0, 10),
    });
    MDG_SHELL.toast("Task created", "success");
  }
  // Keep dream linkage exclusive: unlink from any previous dream first, then
  // link to the newly selected one (if any).
  MDG.dreams.forEach(d => { d.relatedTaskIds = d.relatedTaskIds.filter(id => id !== taskId); });
  if (dreamId) {
    const dream = MDG.dreams.find(d => d.id === dreamId);
    if (dream) dream.relatedTaskIds.push(taskId);
  }
  MDG.saveState();
  closeTaskModal();
  render();
}
