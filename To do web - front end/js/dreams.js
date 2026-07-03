/* ==========================================================================
   Dream Board — the goals-to-tasks connective feature
   ========================================================================== */

document.addEventListener("DOMContentLoaded", () => {
  MDG_SHELL.mount("Dream Board", "Life goals, tracked like tasks — because they matter just as much.");
  document.getElementById("plusIconTop").innerHTML = ICON.plus;
  document.getElementById("closeDreamIcon").innerHTML = ICON.close;
  bindCreateDream();
  bindDreamDetailClose();
  render();
});

const COLOR_MAP = {
  indigo: "var(--brand)", amber: "var(--amber-500)", sky: "var(--sky-500)", mint: "var(--mint-500)",
};

function render() {
  const dreams = MDG.dreams;
  document.getElementById("dreamCount").textContent = `${dreams.length} goal${dreams.length === 1 ? "" : "s"} in motion`;
  document.getElementById("dreamEmptyState").hidden = dreams.length > 0;
  document.getElementById("dreamGrid").hidden = dreams.length === 0;

  const cards = dreams.map((d, i) => {
    const daysLeft = Math.max(0, Math.ceil((new Date(d.target) - new Date()) / (1000 * 60 * 60 * 24)));
    const relatedTasks = d.relatedTaskIds.map(id => MDG.tasks.find(t => t.id === id)).filter(Boolean);
    return `
    <div class="card dream-card hover-lift anim-fade-up" style="animation-delay:${i * 0.05}s" data-id="${d.id}">
      <div class="dream-card-top">
        <div class="dream-emoji-badge">${d.emoji}</div>
        <button class="icon-btn dream-card-menu" style="width:30px;height:30px;border:none;background:transparent;" data-tooltip="Options">${ICON.more}</button>
      </div>
      <div>
        <h3>${d.title}</h3>
        <p class="dream-card-motivation">"${d.motivation}"</p>
      </div>
      <div>
        <div class="dream-progress-row"><span>Progress</span><strong>${d.progress}%</strong></div>
        <div class="progress-bar"><div class="progress-bar-fill" style="width:${d.progress}%;background:linear-gradient(90deg, ${COLOR_MAP[d.color]}, var(--secondary));"></div></div>
      </div>
      ${relatedTasks.length ? `<div class="dream-related-tasks">${relatedTasks.slice(0, 2).map(t => `<div class="dream-related-task"><span class="priority-dot priority-${t.priority}"></span>${t.title}</div>`).join("")}</div>` : ""}
      <div class="dream-card-footer">
        <span>${daysLeft > 0 ? `<strong>${daysLeft}</strong> days left` : "Target date passed"}</span>
        <span>Target: <strong>${new Date(d.target).toLocaleDateString([], { month: "short", year: "numeric" })}</strong></span>
      </div>
    </div>`;
  }).join("");

  const addCard = `
    <div class="dream-add-card" id="addDreamCardInline">
      <div class="dream-add-card-icon">${ICON.plus}</div>
      <strong style="font-size:var(--fs-sm);">Add a new dream</strong>
      <span style="font-size:var(--fs-2xs);">Define a goal worth working toward</span>
    </div>`;

  document.getElementById("dreamGrid").innerHTML = cards + addCard;

  document.getElementById("dreamGrid").querySelectorAll(".dream-card").forEach(card => {
    card.addEventListener("click", (e) => {
      if (e.target.closest(".dream-card-menu")) return;
      openDreamDetail(card.dataset.id);
    });
  });
  document.getElementById("addDreamCardInline").addEventListener("click", openCreateDream);
  document.getElementById("addDreamBtnTop").addEventListener("click", openCreateDream);
  document.getElementById("addDreamBtnEmpty")?.addEventListener("click", openCreateDream);
}

function openDreamDetail(id) {
  const d = MDG.dreams.find(x => x.id === id);
  const relatedTasks = d.relatedTaskIds.map(tid => MDG.tasks.find(t => t.id === tid)).filter(Boolean);
  const daysLeft = Math.max(0, Math.ceil((new Date(d.target) - new Date()) / (1000 * 60 * 60 * 24)));

  document.getElementById("dreamModal").innerHTML = `
    <div class="flex items-start justify-between" style="margin-bottom:var(--sp-5);">
      <div class="flex items-center gap-3">
        <div class="dream-emoji-badge" style="font-size:2rem;width:64px;height:64px;">${d.emoji}</div>
        <div>
          <h3 style="margin-bottom:4px;">${d.title}</h3>
          <span style="font-size:var(--fs-xs);color:var(--text-tertiary);">Target: ${new Date(d.target).toLocaleDateString([], { month: "long", day: "numeric", year: "numeric" })} · ${daysLeft} days left</span>
        </div>
      </div>
      <button class="icon-btn" id="closeDreamDetailBtn" style="width:34px;height:34px;">${ICON.close}</button>
    </div>

    <p style="font-style:italic;font-size:var(--fs-sm);color:var(--text-secondary);margin-bottom:var(--sp-5);">"${d.motivation}"</p>

    <div class="drawer-section-label">Progress</div>
    <div class="flex items-center gap-3" style="margin-bottom:var(--sp-5);">
      <div class="progress-bar" style="flex:1;"><div class="progress-bar-fill" style="width:${d.progress}%"></div></div>
      <strong>${d.progress}%</strong>
    </div>

    <div class="drawer-section-label">Related Tasks</div>
    <div style="margin-bottom:var(--sp-5);">
      ${relatedTasks.length ? relatedTasks.map(t => `
        <div class="focus-item" style="padding-left:0;padding-right:0;">
          <span class="priority-dot priority-${t.priority}"></span>
          <div style="flex:1;"><div class="focus-title ${t.status === "completed" ? "is-done" : ""}">${t.title}</div></div>
          <span class="badge badge-gray">${t.status}</span>
        </div>`).join("") : `<p style="font-size:var(--fs-xs);">No tasks linked yet. Tag a task with this dream from Task creation to connect it here.</p>`}
    </div>

    <div class="flex items-center gap-3">
      <button class="btn btn-secondary" id="bumpProgressBtn">+10% Progress</button>
      <button class="btn btn-danger" id="deleteDreamBtn">${ICON.trash} Delete</button>
    </div>`;

  document.getElementById("dreamModal").hidden = false;
  document.getElementById("dreamOverlay").hidden = false;
  document.getElementById("closeDreamDetailBtn").addEventListener("click", closeDreamDetail);
  document.getElementById("bumpProgressBtn").addEventListener("click", () => {
    d.progress = Math.min(100, d.progress + 10);
    MDG.saveState();
    MDG_SHELL.toast(`"${d.title}" is now ${d.progress}% complete`, "success");
    closeDreamDetail();
    render();
  });
  document.getElementById("deleteDreamBtn").addEventListener("click", () => {
    MDG.dreams.splice(MDG.dreams.indexOf(d), 1);
    MDG.saveState();
    MDG_SHELL.toast("Dream removed", "warn");
    closeDreamDetail();
    render();
  });
}
function closeDreamDetail() {
  document.getElementById("dreamModal").hidden = true;
  document.getElementById("dreamOverlay").hidden = true;
}
function bindDreamDetailClose() {
  document.getElementById("dreamOverlay").addEventListener("click", closeDreamDetail);
}

function bindCreateDream() {
  document.getElementById("closeCreateDreamBtn").addEventListener("click", closeCreateDream);
  document.getElementById("cancelDreamBtn").addEventListener("click", closeCreateDream);
  document.getElementById("createDreamOverlay").addEventListener("click", closeCreateDream);
  document.querySelectorAll("#emojiSwatches .chip").forEach(chip => {
    chip.addEventListener("click", () => {
      document.querySelectorAll("#emojiSwatches .chip").forEach(c => c.classList.remove("is-active"));
      chip.classList.add("is-active");
    });
  });
  document.getElementById("dreamForm").addEventListener("submit", (e) => {
    e.preventDefault();
    const title = document.getElementById("dTitle").value.trim();
    if (!title) return;
    const emoji = document.querySelector("#emojiSwatches .chip.is-active")?.dataset.emoji || "✦";
    MDG.dreams.push({
      id: "d" + Date.now(), title, emoji,
      motivation: document.getElementById("dMotivation").value.trim() || "A goal worth working toward.",
      target: document.getElementById("dTarget").value || new Date().toISOString().slice(0, 10),
      progress: 0, color: ["indigo", "amber", "sky", "mint"][MDG.dreams.length % 4], relatedTaskIds: [],
    });
    MDG.saveState();
    MDG_SHELL.toast("New dream added to your board", "success");
    closeCreateDream();
    render();
  });
}
function openCreateDream() {
  document.getElementById("dreamForm").reset();
  document.getElementById("createDreamModal").hidden = false;
  document.getElementById("createDreamOverlay").hidden = false;
}
function closeCreateDream() {
  document.getElementById("createDreamModal").hidden = true;
  document.getElementById("createDreamOverlay").hidden = true;
}
