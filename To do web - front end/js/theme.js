/* ==========================================================================
   Dynamic Day/Night theme engine
   Detects time of day, sets [data-theme] (day|night) and [data-period]
   (morning|afternoon|evening|night) on <html>, and exposes greeting content.
   Users can override with a manual toggle, persisted to localStorage.
   ========================================================================== */

const MDG_THEME = (() => {
  const THEME_KEY = "magadige_theme_override";

  const PERIODS = {
    morning:   { theme: "day",   label: "Morning",   greeting: "Good morning",   icon: "sunrise", mood: "Fresh start, clear mind." },
    afternoon: { theme: "day",   label: "Afternoon", greeting: "Good afternoon", icon: "sun",     mood: "Keep the momentum going." },
    evening:   { theme: "day",   label: "Evening",   greeting: "Good evening",   icon: "sunset",  mood: "Wind down, wrap up well." },
    night:     { theme: "night", label: "Night",     greeting: "Good night",    icon: "moon",    mood: "Rest fuels tomorrow's focus." },
  };

  function detectPeriod(date = new Date()) {
    const h = date.getHours();
    if (h >= 5 && h < 12) return "morning";
    if (h >= 12 && h < 17) return "afternoon";
    if (h >= 17 && h < 21) return "evening";
    return "night";
  }

  function getOverride() {
    return localStorage.getItem(THEME_KEY); // "day" | "night" | null (auto)
  }

  function setOverride(mode) {
    if (mode) localStorage.setItem(THEME_KEY, mode);
    else localStorage.removeItem(THEME_KEY);
    apply();
  }

  function currentPeriod() {
    const override = getOverride();
    if (override === "day") return "afternoon";
    if (override === "night") return "night";
    return detectPeriod();
  }

  function apply() {
    const period = currentPeriod();
    const meta = PERIODS[period];
    document.documentElement.setAttribute("data-theme", meta.theme);
    document.documentElement.setAttribute("data-period", period);
    document.dispatchEvent(new CustomEvent("mdg:theme-applied", { detail: { period, ...meta } }));
    updateToggleUI();
  }

  function updateToggleUI() {
    document.querySelectorAll("[data-theme-toggle]").forEach(group => {
      const override = getOverride();
      group.querySelectorAll("button").forEach(btn => {
        btn.classList.toggle("is-active", btn.dataset.themeSet === (override || "auto"));
      });
    });
  }

  function bindToggle(root = document) {
    root.querySelectorAll("[data-theme-toggle] button").forEach(btn => {
      btn.addEventListener("click", () => {
        const mode = btn.dataset.themeSet;
        setOverride(mode === "auto" ? null : mode);
      });
    });
  }

  function meta() { return PERIODS[currentPeriod()]; }

  // Apply immediately (before paint where possible) to avoid flash
  apply();

  document.addEventListener("DOMContentLoaded", () => {
    bindToggle();
    apply();
    // Re-check every few minutes in case of auto mode + long-open tab
    setInterval(() => { if (!getOverride()) apply(); }, 5 * 60 * 1000);
  });

  return { detectPeriod, currentPeriod, apply, setOverride, getOverride, meta, PERIODS, bindToggle };
})();
