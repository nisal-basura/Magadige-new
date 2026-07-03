/* Landing page interactions: mobile nav + scroll-reveal */

document.addEventListener("DOMContentLoaded", () => {
  const burger = document.getElementById("navBurger");
  const links = document.querySelector(".nav-links");
  if (burger && links) {
    burger.innerHTML = ICON.menu;
    burger.addEventListener("click", () => {
      const open = links.style.display === "flex";
      links.style.cssText = open ? "" : "display:flex;position:absolute;top:100%;left:0;right:0;flex-direction:column;background:var(--bg-surface);padding:1rem 2rem;border-bottom:1px solid var(--border-subtle);gap:1rem;";
    });
  }

  const io = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add("anim-fade-up");
        io.unobserve(entry.target);
      }
    });
  }, { threshold: 0.12 });
  document.querySelectorAll(".feature-card, .showcase, .price-card").forEach(el => io.observe(el));
});
