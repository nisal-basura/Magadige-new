/* ==========================================================================
   Settings page logic
   ========================================================================== */

document.addEventListener("DOMContentLoaded", () => {
  MDG_SHELL.mount("Settings", "Tune Magadige Task to fit how you work.");
  bindNavIcons();
  bindScrollSpy();
  bindThemeCards();
  bindDataActions();
  document.getElementById("googleIcon").innerHTML = ICON.google;
  document.getElementById("githubIcon").innerHTML = ICON.github;
  document.getElementById("downloadIcon").innerHTML = ICON.download;
});

function bindNavIcons() {
  document.getElementById("navIconAppearance").innerHTML = ICON.sun;
  document.getElementById("navIconNotif").innerHTML = ICON.bell;
  document.getElementById("navIconLang").innerHTML = ICON.globe;
  document.getElementById("navIconPrivacy").innerHTML = ICON.shield;
  document.getElementById("navIconSecurity").innerHTML = ICON.lock;
  document.getElementById("navIconAccounts").innerHTML = ICON.user;
  document.getElementById("navIconData").innerHTML = ICON.download;
}

function bindScrollSpy() {
  const links = document.querySelectorAll("#settingsNav a");
  const sections = Array.from(links).map(a => document.querySelector(a.getAttribute("href")));
  const io = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        const id = "#" + entry.target.id;
        links.forEach(l => l.classList.toggle("is-active", l.getAttribute("href") === id));
      }
    });
  }, { rootMargin: "-30% 0px -60% 0px" });
  sections.forEach(sec => sec && io.observe(sec));
}

function bindThemeCards() {
  const cards = document.querySelectorAll(".theme-preview-card");
  function syncActive() {
    const current = MDG_THEME.getOverride() || "auto";
    cards.forEach(c => c.classList.toggle("is-active", c.dataset.themeSet === current));
  }
  cards.forEach(card => {
    card.addEventListener("click", () => {
      MDG_THEME.setOverride(card.dataset.themeSet === "auto" ? null : card.dataset.themeSet);
      syncActive();
      MDG_SHELL.toast("Appearance updated", "success");
    });
  });
  syncActive();
}

function bindDataActions() {
  document.getElementById("exportBtn").addEventListener("click", () => {
    const data = { user: MDG.user, tasks: MDG.tasks, dreams: MDG.dreams };
    const blob = new Blob([JSON.stringify(data, null, 2)], { type: "application/json" });
    const url = URL.createObjectURL(blob);
    const a = document.createElement("a");
    a.href = url;
    a.download = "magadige-task-export.json";
    a.click();
    URL.revokeObjectURL(url);
    MDG_SHELL.toast("Export downloaded", "success");
  });

  document.getElementById("deleteAccountBtn").addEventListener("click", () => {
    if (confirm("This will permanently delete your account and all local data. Continue?")) {
      MDG.resetState();
    }
  });
}
