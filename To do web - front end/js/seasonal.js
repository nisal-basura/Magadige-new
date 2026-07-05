/* ==========================================================================
   Site-wide seasonal effects — controlled from admin.html, persisted to
   localStorage, and mounted on every page via a lightweight canvas overlay.
   Kept subtle and non-interactive (pointer-events: none) so it never gets
   in the way of the actual product underneath.
   ========================================================================== */

const MDG_SEASONAL = (() => {
  const KEY = "magadige_seasonal_theme"; // "none" | "christmas" | "newyear"
  const reduceMotion = window.matchMedia && window.matchMedia("(prefers-reduced-motion: reduce)").matches;

  let canvas, ctx, raf, particles = [], resizeHandler;
  let fireworkTimer;

  function getTheme() {
    return localStorage.getItem(KEY) || "none";
  }

  function setTheme(theme) {
    localStorage.setItem(KEY, theme);
    mount();
  }

  function teardown() {
    if (raf) cancelAnimationFrame(raf);
    if (fireworkTimer) clearInterval(fireworkTimer);
    if (resizeHandler) window.removeEventListener("resize", resizeHandler);
    if (canvas) canvas.remove();
    canvas = null; ctx = null; particles = [];
  }

  function setupCanvas() {
    canvas = document.createElement("canvas");
    canvas.id = "mdgSeasonalCanvas";
    canvas.style.cssText = "position:fixed;inset:0;width:100%;height:100%;pointer-events:none;z-index:9999;";
    document.body.appendChild(canvas);
    ctx = canvas.getContext("2d");
    const resize = () => { canvas.width = window.innerWidth; canvas.height = window.innerHeight; };
    resize();
    resizeHandler = resize;
    window.addEventListener("resize", resizeHandler);
  }

  function mountChristmas() {
    setupCanvas();
    const count = reduceMotion ? 0 : Math.min(70, Math.round(window.innerWidth / 14));
    particles = Array.from({ length: count }, () => ({
      x: Math.random() * canvas.width,
      y: Math.random() * canvas.height,
      r: Math.random() * 3 + 1.5,
      speed: Math.random() * 0.6 + 0.4,
      drift: Math.random() * 1 - 0.5,
      sway: Math.random() * Math.PI * 2,
    }));

    function draw() {
      ctx.clearRect(0, 0, canvas.width, canvas.height);
      ctx.fillStyle = "rgba(255,255,255,0.85)";
      particles.forEach(p => {
        p.y += p.speed;
        p.sway += 0.02;
        p.x += Math.sin(p.sway) * 0.4 + p.drift * 0.15;
        if (p.y > canvas.height) { p.y = -5; p.x = Math.random() * canvas.width; }
        if (p.x > canvas.width) p.x = 0;
        if (p.x < 0) p.x = canvas.width;
        ctx.beginPath();
        ctx.arc(p.x, p.y, p.r, 0, Math.PI * 2);
        ctx.fill();
      });
      raf = requestAnimationFrame(draw);
    }
    if (!reduceMotion) draw();
  }

  function mountNewYear() {
    setupCanvas();
    const bursts = [];
    const colors = ["#6c4eff", "#1f97f2", "#fa8f0f", "#22c58b", "#ff6b6b", "#ffffff"];

    function spawnBurst() {
      const x = Math.random() * canvas.width * 0.8 + canvas.width * 0.1;
      const y = Math.random() * canvas.height * 0.5 + canvas.height * 0.1;
      const color = colors[Math.floor(Math.random() * colors.length)];
      const particleCount = 32;
      for (let i = 0; i < particleCount; i++) {
        const angle = (Math.PI * 2 * i) / particleCount;
        const speed = Math.random() * 2.4 + 1.6;
        bursts.push({
          x, y, color,
          vx: Math.cos(angle) * speed,
          vy: Math.sin(angle) * speed,
          life: 1,
        });
      }
    }

    function draw() {
      ctx.clearRect(0, 0, canvas.width, canvas.height);
      for (let i = bursts.length - 1; i >= 0; i--) {
        const b = bursts[i];
        b.x += b.vx;
        b.y += b.vy;
        b.vy += 0.03; // gravity
        b.life -= 0.012;
        if (b.life <= 0) { bursts.splice(i, 1); continue; }
        ctx.globalAlpha = Math.max(b.life, 0);
        ctx.fillStyle = b.color;
        ctx.beginPath();
        ctx.arc(b.x, b.y, 2.6, 0, Math.PI * 2);
        ctx.fill();
      }
      ctx.globalAlpha = 1;
      raf = requestAnimationFrame(draw);
    }

    if (!reduceMotion) {
      spawnBurst();
      fireworkTimer = setInterval(spawnBurst, 1800);
      draw();
    }
  }

  function mount() {
    teardown();
    const theme = getTheme();
    if (theme === "christmas") mountChristmas();
    else if (theme === "newyear") mountNewYear();
  }

  document.addEventListener("DOMContentLoaded", mount);

  return { getTheme, setTheme, mount, teardown };
})();
