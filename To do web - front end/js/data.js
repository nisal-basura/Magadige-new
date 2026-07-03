/* ==========================================================================
   MAGADIGE TASK — Dummy data layer
   Everything here is fake/local data used to power the UI demo. In a real
   product this would come from an API; here it seeds localStorage so state
   feels persistent across the static pages.
   ========================================================================== */

const MDG = (() => {
  const STORAGE_KEY = "magadige_state_v1";

  const CATEGORIES = [
    { id: "work", label: "Work", color: "indigo", icon: "briefcase" },
    { id: "personal", label: "Personal", color: "sky", icon: "user" },
    { id: "health", label: "Health", color: "mint", icon: "heart" },
    { id: "learning", label: "Learning", color: "amber", icon: "book" },
    { id: "finance", label: "Finance", color: "gray", icon: "wallet" },
  ];

  const defaultUser = {
    name: "Amaka Nwosu",
    role: "Product Designer @ Northwind Labs",
    email: "nbcodezone@gmail.com",
    avatarInitials: "AN",
    memberSince: "March 2024",
    timezone: "GMT+1 · Lagos",
    streakCurrent: 12,
    streakLongest: 34,
    productivityScore: 87,
  };

  const defaultTasks = [
    { id: "t1", title: "Finalize onboarding flow wireframes", description: "Polish the 5-step onboarding wireframes and prep for the Friday design crit with the growth team.", category: "work", priority: "high", status: "in-progress", due: "2026-07-02", tags: ["design", "onboarding"], estimate: "3h", progress: 65, favorite: true, createdAt: "2026-06-28" },
    { id: "t2", title: "Morning run — 5km", description: "Easy pace, focus on breathing rhythm.", category: "health", priority: "medium", status: "pending", due: "2026-07-02", tags: ["fitness"], estimate: "40m", progress: 0, favorite: false, createdAt: "2026-06-30" },
    { id: "t3", title: "Review Q3 budget spreadsheet", description: "Cross-check marketing spend against approved budget lines before the finance sync.", category: "finance", priority: "high", status: "overdue", due: "2026-06-30", tags: ["budget", "review"], estimate: "1h", progress: 20, favorite: false, createdAt: "2026-06-25" },
    { id: "t4", title: "Read 'Deep Work' — Ch. 4", description: "Continue reading, take notes for the book club discussion.", category: "learning", priority: "low", status: "pending", due: "2026-07-03", tags: ["reading"], estimate: "45m", progress: 10, favorite: false, createdAt: "2026-06-29" },
    { id: "t5", title: "Prepare investor update email", description: "Summarize product milestones and MRR growth for the monthly investor newsletter.", category: "work", priority: "high", status: "pending", due: "2026-07-04", tags: ["startup", "writing"], estimate: "2h", progress: 0, favorite: true, createdAt: "2026-07-01" },
    { id: "t6", title: "Grocery run for the week", description: "Get produce, oats, and coffee beans.", category: "personal", priority: "low", status: "completed", due: "2026-07-01", tags: ["errands"], estimate: "30m", progress: 100, favorite: false, createdAt: "2026-06-27" },
    { id: "t7", title: "Design system: audit color tokens", description: "Ensure new brand tokens map cleanly across day/night themes.", category: "work", priority: "medium", status: "completed", due: "2026-06-29", tags: ["design-system"], estimate: "1.5h", progress: 100, favorite: false, createdAt: "2026-06-24" },
    { id: "t8", title: "Call mum", description: "Weekly catch-up call.", category: "personal", priority: "medium", status: "completed", due: "2026-06-30", tags: ["family"], estimate: "20m", progress: 100, favorite: true, createdAt: "2026-06-30" },
    { id: "t9", title: "Yoga & stretching session", description: "Focus on hips and shoulders.", category: "health", priority: "low", status: "pending", due: "2026-07-02", tags: ["fitness", "recovery"], estimate: "25m", progress: 0, favorite: false, createdAt: "2026-07-01" },
    { id: "t10", title: "Refactor auth service tests", description: "Increase coverage on token refresh edge cases.", category: "work", priority: "medium", status: "overdue", due: "2026-06-28", tags: ["engineering"], estimate: "2h", progress: 40, favorite: false, createdAt: "2026-06-22" },
    { id: "t11", title: "Plan Japan itinerary — Kyoto leg", description: "Map temples, ryokan stay, and food spots for the 4-day Kyoto stretch.", category: "personal", priority: "medium", status: "pending", due: "2026-07-06", tags: ["travel", "dream:japan"], estimate: "1h", progress: 15, favorite: true, createdAt: "2026-06-26" },
    { id: "t12", title: "Study system design — caching patterns", description: "Notes on write-through vs write-behind caches for the architect track.", category: "learning", priority: "high", status: "pending", due: "2026-07-05", tags: ["architecture", "dream:architect"], estimate: "1.5h", progress: 30, favorite: false, createdAt: "2026-06-27" },
  ];

  const defaultDreams = [
    {
      id: "d1", title: "Become a Software Architect", emoji: "🏛️",
      motivation: "Design systems that outlive trends — build the technical judgment to lead at scale.",
      target: "2027-12-31", progress: 42, color: "indigo",
      relatedTaskIds: ["t12"],
    },
    {
      id: "d2", title: "Build My Startup", emoji: "🚀",
      motivation: "Ship something people love and own my time. This is the long game.",
      target: "2028-06-30", progress: 27, color: "amber",
      relatedTaskIds: ["t5"],
    },
    {
      id: "d3", title: "Travel Japan", emoji: "🗾",
      motivation: "Cherry blossoms in Kyoto, ramen in Osaka, quiet mornings at a ryokan.",
      target: "2026-11-15", progress: 58, color: "sky",
      relatedTaskIds: ["t11"],
    },
    {
      id: "d4", title: "Buy a House", emoji: "🏡",
      motivation: "A calm, permanent space to build a life — and a studio corner for side projects.",
      target: "2029-03-01", progress: 15, color: "mint",
      relatedTaskIds: [],
    },
  ];

  const weeklyProgress = [
    { day: "Mon", completed: 5, total: 7 },
    { day: "Tue", completed: 6, total: 6 },
    { day: "Wed", completed: 3, total: 8 },
    { day: "Thu", completed: 7, total: 7 },
    { day: "Fri", completed: 4, total: 9 },
    { day: "Sat", completed: 2, total: 4 },
    { day: "Sun", completed: 1, total: 3 },
  ];

  const monthlyProgress = [62, 71, 55, 80, 74, 68, 85, 90, 77, 82, 95, 88];
  const monthLabels = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];

  const activity = [
    { id: "a1", type: "complete", text: "Completed “Call mum”", time: "2h ago" },
    { id: "a2", type: "create", text: "Added new task “Prepare investor update email”", time: "5h ago" },
    { id: "a3", type: "dream", text: "Progressed “Travel Japan” dream +4%", time: "1d ago" },
    { id: "a4", type: "complete", text: "Completed “Design system: audit color tokens”", time: "1d ago" },
    { id: "a5", type: "badge", text: "Earned badge “Consistency Champion”", time: "2d ago" },
    { id: "a6", type: "overdue", text: "“Review Q3 budget spreadsheet” became overdue", time: "2d ago" },
  ];

  const defaultBadges = [
    { id: "b1", label: "7-Day Streak", icon: "flame", earned: true, earnedDate: "2026-06-20", desc: "Complete at least one task every day for 7 days straight." },
    { id: "b2", label: "Early Bird", icon: "sunrise", earned: true, earnedDate: "2026-06-15", desc: "Complete a task before 8 AM." },
    { id: "b3", label: "Consistency Champion", icon: "medal", earned: true, earnedDate: "2026-06-30", desc: "Maintain a 30-day completion rate above 70%." },
    { id: "b4", label: "100 Tasks Done", icon: "trophy", earned: false, progress: 78, desc: "Complete 100 tasks total." },
    { id: "b5", label: "Dream Achiever", icon: "star", earned: false, progress: 30, desc: "Reach 100% progress on any dream." },
    { id: "b6", label: "Night Owl", icon: "moon", earned: true, earnedDate: "2026-06-25", desc: "Complete a task after 10 PM." },
    { id: "b7", label: "Focus Master", icon: "target", earned: false, progress: 55, desc: "Complete 20 high-priority tasks." },
    { id: "b8", label: "Planner", icon: "calendar", earned: true, earnedDate: "2026-06-10", desc: "Schedule tasks for every day in a week." },
  ];

  const defaultNotifications = [
    { id: "n1", title: "Task due in 1 hour", body: "“Morning run — 5km” is due soon.", time: "10m ago", unread: true, type: "reminder" },
    { id: "n2", title: "Streak milestone!", body: "You've hit a 12-day streak. Keep it going.", time: "3h ago", unread: true, type: "achievement" },
    { id: "n3", title: "Dream progress updated", body: "“Travel Japan” moved to 58% complete.", time: "1d ago", unread: false, type: "dream" },
    { id: "n4", title: "Weekly summary ready", body: "You completed 28 of 44 tasks this week.", time: "2d ago", unread: false, type: "summary" },
    { id: "n5", title: "New comment on a task", body: "Tunde Bakare commented on “Finalize onboarding flow wireframes”.", time: "2d ago", unread: true, type: "comment" },
    { id: "n6", title: "Task overdue", body: "“Review Q3 budget spreadsheet” is now overdue.", time: "2d ago", unread: false, type: "reminder" },
    { id: "n7", title: "Badge earned: Consistency Champion", body: "Your 30-day completion rate crossed 70%.", time: "3d ago", unread: false, type: "achievement" },
    { id: "n8", title: "System update", body: "Magadige Task now supports Dream Board reminders.", time: "5d ago", unread: false, type: "system" },
  ];

  function load() {
    try {
      const raw = localStorage.getItem(STORAGE_KEY);
      if (raw) {
        const parsed = JSON.parse(raw);
        if (!parsed.notifications) parsed.notifications = defaultNotifications;
        if (!parsed.badges) parsed.badges = defaultBadges;
        return parsed;
      }
    } catch (e) { /* ignore corrupt storage */ }
    const seed = { user: defaultUser, tasks: defaultTasks, dreams: defaultDreams, notifications: defaultNotifications, badges: defaultBadges };
    localStorage.setItem(STORAGE_KEY, JSON.stringify(seed));
    return seed;
  }

  function save(state) {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(state));
  }

  const state = load();

  return {
    CATEGORIES, weeklyProgress, monthlyProgress, monthLabels,
    activity,
    get user() { return state.user; },
    get tasks() { return state.tasks; },
    get dreams() { return state.dreams; },
    get badges() { return state.badges; },
    get notifications() { return state.notifications; },
    saveState() { save(state); },
    resetState() {
      localStorage.removeItem(STORAGE_KEY);
      location.reload();
    },
    categoryOf(id) { return CATEGORIES.find(c => c.id === id) || CATEGORIES[0]; },
    taskStats() {
      const tasks = state.tasks;
      const completed = tasks.filter(t => t.status === "completed").length;
      const pending = tasks.filter(t => t.status === "pending" || t.status === "in-progress").length;
      const overdue = tasks.filter(t => t.status === "overdue").length;
      const highPriority = tasks.filter(t => t.priority === "high" && t.status !== "completed").length;
      const total = tasks.length;
      const completionRate = total ? Math.round((completed / total) * 100) : 0;
      return { completed, pending, overdue, highPriority, total, completionRate };
    },
  };
})();
