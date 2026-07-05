/* ==========================================================================
   Admin dashboard logic — stats, charts, quotes CRUD, seasonal effects.
   ========================================================================== */

document.addEventListener("DOMContentLoaded", () => {
  bindStaticIcons();
  bindTabs();
  renderOverview();
  renderQuotes();
  bindQuoteForm();
  bindSeasonalCards();
});

function bindStaticIcons() {
  document.getElementById("shieldIcon").innerHTML = ICON.shield;
  document.getElementById("sunIcon").innerHTML = ICON.sun;
  document.getElementById("autoIcon").innerHTML = ICON.auto;
  document.getElementById("moonIcon").innerHTML = ICON.moon;
  document.getElementById("backIcon").innerHTML = ICON.arrowRight;
  document.getElementById("tabOverviewIcon").innerHTML = ICON.analytics;
  document.getElementById("tabQuotesIcon").innerHTML = ICON.bulb;
  document.getElementById("tabSeasonalIcon").innerHTML = ICON.sparkles;
  document.getElementById("addQuoteIcon").innerHTML = ICON.plus;
}

function bindTabs() {
  document.querySelectorAll("#adminTabs .tab").forEach(tab => {
    tab.addEventListener("click", () => {
      document.querySelectorAll("#adminTabs .tab").forEach(t => t.classList.remove("is-active"));
      document.querySelectorAll(".admin-panel").forEach(p => p.classList.remove("is-active"));
      tab.classList.add("is-active");
      document.getElementById("panel-" + tab.dataset.panel).classList.add("is-active");
    });
  });
}

function renderOverview() {
  const stats = MDG_ADMIN.stats();
  const tiles = [
    { label: "Total Registered Users", value: stats.totalUsers, icon: "user", color: ["var(--brand-soft)", "var(--brand-strong)"] },
    { label: "New Today", value: stats.newToday, icon: "sunrise", color: ["var(--accent-soft)", "var(--amber-700)"] },
    { label: "New This Week", value: stats.newThisWeek, icon: "calendar", color: ["var(--secondary-soft)", "var(--sky-700)"] },
    { label: "New This Month", value: stats.newThisMonth, icon: "flame", color: ["hsl(155 65% 92%)", "var(--mint-600)"] },
  ];
  document.getElementById("statTilesRow").innerHTML = tiles.map(t => `
    <div class="card admin-stat-tile a-g-3 hover-lift">
      <div class="admin-stat-icon" style="background:${t.color[0]};color:${t.color[1]}">${ICON[t.icon]}</div>
      <div class="admin-stat-value">${t.value.toLocaleString()}</div>
      <div class="admin-stat-label">${t.label}</div>
    </div>`).join("");

  MDG_CHART.lineChart(document.getElementById("growthChart"), MDG_ADMIN.monthlyGrowth(12), { height: 200 });

  const weekly = MDG_ADMIN.weeklySignups();
  MDG_CHART.barChart(
    document.getElementById("weeklyChart"),
    weekly.labels.map((label, i) => ({ label, value: weekly.counts[i] })),
    { height: 180 }
  );

  const plans = MDG_ADMIN.planBreakdown();
  const planColors = { Free: "var(--gray-400)", Pro: "var(--brand)", Team: "var(--amber-500)" };
  const planData = Object.entries(plans).map(([label, value]) => ({ label, value, color: planColors[label] }));
  MDG_CHART.donutChart(document.getElementById("planDonut"), planData, { size: 120, thickness: 18 });
  document.getElementById("planLegend").innerHTML = planData.map(d => `
    <div class="flex items-center gap-2" style="margin-bottom:8px;">
      <span style="width:10px;height:10px;border-radius:3px;background:${d.color};display:inline-block;"></span>
      <span style="font-size:var(--fs-xs);flex:1;">${d.label}</span>
      <strong style="font-size:var(--fs-xs);">${d.value}</strong>
    </div>`).join("");

  document.getElementById("recentUsersBody").innerHTML = MDG_ADMIN.recentUsers(8).map(u => `
    <tr>
      <td>
        <div class="admin-user-cell">
          <span class="avatar-text" style="width:30px;height:30px;font-size:10px;">${u.name.split(" ").map(n => n[0]).join("")}</span>
          <div>
            <div style="font-weight:700;">${u.name}</div>
            <div style="color:var(--text-tertiary);font-size:var(--fs-2xs);">${u.email}</div>
          </div>
        </div>
      </td>
      <td><span class="badge badge-gray">${u.plan}</span></td>
      <td>${new Date(u.joinedAt).toLocaleDateString([], { month: "short", day: "numeric", year: "numeric" })}</td>
    </tr>`).join("");
}

function renderQuotes() {
  const quotes = MDG_QUOTES.getManaged();
  document.getElementById("quoteCount").textContent = `${quotes.length} quotes total`;
  document.getElementById("quoteList").innerHTML = quotes.map(q => `
    <div class="quote-item">
      <span class="quote-item-mark">"</span>
      <div class="quote-item-body">
        <div class="quote-item-text">${q.text}</div>
        <div class="quote-item-author">— ${q.author} ${q.custom ? "" : "· Built-in"}</div>
      </div>
      ${q.custom ? `<div class="quote-item-actions"><button class="icon-btn" style="width:32px;height:32px;" data-delete-quote="${q.id.replace("custom-", "")}">${ICON.trash}</button></div>` : ""}
    </div>`).join("");

  document.querySelectorAll("[data-delete-quote]").forEach(btn => {
    btn.addEventListener("click", () => {
      MDG_QUOTES.deleteCustomQuote(parseInt(btn.dataset.deleteQuote, 10));
      renderQuotes();
    });
  });
}

function bindQuoteForm() {
  document.getElementById("quoteForm").addEventListener("submit", (e) => {
    e.preventDefault();
    const text = document.getElementById("quoteText").value.trim();
    const author = document.getElementById("quoteAuthor").value.trim();
    if (!text) return;
    MDG_QUOTES.addQuote(text, author);
    e.target.reset();
    renderQuotes();
  });
}

function bindSeasonalCards() {
  const cards = document.querySelectorAll(".seasonal-card");
  function syncActive() {
    const current = MDG_SEASONAL.getTheme();
    cards.forEach(c => {
      const active = c.dataset.themeChoice === current;
      c.classList.toggle("is-active", active);
      const existingPill = c.querySelector(".seasonal-active-pill");
      if (active && !existingPill) {
        c.insertAdjacentHTML("beforeend", `<span class="seasonal-active-pill">${ICON.check} Live now</span>`);
      } else if (!active && existingPill) {
        existingPill.remove();
      }
    });
  }
  cards.forEach(card => {
    card.addEventListener("click", () => {
      MDG_SEASONAL.setTheme(card.dataset.themeChoice);
      syncActive();
    });
  });
  syncActive();
}
