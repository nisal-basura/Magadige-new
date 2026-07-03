/* ==========================================================================
   Dashboard page logic — wires dummy data + charts into the bento grid
   ========================================================================== */

document.addEventListener("DOMContentLoaded", () => {
  MDG_SHELL.mount("Dashboard", "Here's what's on your plate today.");
  renderGreeting();
  renderWeather();
  renderStats();
  renderMotivation();
  renderInspiration();
  renderFocusList();
  renderQuickAdd();
  MDG_CHART.barChart(document.getElementById("weeklyChart"), MDG.weeklyProgress);
  MDG_CHART.lineChart(document.getElementById("monthlyChart"), MDG.monthlyProgress);
  renderActivity();
  renderUpcoming();
  renderCalendar();
  renderProductivityScore();
  renderBadges();
  renderDreamNudge();
});

function renderGreeting() {
  const meta = MDG_THEME.meta();
  const now = new Date();
  const firstName = MDG.user.name.split(" ")[0];
  document.getElementById("greetingIcon").innerHTML = ICON[meta.icon];
  document.getElementById("greetingTitle").textContent = `${meta.greeting}, ${firstName}.`;
  document.getElementById("greetingMood").textContent = meta.mood;
  document.getElementById("clockNow").textContent = now.toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" });
  document.getElementById("dateNow").textContent = now.toLocaleDateString([], { weekday: "long", month: "long", day: "numeric" });
}

function renderWeather() {
  // Placeholder weather — no live API in this demo.
  document.getElementById("weatherIcon").innerHTML = ICON.sun;
  document.getElementById("weatherTemp").textContent = "27°C";
  document.getElementById("weatherDesc").textContent = "Partly sunny · Lagos";
}

function renderStats() {
  const s = MDG.taskStats();
  const tiles = [
    { label: "Completed", value: s.completed, icon: "check", color: "mint" },
    { label: "Pending", value: s.pending, icon: "clock", color: "sky" },
    { label: "Overdue", value: s.overdue, icon: "flame", color: "coral" },
    { label: "High Priority", value: s.highPriority, icon: "target", color: "amber" },
  ];
  const colorMap = {
    mint: ["hsl(155 65% 92%)", "var(--mint-600)"],
    sky: ["var(--secondary-soft)", "var(--sky-700)"],
    coral: ["hsl(0 90% 95%)", "var(--coral-600)"],
    amber: ["var(--accent-soft)", "var(--amber-700)"],
  };
  const wrap = document.getElementById("statTiles");
  wrap.innerHTML = tiles.map((t, i) => `
    <div class="card stat-tile g-3 hover-lift anim-fade-up" style="animation-delay:${i * 0.05}s">
      <div class="stat-tile-top">
        <div class="stat-tile-icon" style="background:${colorMap[t.color][0]};color:${colorMap[t.color][1]}">${ICON[t.icon]}</div>
        <span class="stat-tile-trend up">${ICON.arrowUp} ${Math.floor(Math.random() * 8) + 2}%</span>
      </div>
      <div class="stat-tile-value">${t.value}</div>
      <div class="stat-tile-label">${t.label}</div>
    </div>`).join("");
}

function renderMotivation() {
  const stats = MDG.taskStats();
  const msg = MDG_QUOTES.motivationMessage(stats);
  document.getElementById("motivationHeadline").textContent = msg.headline;
  document.getElementById("motivationBody").textContent = msg.body;
}

function renderInspiration() {
  const q = MDG_QUOTES.inspirationForNow(MDG.taskStats());
  document.getElementById("inspirationQuote").textContent = q.text;
  document.getElementById("inspirationAuthor").textContent = "— " + q.author;
}

function renderFocusList() {
  const today = new Date().toISOString().slice(0, 10);
  const focusTasks = MDG.tasks.filter(t => t.due === today).sort((a, b) => (a.status === "completed") - (b.status === "completed"));
  const wrap = document.getElementById("focusList");
  if (!focusTasks.length) {
    wrap.innerHTML = `<div class="empty-state" style="padding:var(--sp-8) var(--sp-4);">
      <img src="assets/illustrations/empty-tasks.svg" style="width:110px;margin-bottom:var(--sp-3);" alt="" />
      <h4 style="font-size:var(--fs-sm);">Nothing due today</h4>
      <p>Enjoy the clear runway, or line something up for tomorrow.</p>
    </div>`;
    return;
  }
  wrap.innerHTML = focusTasks.map(t => `
    <div class="focus-item" data-task-id="${t.id}">
      <span class="focus-check ${t.status === "completed" ? "is-done" : ""}">${t.status === "completed" ? ICON.check : ""}</span>
      <div style="flex:1;">
        <div class="focus-title ${t.status === "completed" ? "is-done" : ""}">${t.title}</div>
        <div class="focus-meta">
          <span class="priority-dot priority-${t.priority}"></span>
          <span>${MDG.categoryOf(t.category).label}</span>
          <span>· ${t.estimate}</span>
        </div>
      </div>
      <a class="icon-btn" style="width:32px;height:32px;" href="task-details.html?id=${t.id}">${ICON.chevronRight}</a>
    </div>`).join("");

  wrap.querySelectorAll(".focus-check").forEach(el => {
    el.addEventListener("click", () => {
      const id = el.closest(".focus-item").dataset.taskId;
      const task = MDG.tasks.find(t => t.id === id);
      task.status = task.status === "completed" ? "pending" : "completed";
      task.progress = task.status === "completed" ? 100 : 40;
      MDG.saveState();
      MDG_SHELL.toast(task.status === "completed" ? "Nice work — task completed!" : "Marked as pending", "success");
      renderFocusList();
      renderStats();
      renderMotivation();
    });
  });
}

function renderQuickAdd() {
  const input = document.getElementById("quickAddInput");
  const btn = document.getElementById("quickAddBtn");
  const add = () => {
    const val = input.value.trim();
    if (!val) return;
    MDG.tasks.unshift({
      id: "t" + Date.now(), title: val, description: "", category: "work", priority: "medium",
      status: "pending", due: new Date().toISOString().slice(0, 10), tags: [], estimate: "30m", progress: 0, favorite: false,
      createdAt: new Date().toISOString().slice(0, 10),
    });
    MDG.saveState();
    input.value = "";
    MDG_SHELL.toast("Task added to today's focus", "success");
    renderFocusList();
    renderStats();
  };
  btn.addEventListener("click", add);
  input.addEventListener("keydown", (e) => { if (e.key === "Enter") add(); });
}

function renderActivity() {
  const icons = { complete: ["check", "mint"], create: ["plus", "sky"], dream: ["dream", "indigo"], badge: ["medal", "amber"], overdue: ["flame", "coral"] };
  const colorMap = {
    mint: ["hsl(155 65% 92%)", "var(--mint-600)"], sky: ["var(--secondary-soft)", "var(--sky-700)"],
    indigo: ["var(--brand-soft)", "var(--brand-strong)"], amber: ["var(--accent-soft)", "var(--amber-700)"], coral: ["hsl(0 90% 95%)", "var(--coral-600)"],
  };
  document.getElementById("activityFeed").innerHTML = MDG.activity.map(a => {
    const [icon, color] = icons[a.type];
    return `<div class="activity-item">
      <div class="activity-icon" style="background:${colorMap[color][0]};color:${colorMap[color][1]}">${ICON[icon]}</div>
      <div><div class="activity-text">${a.text}</div><div class="activity-time">${a.time}</div></div>
    </div>`;
  }).join("");
}

function renderUpcoming() {
  const today = new Date().toISOString().slice(0, 10);
  const upcoming = MDG.tasks.filter(t => t.status !== "completed" && t.due > today).sort((a, b) => a.due.localeCompare(b.due)).slice(0, 5);
  const wrap = document.getElementById("upcomingList");
  if (!upcoming.length) {
    wrap.innerHTML = `<p style="font-size:var(--fs-xs);padding:var(--sp-4) 0;">No upcoming tasks scheduled — you're all caught up.</p>`;
    return;
  }
  const monthShort = ["JAN","FEB","MAR","APR","MAY","JUN","JUL","AUG","SEP","OCT","NOV","DEC"];
  wrap.innerHTML = upcoming.map(t => {
    const d = new Date(t.due + "T00:00:00");
    return `<div class="upcoming-item">
      <div class="upcoming-date-badge"><span class="d">${d.getDate()}</span><span class="m">${monthShort[d.getMonth()]}</span></div>
      <div style="flex:1;">
        <div class="focus-title">${t.title}</div>
        <div class="focus-meta"><span class="priority-dot priority-${t.priority}"></span>${MDG.categoryOf(t.category).label}</div>
      </div>
    </div>`;
  }).join("");
}

function renderCalendar() {
  const now = new Date();
  const year = now.getFullYear(), month = now.getMonth();
  const firstDay = new Date(year, month, 1).getDay();
  const daysInMonth = new Date(year, month + 1, 0).getDate();
  const prevDays = new Date(year, month, 0).getDate();
  const taskDays = new Set(MDG.tasks.map(t => t.due));
  document.getElementById("calLabel").textContent = now.toLocaleDateString([], { month: "long", year: "numeric" });

  let cells = "";
  for (let i = firstDay - 1; i >= 0; i--) cells += `<div class="mini-cal-day is-muted">${prevDays - i}</div>`;
  for (let d = 1; d <= daysInMonth; d++) {
    const dateStr = `${year}-${String(month + 1).padStart(2, "0")}-${String(d).padStart(2, "0")}`;
    const isToday = d === now.getDate();
    const hasTask = taskDays.has(dateStr);
    cells += `<div class="mini-cal-day ${isToday ? "is-today" : ""} ${hasTask ? "has-task" : ""}">${d}</div>`;
  }
  const remainder = (firstDay + daysInMonth) % 7;
  if (remainder) for (let i = 1; i <= 7 - remainder; i++) cells += `<div class="mini-cal-day is-muted">${i}</div>`;

  document.getElementById("calGrid").innerHTML = `
    <div class="dow">S</div><div class="dow">M</div><div class="dow">T</div><div class="dow">W</div><div class="dow">T</div><div class="dow">F</div><div class="dow">S</div>
    ${cells}`;
}

function renderProductivityScore() {
  const u = MDG.user;
  const ringTarget = document.getElementById("scoreRing");
  MDG_CHART.ring(ringTarget, u.productivityScore, {
    size: 130, stroke: 12, color: "var(--brand)",
    label: `<div class="score-ring-label">${u.productivityScore}<small>SCORE</small></div>`,
  });
  document.getElementById("streakCurrent").textContent = u.streakCurrent + " days";
  document.getElementById("streakLongest").textContent = u.streakLongest + " days";
  document.getElementById("completionRate").textContent = MDG.taskStats().completionRate + "%";
}

function renderBadges() {
  document.getElementById("badgeGrid").innerHTML = MDG.badges.slice(0, 6).map(b => `
    <div class="badge-tile ${b.earned ? "earned" : ""}" data-tooltip="${b.earned ? "Earned" : (b.progress || 0) + "% to go"}">
      <div class="badge-tile-icon">${ICON[b.icon]}</div>
      <span>${b.label}</span>
    </div>`).join("");
}

function renderDreamNudge() {
  const dream = MDG.dreams.slice().sort((a, b) => b.progress - a.progress)[0];
  if (!dream) return;
  document.getElementById("dreamNudge").innerHTML = `
    <span class="dream-nudge-emoji">${dream.emoji}</span>
    <div style="flex:1;">
      <div class="flex items-center justify-between" style="margin-bottom:6px;">
        <strong style="font-size:var(--fs-sm);">${dream.title}</strong>
        <span class="badge badge-indigo">${dream.progress}%</span>
      </div>
      <div class="progress-bar"><div class="progress-bar-fill" style="width:${dream.progress}%"></div></div>
    </div>
    <a href="dreams.html" class="btn btn-secondary btn-sm">View</a>`;
}
