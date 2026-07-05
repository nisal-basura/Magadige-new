/* ==========================================================================
   Admin dashboard data layer — dummy "platform" data (registered users,
   growth) seeded once into localStorage, mirroring the same demo-data
   pattern used by data.js for the end-user app. A real backend would
   replace this with an API layer without changing admin.html's rendering.
   ========================================================================== */

const MDG_ADMIN = (() => {
  const STORAGE_KEY = "magadige_admin_users_v1";

  const FIRST_NAMES = ["Amaka", "Tunde", "Chidi", "Ifeoma", "Bola", "Emeka", "Ngozi", "Kunle", "Aisha", "Femi", "Zainab", "Chinedu", "Yemi", "Adaeze", "Segun", "Blessing", "Uche", "Funke", "Ibrahim", "Chioma", "Dayo", "Halima", "Obinna", "Temi"];
  const LAST_NAMES = ["Nwosu", "Bakare", "Okafor", "Adeyemi", "Balogun", "Eze", "Abubakar", "Okoro", "Afolabi", "Nnamdi", "Yusuf", "Chukwu", "Ogunleye", "Musa", "Adeleke"];
  const PLANS = ["Free", "Free", "Free", "Pro", "Pro", "Team"];

  function randomDateWithinLastDays(days) {
    const now = new Date();
    return new Date(now.getTime() - Math.random() * days * 24 * 60 * 60 * 1000);
  }

  function seedUsers() {
    const users = [];
    let id = 1;
    // Build a growth curve: fewer signups further back, ramping up recently.
    const monthWeights = [2, 3, 3, 4, 5, 6, 7, 8, 10, 12, 15, 18];
    monthWeights.forEach((weight, monthsAgoFromOldest) => {
      const monthsAgo = monthWeights.length - 1 - monthsAgoFromOldest;
      for (let i = 0; i < weight; i++) {
        const first = FIRST_NAMES[Math.floor(Math.random() * FIRST_NAMES.length)];
        const last = LAST_NAMES[Math.floor(Math.random() * LAST_NAMES.length)];
        const now = new Date();
        const base = new Date(now.getFullYear(), now.getMonth() - monthsAgo, 1);
        // For the current (partial) month, pick a moment between the 1st and
        // right now — picking a day and hour independently can still land a
        // valid day (today) with an hour later than the current one, which
        // is a subtler way to produce a "future" registration.
        let joined;
        if (monthsAgo === 0) {
          joined = new Date(base.getTime() + Math.random() * (now.getTime() - base.getTime()));
        } else {
          const daysInMonth = new Date(base.getFullYear(), base.getMonth() + 1, 0).getDate();
          joined = new Date(base.getFullYear(), base.getMonth(), 1 + Math.floor(Math.random() * daysInMonth), Math.floor(Math.random() * 24));
        }
        users.push({
          id: `u${id++}`,
          name: `${first} ${last}`,
          email: `${first.toLowerCase()}.${last.toLowerCase()}${Math.floor(Math.random() * 90) + 10}@example.com`,
          plan: PLANS[Math.floor(Math.random() * PLANS.length)],
          joinedAt: joined.toISOString(),
          active: Math.random() > 0.18,
        });
      }
    });
    // A handful of very recent signups (this week) for a lively "recent" table.
    for (let i = 0; i < 6; i++) {
      const first = FIRST_NAMES[Math.floor(Math.random() * FIRST_NAMES.length)];
      const last = LAST_NAMES[Math.floor(Math.random() * LAST_NAMES.length)];
      users.push({
        id: `u${id++}`,
        name: `${first} ${last}`,
        email: `${first.toLowerCase()}.${last.toLowerCase()}${Math.floor(Math.random() * 90) + 10}@example.com`,
        plan: PLANS[Math.floor(Math.random() * PLANS.length)],
        joinedAt: randomDateWithinLastDays(6).toISOString(),
        active: true,
      });
    }
    return users.sort((a, b) => new Date(b.joinedAt) - new Date(a.joinedAt));
  }

  function load() {
    try {
      const raw = localStorage.getItem(STORAGE_KEY);
      if (raw) return JSON.parse(raw);
    } catch (e) { /* ignore corrupt storage */ }
    const seed = seedUsers();
    localStorage.setItem(STORAGE_KEY, JSON.stringify(seed));
    return seed;
  }

  const users = load();

  function monthLabels(count) {
    const labels = [];
    const now = new Date();
    for (let i = count - 1; i >= 0; i--) {
      const d = new Date(now.getFullYear(), now.getMonth() - i, 1);
      labels.push(d.toLocaleDateString([], { month: "short" }));
    }
    return labels;
  }

  function monthlyGrowth(count = 12) {
    const now = new Date();
    const buckets = new Array(count).fill(0);
    users.forEach(u => {
      const joined = new Date(u.joinedAt);
      const monthsAgo = (now.getFullYear() - joined.getFullYear()) * 12 + (now.getMonth() - joined.getMonth());
      const idx = count - 1 - monthsAgo;
      if (idx >= 0 && idx < count) buckets[idx]++;
    });
    // Convert to cumulative totals for a "growth" line, not just per-month counts.
    let running = users.length - buckets.reduce((a, b) => a + b, 0);
    return buckets.map(n => (running += n));
  }

  function weeklySignups() {
    const now = new Date();
    const labels = [];
    const counts = [];
    for (let i = 6; i >= 0; i--) {
      const day = new Date(now.getFullYear(), now.getMonth(), now.getDate() - i);
      labels.push(day.toLocaleDateString([], { weekday: "short" }));
      const count = users.filter(u => {
        const joined = new Date(u.joinedAt);
        return joined.toDateString() === day.toDateString();
      }).length;
      counts.push(count);
    }
    return { labels, counts };
  }

  function stats() {
    const now = new Date();
    const startOfDay = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    const startOfWeek = new Date(startOfDay); startOfWeek.setDate(startOfWeek.getDate() - 6);
    // Rolling 30-day window rather than "since the 1st of this calendar
    // month" — the latter can dip below the weekly figure right after a
    // month boundary (e.g. 2 days into a new month), which reads as a bug
    // even though it's technically correct. A rolling window always fully
    // contains the weekly window, so "month" >= "week" always holds.
    const startOfMonth = new Date(startOfDay); startOfMonth.setDate(startOfMonth.getDate() - 29);
    const newToday = users.filter(u => new Date(u.joinedAt) >= startOfDay).length;
    const newThisWeek = users.filter(u => new Date(u.joinedAt) >= startOfWeek).length;
    const newThisMonth = users.filter(u => new Date(u.joinedAt) >= startOfMonth).length;
    const activeUsers = users.filter(u => u.active).length;
    return { totalUsers: users.length, newToday, newThisWeek, newThisMonth, activeUsers };
  }

  function planBreakdown() {
    const counts = { Free: 0, Pro: 0, Team: 0 };
    users.forEach(u => { counts[u.plan] = (counts[u.plan] || 0) + 1; });
    return counts;
  }

  function recentUsers(limit = 8) {
    return users.slice(0, limit);
  }

  return { stats, monthlyGrowth, monthLabels, weeklySignups, planBreakdown, recentUsers, allUsers: () => users };
})();
