/* ==========================================================================
   Auth interactions: validation states, password visibility, strength meter,
   OTP auto-advance, simulated loading + redirect. All client-side/demo only.
   ========================================================================== */

document.addEventListener("DOMContentLoaded", () => {

  // ---- Password visibility toggles -------------------------------------
  document.querySelectorAll("[data-toggle-password]").forEach(btn => {
    btn.innerHTML = ICON.eye;
    btn.addEventListener("click", () => {
      const input = document.getElementById(btn.dataset.togglePassword);
      const isPw = input.type === "password";
      input.type = isPw ? "text" : "password";
      btn.innerHTML = isPw ? ICON.eyeOff : ICON.eye;
    });
  });

  // ---- Password strength meter -------------------------------------------
  const pwInput = document.getElementById("regPassword");
  const strengthBars = document.querySelectorAll(".pw-strength-bar");
  if (pwInput && strengthBars.length) {
    pwInput.addEventListener("input", () => {
      const v = pwInput.value;
      let score = 0;
      if (v.length >= 8) score++;
      if (/[A-Z]/.test(v)) score++;
      if (/[0-9]/.test(v)) score++;
      if (/[^A-Za-z0-9]/.test(v)) score++;
      const colors = ["var(--coral-500)", "var(--coral-500)", "var(--amber-500)", "var(--mint-500)", "var(--mint-600)"];
      strengthBars.forEach((bar, i) => {
        bar.style.background = i < score ? colors[score] : "var(--bg-sunken)";
      });
    });
  }

  // ---- Avatar upload preview --------------------------------------------
  const avatarInput = document.getElementById("avatarInput");
  const avatarCircle = document.getElementById("avatarCircle");
  if (avatarInput && avatarCircle) {
    avatarInput.addEventListener("change", () => {
      const file = avatarInput.files[0];
      if (!file) return;
      const reader = new FileReader();
      reader.onload = (e) => {
        avatarCircle.innerHTML = `<img src="${e.target.result}" alt="Avatar preview" />`;
      };
      reader.readAsDataURL(file);
    });
  }

  // ---- OTP inputs: auto-advance / backspace ------------------------------
  const otpInputs = document.querySelectorAll(".otp-input");
  otpInputs.forEach((input, i) => {
    input.addEventListener("input", () => {
      input.value = input.value.replace(/[^0-9]/g, "").slice(0, 1);
      if (input.value && otpInputs[i + 1]) otpInputs[i + 1].focus();
    });
    input.addEventListener("keydown", (e) => {
      if (e.key === "Backspace" && !input.value && otpInputs[i - 1]) otpInputs[i - 1].focus();
    });
  });

  // ---- Form submit: validation + simulated loading -----------------------
  document.querySelectorAll("form[data-auth-form]").forEach(form => {
    form.addEventListener("submit", (e) => {
      e.preventDefault();
      let valid = true;
      form.querySelectorAll("[required]").forEach(field => {
        const errorEl = form.querySelector(`[data-error-for="${field.id}"]`);
        const empty = !field.value.trim();
        const mismatch = field.dataset.matches && form.querySelector(`#${field.dataset.matches}`)?.value !== field.value;
        const hasError = empty || mismatch;
        field.classList.toggle("has-error", hasError);
        if (errorEl) errorEl.textContent = empty ? "This field is required" : mismatch ? "Passwords don't match" : "";
        if (hasError) valid = false;
      });
      if (!valid) return;

      const btn = form.querySelector('button[type="submit"]');
      const redirect = form.dataset.redirect;
      btn.classList.add("btn-loading");
      btn.disabled = true;
      setTimeout(() => {
        if (redirect) location.href = redirect;
      }, 1100);
    });
  });

  // ---- Step indicator demo (forgot password) ------------------------------
  window.MDG_AUTH_STEP = function (step) {
    document.querySelectorAll(".auth-step-panel").forEach(p => p.hidden = true);
    const panel = document.getElementById("step-" + step);
    if (panel) panel.hidden = false;
    document.querySelectorAll(".auth-step-dot").forEach((dot, i) => {
      dot.classList.toggle("is-active", i === step - 1);
      dot.classList.toggle("is-done", i < step - 1);
    });
  };
});
