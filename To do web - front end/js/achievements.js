/* ==========================================================================
   Achievements page — trophy case + earned-badge timeline
   ========================================================================== */

document.addEventListener("DOMContentLoaded", () => {
  MDG_SHELL.mount("Achievements", "Every streak and milestone you've earned.");
  renderHero();
  renderGrid();
  renderTimeline();
});

function renderHero() {
  const earned = MDG.badges.filter(b => b.earned).length;
  document.getElementById("achEarnedCount").textContent = `${earned}/${MDG.badges.length}`;
  document.getElementById("achScore").textContent = MDG.user.productivityScore;
  document.getElementById("achStreak").textContent = MDG.user.streakCurrent + "d";
  document.getElementById("achLongest").textContent = MDG.user.streakLongest + "d";
}

function renderGrid() {
  document.getElementById("achGrid").innerHTML = MDG.badges.map(b => `
    <div class="card ach-card hover-lift ${b.earned ? "" : "is-locked"}">
      <div class="ach-card-icon">${ICON[b.icon]}</div>
      <h4>${b.label}</h4>
      <p>${b.desc}</p>
      ${b.earned
        ? `<span class="ach-card-date">Earned ${new Date(b.earnedDate).toLocaleDateString([], { month: "short", day: "numeric" })}</span>`
        : `<div class="ach-card-progress">
            <div class="progress-bar" style="margin-bottom:4px;"><div class="progress-bar-fill amber" style="width:${b.progress}%"></div></div>
            <span style="font-size:11px;color:var(--text-tertiary);">${b.progress}% to unlock</span>
           </div>`}
    </div>`).join("");
}

function renderTimeline() {
  const earned = MDG.badges.filter(b => b.earned).sort((a, b) => b.earnedDate.localeCompare(a.earnedDate));
  document.getElementById("achTimeline").innerHTML = earned.map(b => `
    <div class="timeline-item is-done">
      <span class="timeline-dot"></span>
      <div class="timeline-title">${b.label}</div>
      <div class="timeline-time">${new Date(b.earnedDate).toLocaleDateString([], { month: "long", day: "numeric", year: "numeric" })}</div>
    </div>`).join("") || `<p style="font-size:var(--fs-xs);">No badges earned yet — complete tasks to start unlocking them.</p>`;
}
