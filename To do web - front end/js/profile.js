/* ==========================================================================
   Profile page logic
   ========================================================================== */

document.addEventListener("DOMContentLoaded", () => {
  MDG_SHELL.mount("Profile", "Your identity, stats, and achievements.");
  bindIcons();
  renderHeader();
  renderStatStrip();
  renderBadges();
  renderScore();
});

function bindIcons() {
  document.getElementById("editAvatarIcon").innerHTML = ICON.camera;
  document.getElementById("editIcon").innerHTML = ICON.edit;
  document.getElementById("bellIcon").innerHTML = ICON.bell;
  document.getElementById("flameIcon").innerHTML = ICON.flame;
  document.getElementById("lockIcon").innerHTML = ICON.lock;
  document.getElementById("shieldIcon").innerHTML = ICON.shield;
  document.getElementById("googleIcon").innerHTML = ICON.google;
  document.getElementById("githubIcon").innerHTML = ICON.github;
  document.getElementById("themeSunIcon").innerHTML = ICON.sun;
  document.getElementById("themeAutoIcon").innerHTML = ICON.auto;
  document.getElementById("themeMoonIcon").innerHTML = ICON.moon;
  document.getElementById("editProfileBtn").addEventListener("click", () => MDG_SHELL.toast("Profile editing is a UI demo only.", "info"));
  document.getElementById("editAvatarBtn").addEventListener("click", () => MDG_SHELL.toast("Photo upload is a UI demo only.", "info"));
}

function renderHeader() {
  const u = MDG.user;
  document.getElementById("profileAvatar").textContent = u.avatarInitials;
  document.getElementById("profileName").textContent = u.name;
  document.getElementById("profileRole").textContent = u.role;
  document.getElementById("profileEmail").textContent = u.email;
  document.getElementById("profileMemberSince").textContent = "Member since " + u.memberSince;
  document.getElementById("profileTimezone").textContent = u.timezone;
}

function renderStatStrip() {
  const s = MDG.taskStats();
  const tiles = [
    { label: "Tasks Completed", value: s.completed, icon: "check", color: ["hsl(155 65% 92%)", "var(--mint-600)"] },
    { label: "Current Streak", value: MDG.user.streakCurrent + "d", icon: "flame", color: ["hsl(0 90% 95%)", "var(--coral-600)"] },
    { label: "Longest Streak", value: MDG.user.streakLongest + "d", icon: "trophy", color: ["var(--accent-soft)", "var(--amber-700)"] },
    { label: "Dreams in Motion", value: MDG.dreams.length, icon: "dream", color: ["var(--brand-soft)", "var(--brand-strong)"] },
  ];
  document.getElementById("profileStatStrip").innerHTML = tiles.map(t => `
    <div class="card stat-tile hover-lift">
      <div class="stat-tile-top"><div class="stat-tile-icon" style="background:${t.color[0]};color:${t.color[1]}">${ICON[t.icon]}</div></div>
      <div class="stat-tile-value">${t.value}</div>
      <div class="stat-tile-label">${t.label}</div>
    </div>`).join("");
}

function renderBadges() {
  document.getElementById("profileBadgeGrid").innerHTML = MDG.badges.map(b => `
    <div class="badge-tile ${b.earned ? "earned" : ""}" data-tooltip="${b.earned ? "Earned" : (b.progress || 0) + "% to go"}">
      <div class="badge-tile-icon">${ICON[b.icon]}</div>
      <span>${b.label}</span>
    </div>`).join("");
}

function renderScore() {
  MDG_CHART.ring(document.getElementById("profileScoreRing"), MDG.user.productivityScore, {
    size: 140, stroke: 13, label: `<div class="score-ring-label">${MDG.user.productivityScore}<small>SCORE</small></div>`,
  });
}
