/* ==========================================================================
   Context-aware motivation engine + curated quote library
   Built-in quotes ship with the app; admins can add more from admin.html —
   those are persisted to localStorage and merged into the same pool used
   by the dashboard's "Today's Inspiration" card.
   ========================================================================== */

const MDG_QUOTES = (() => {
  const CUSTOM_KEY = "magadige_custom_quotes_v1";
  const ALL_MOODS = ["morning", "afternoon", "evening", "night", "calm", "momentum", "struggle", "complete", "work", "learning", "dream", "overdue"];

  const library = [
    { text: "The best way to find yourself is to lose yourself in the service of others.", author: "Mahatma Gandhi", mood: ["morning", "calm"] },
    { text: "Any sufficiently advanced technology is indistinguishable from magic.", author: "Arthur C. Clarke", mood: ["work", "learning"] },
    { text: "Stay hungry, stay foolish.", author: "Steve Jobs", mood: ["momentum", "morning"] },
    { text: "It always seems impossible until it's done.", author: "Nelson Mandela", mood: ["overdue", "struggle"] },
    { text: "It does not matter how slowly you go as long as you do not stop.", author: "Confucius", mood: ["struggle", "night"] },
    { text: "Simplicity is the ultimate sophistication.", author: "Leonardo da Vinci", mood: ["work", "calm"] },
    { text: "Nothing in life is to be feared, it is only to be understood.", author: "Marie Curie", mood: ["learning", "calm"] },
    { text: "The way to get started is to quit talking and begin doing.", author: "Walt Disney", mood: ["momentum", "morning"] },
    { text: "You must be the change you wish to see in the world.", author: "Mahatma Gandhi", mood: ["evening", "calm"] },
    { text: "The future belongs to those who believe in the beauty of their dreams.", author: "Eleanor Roosevelt", mood: ["dream", "evening"] },
    { text: "Design is not just what it looks like and feels like. Design is how it works.", author: "Steve Jobs", mood: ["work"] },
    { text: "We are what we repeatedly do. Excellence, then, is not an act, but a habit.", author: "Aristotle", mood: ["complete", "momentum"] },
    { text: "Almost everything will work again if you unplug it for a few minutes, including you.", author: "Anne Lamott", mood: ["night", "calm"] },
  ];

  function loadCustom() {
    try {
      const raw = localStorage.getItem(CUSTOM_KEY);
      return raw ? JSON.parse(raw) : [];
    } catch (e) {
      return [];
    }
  }

  function saveCustom(list) {
    localStorage.setItem(CUSTOM_KEY, JSON.stringify(list));
  }

  let custom = loadCustom();

  function allQuotes() {
    return [...library, ...custom];
  }

  function timeOfDay(date = new Date()) {
    const h = date.getHours();
    if (h >= 5 && h < 12) return "morning";
    if (h >= 12 && h < 17) return "afternoon";
    if (h >= 17 && h < 21) return "evening";
    return "night";
  }

  function pickQuote(moodTag) {
    const pool = allQuotes().filter(q => q.mood.includes(moodTag));
    const list = pool.length ? pool : allQuotes();
    const dayIndex = new Date().getDate() + (moodTag ? moodTag.length : 0);
    return list[dayIndex % list.length];
  }

  /**
   * Builds an intelligent motivation message from real task-completion state,
   * not a random quote — matches copy to the actual situation.
   */
  function motivationMessage(stats) {
    const { completed, total, overdue, pending } = stats;
    if (total > 0 && completed === total) {
      return { headline: "Outstanding work today.", body: "Consistency builds success. Every task closed today compounds tomorrow.", tone: "celebrate" };
    }
    if (overdue > 0) {
      return { headline: `${overdue} important ${overdue === 1 ? "task is" : "tasks are"} waiting for you.`, body: "Let's finish it today — clearing overdue work frees up real mental space.", tone: "urgent" };
    }
    if (completed === 0 && pending > 0) {
      return { headline: "Start with one small task.", body: "Momentum begins with a single step. Pick the easiest one and go.", tone: "nudge" };
    }
    if (completed > 0 && completed < total) {
      const pct = Math.round((completed / total) * 100);
      return { headline: `You're ${pct}% through today.`, body: "Good pace — keep the momentum rolling into the next task.", tone: "progress" };
    }
    return { headline: "A fresh page, a fresh start.", body: "Set today's focus and let's build something worth remembering.", tone: "neutral" };
  }

  function inspirationForNow(stats) {
    const tod = timeOfDay();
    let moodTag = tod;
    if (stats) {
      if (stats.overdue > 0) moodTag = "struggle";
      else if (stats.completed === stats.total && stats.total > 0) moodTag = "complete";
      else if (stats.completed > 0) moodTag = "momentum";
    }
    return pickQuote(moodTag);
  }

  // ---- Admin-facing management API --------------------------------------
  function getBuiltIn() { return library.map((q, i) => ({ ...q, id: `builtin-${i}`, custom: false })); }
  function getCustom() { return custom.map((q, i) => ({ ...q, id: `custom-${i}`, custom: true })); }
  function getManaged() { return [...getCustom(), ...getBuiltIn()]; }

  function addQuote(text, author) {
    const entry = { text: text.trim(), author: author.trim() || "Unknown", mood: [...ALL_MOODS] };
    custom = [entry, ...custom];
    saveCustom(custom);
    return entry;
  }

  function deleteCustomQuote(index) {
    custom = custom.filter((_, i) => i !== index);
    saveCustom(custom);
  }

  return {
    timeOfDay, motivationMessage, inspirationForNow, pickQuote,
    getManaged, addQuote, deleteCustomQuote,
  };
})();
