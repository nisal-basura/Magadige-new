/* ==========================================================================
   Lightweight dependency-free SVG chart renderers
   ========================================================================== */

const MDG_CHART = (() => {
  const NS = "http://www.w3.org/2000/svg";

  function el(tag, attrs = {}) {
    const node = document.createElementNS(NS, tag);
    Object.entries(attrs).forEach(([k, v]) => node.setAttribute(k, v));
    return node;
  }

  /** Circular progress ring. target: DOM node, pct: 0-100 */
  function ring(target, pct, { size = 120, stroke = 12, color = "var(--brand)", track = "var(--bg-sunken)", label = "" } = {}) {
    const r = (size - stroke) / 2;
    const c = 2 * Math.PI * r;
    const offset = c - (Math.min(Math.max(pct, 0), 100) / 100) * c;
    const svg = el("svg", { width: size, height: size, viewBox: `0 0 ${size} ${size}`, class: "progress-ring" });
    svg.appendChild(el("circle", { cx: size / 2, cy: size / 2, r, fill: "none", stroke: track, "stroke-width": stroke }));
    const fg = el("circle", {
      cx: size / 2, cy: size / 2, r, fill: "none", stroke: color, "stroke-width": stroke,
      "stroke-linecap": "round", "stroke-dasharray": c, "stroke-dashoffset": c,
      transform: `rotate(-90 ${size / 2} ${size / 2})`, style: `--circ:${c}`,
    });
    svg.appendChild(fg);
    target.innerHTML = "";
    target.appendChild(svg);
    requestAnimationFrame(() => { fg.style.transition = "stroke-dashoffset 1.1s cubic-bezier(.16,1,.3,1)"; fg.setAttribute("stroke-dashoffset", offset); });
    if (label) {
      const wrap = document.createElement("div");
      wrap.className = "progress-ring-label";
      wrap.style.cssText = `position:absolute;inset:0;display:grid;place-content:center;text-align:center;`;
      wrap.innerHTML = label;
      target.style.position = "relative";
      target.appendChild(wrap);
    }
    return svg;
  }

  /** Simple animated bar chart. data: [{label, value, max}] */
  function barChart(target, data, { height = 160, color = "var(--brand)" } = {}) {
    const max = Math.max(...data.map(d => d.total ?? d.value ?? 1), 1);
    target.innerHTML = "";
    target.classList.add("bar-chart");
    target.style.height = height + "px";
    data.forEach((d, i) => {
      const value = d.completed ?? d.value;
      const total = d.total ?? max;
      const pctTotal = Math.max((total / max) * 100, 4);
      const pctDone = total ? (value / total) * 100 : 0;
      const col = document.createElement("div");
      col.className = "bar-col";
      col.style.setProperty("--h", pctTotal + "%");
      col.style.animationDelay = (i * 0.06) + "s";
      col.innerHTML = `
        <div class="bar-track">
          <div class="bar-fill" style="--fill:${pctDone}%"></div>
        </div>
        <span class="bar-label">${d.day || d.label}</span>`;
      target.appendChild(col);
    });
  }

  /** Sparkline / line chart. values: number[] */
  function lineChart(target, values, { width = 320, height = 90, color = "var(--brand)", fill = true } = {}) {
    const max = Math.max(...values);
    const min = Math.min(...values);
    const range = max - min || 1;
    const step = width / (values.length - 1);
    const points = values.map((v, i) => {
      const x = i * step;
      const y = height - ((v - min) / range) * (height - 14) - 7;
      return [x, y];
    });
    const path = points.map((p, i) => (i === 0 ? "M" : "L") + p[0].toFixed(1) + "," + p[1].toFixed(1)).join(" ");
    const areaPath = `${path} L${width},${height} L0,${height} Z`;
    const gradId = "grad-" + Math.random().toString(36).slice(2, 8);

    target.innerHTML = "";
    const svg = el("svg", { viewBox: `0 0 ${width} ${height}`, width: "100%", height, preserveAspectRatio: "none" });
    if (fill) {
      const defs = el("defs");
      const grad = el("linearGradient", { id: gradId, x1: 0, y1: 0, x2: 0, y2: 1 });
      grad.appendChild(el("stop", { offset: "0%", "stop-color": "var(--brand)", "stop-opacity": 0.35 }));
      grad.appendChild(el("stop", { offset: "100%", "stop-color": "var(--brand)", "stop-opacity": 0 }));
      defs.appendChild(grad);
      svg.appendChild(defs);
      svg.appendChild(el("path", { d: areaPath, fill: `url(#${gradId})`, stroke: "none" }));
    }
    const line = el("path", { d: path, fill: "none", stroke: color, "stroke-width": 2.5, "stroke-linecap": "round", "stroke-linejoin": "round" });
    const len = 1000;
    line.style.strokeDasharray = len;
    line.style.strokeDashoffset = len;
    svg.appendChild(line);
    points.forEach(([x, y], i) => {
      if (i === points.length - 1) {
        svg.appendChild(el("circle", { cx: x, cy: y, r: 4, fill: color, stroke: "var(--bg-surface)", "stroke-width": 2 }));
      }
    });
    target.appendChild(svg);
    requestAnimationFrame(() => {
      line.style.transition = "stroke-dashoffset 1.2s cubic-bezier(.16,1,.3,1)";
      line.style.strokeDashoffset = "0";
    });
  }

  /** Donut chart with legend. data: [{label, value, color}] */
  function donutChart(target, data, { size = 160, thickness = 22 } = {}) {
    const total = data.reduce((s, d) => s + d.value, 0) || 1;
    const r = (size - thickness) / 2;
    const c = 2 * Math.PI * r;
    let acc = 0;
    const svg = el("svg", { width: size, height: size, viewBox: `0 0 ${size} ${size}` });
    const g = el("g", { transform: `rotate(-90 ${size / 2} ${size / 2})` });
    data.forEach(d => {
      const frac = d.value / total;
      const dash = frac * c;
      const circle = el("circle", {
        cx: size / 2, cy: size / 2, r, fill: "none", stroke: d.color, "stroke-width": thickness,
        "stroke-dasharray": `${dash} ${c - dash}`, "stroke-dashoffset": -acc, "stroke-linecap": data.length > 1 ? "butt" : "round",
      });
      g.appendChild(circle);
      acc += dash;
    });
    svg.appendChild(g);
    target.innerHTML = "";
    target.appendChild(svg);
  }

  return { ring, barChart, lineChart, donutChart };
})();
