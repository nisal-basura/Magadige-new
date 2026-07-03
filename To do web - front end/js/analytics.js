/* ==========================================================================
   Analytics page — deeper reporting on top of the same dummy dataset
   ========================================================================== */

document.addEventListener("DOMContentLoaded", () => {
  MDG_SHELL.mount("Analytics", "The story behind your last few weeks.");
  bindRangeTabs();
  renderStats();
  renderTrend("week");
  renderPriorityDonut();
  renderCategoryDonut();
  renderRhythm();
  renderHeatmap();
  renderInsights();
});

function bindRangeTabs() {
  document.querySelectorAll("#rangeTabs .tab").forEach(tab => {
    tab.addEventListener("click", () => {
      document.querySelectorAll("#rangeTabs .tab").forEach(t => t.classList.remove("is-active"));
      tab.classList.add("is-active");
      renderTrend(tab.dataset.range);
    });
  });
}

function renderStats() {
  const s = MDG.taskStats();
  const totalTasks = MDG.tasks.length;
  const avgPerDay = (MDG.weeklyProgress.reduce((sum, d) => sum + d.completed, 0) / 7).toFixed(1);
  const bestDay = MDG.weeklyProgress.slice().sort((a, b) => (b.completed / b.total) - (a.completed / a.total))[0];
  const focusHours = MDG.tasks.reduce((sum, t) => {
    const m = /([\d.]+)h/.exec(t.estimate);
    const mins = /([\d.]+)m/.exec(t.estimate);
    return sum + (m ? parseFloat(m[1]) : 0) + (mins ? parseFloat(mins[1]) / 60 : 0);
  }, 0);

  const tiles = [
    { label: "Completion Rate", value: s.completionRate + "%", icon: "check", color: ["hsl(155 65% 92%)", "var(--mint-600)"] },
    { label: "Avg Tasks / Day", value: avgPerDay, icon: "target", color: ["var(--brand-soft)", "var(--brand-strong)"] },
    { label: "Most Productive Day", value: bestDay.day, icon: "flame", color: ["var(--accent-soft)", "var(--amber-700)"] },
    { label: "Total Focus Time", value: focusHours.toFixed(1) + "h", icon: "clock", color: ["var(--secondary-soft)", "var(--sky-700)"] },
  ];
  document.getElementById("analyticsStats").innerHTML = tiles.map(t => `
    <div class="card stat-tile g-3 hover-lift">
      <div class="stat-tile-top"><div class="stat-tile-icon" style="background:${t.color[0]};color:${t.color[1]}">${ICON[t.icon]}</div></div>
      <div class="stat-tile-value">${t.value}</div>
      <div class="stat-tile-label">${t.label}</div>
    </div>`).join("");
}

function renderTrend(range) {
  const el = document.getElementById("trendChart");
  if (range === "week") {
    MDG_CHART.barChart(el, MDG.weeklyProgress, { height: 200 });
  } else {
    const values = range === "year" ? MDG.monthlyProgress : MDG.monthlyProgress.slice(-6);
    MDG_CHART.lineChart(el, values, { height: 200 });
  }
}

function renderPriorityDonut() {
  const active = MDG.tasks.filter(t => t.status !== "completed");
  const counts = { high: 0, medium: 0, low: 0 };
  active.forEach(t => counts[t.priority]++);
  const data = [
    { label: "High", value: counts.high, color: "var(--coral-500)" },
    { label: "Medium", value: counts.medium, color: "var(--amber-500)" },
    { label: "Low", value: counts.low, color: "var(--mint-500)" },
  ];
  MDG_CHART.donutChart(document.getElementById("priorityDonut"), data, { size: 130, thickness: 20 });
  document.getElementById("priorityLegend").innerHTML = data.map(d => `
    <div class="legend-row"><span class="legend-dot" style="background:${d.color}"></span>${d.label}<strong>${d.value}</strong></div>`).join("");
}

function renderCategoryDonut() {
  const counts = {};
  MDG.tasks.forEach(t => { counts[t.category] = (counts[t.category] || 0) + 1; });
  const colorVar = { indigo: "var(--brand)", sky: "var(--sky-500)", mint: "var(--mint-500)", amber: "var(--amber-500)", gray: "var(--gray-400)" };
  const data = MDG.CATEGORIES.filter(c => counts[c.id]).map(c => ({ label: c.label, value: counts[c.id], color: colorVar[c.color] }));
  MDG_CHART.donutChart(document.getElementById("categoryDonut"), data, { size: 130, thickness: 20 });
  document.getElementById("categoryLegend").innerHTML = data.map(d => `
    <div class="legend-row"><span class="legend-dot" style="background:${d.color}"></span>${d.label}<strong>${d.value}</strong></div>`).join("");
}

function renderRhythm() {
  MDG_CHART.barChart(document.getElementById("rhythmChart"), MDG.weeklyProgress, { height: 180 });
}

function renderHeatmap() {
  let seed = 42;
  let cells = "";
  for (let i = 0; i < 84; i++) {
    const v = (seed * (i + 3) * 9301 + 49297) % 233280 / 233280;
    const level = v > 0.82 ? 3 : v > 0.6 ? 2 : v > 0.35 ? 1 : 0;
    cells += `<div class="history-cell level-${level}"></div>`;
  }
  document.getElementById("analyticsHeatmap").innerHTML = cells;
}

function renderInsights() {
  const s = MDG.taskStats();
  const bestDay = MDG.weeklyProgress.slice().sort((a, b) => (b.completed / b.total) - (a.completed / a.total))[0];
  const worstDay = MDG.weeklyProgress.slice().sort((a, b) => (a.completed / a.total) - (b.completed / b.total))[0];
  const insights = [
    { icon: "flame", color: ["var(--accent-soft)", "var(--amber-700)"], text: `${bestDay.day} is your strongest day — you finish ${Math.round((bestDay.completed / bestDay.total) * 100)}% of what you plan.` },
    { icon: "clock", color: ["hsl(0 90% 95%)", "var(--coral-600)"], text: `${s.overdue} task${s.overdue === 1 ? " is" : "s are"} overdue right now. Clearing these first tends to unlock the rest of the week.` },
    { icon: "target", color: ["var(--brand-soft)", "var(--brand-strong)"], text: `${s.highPriority} high-priority tasks are still open — consider tackling those before anything else.` },
    { icon: "trophy", color: ["hsl(155 65% 92%)", "var(--mint-600)"], text: `Your current streak is ${MDG.user.streakCurrent} days, ${MDG.user.streakLongest - MDG.user.streakCurrent} short of your all-time best.` },
    { icon: "sunrise", color: ["var(--secondary-soft)", "var(--sky-700)"], text: `${worstDay.day} sees the lowest completion rate — try scheduling lighter, easier tasks that day.` },
  ];
  document.getElementById("insightsList").innerHTML = insights.map(i => `
    <div class="insight-row">
      <div class="insight-icon" style="background:${i.color[0]};color:${i.color[1]}">${ICON[i.icon]}</div>
      <p style="font-size:var(--fs-xs);margin:0;">${i.text}</p>
    </div>`).join("");
}
