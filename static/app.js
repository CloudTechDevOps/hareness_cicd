(() => {
  const POLL_MS = 3000;
  const pulseLine = document.getElementById("pulse-line");
  const pulseHistory = new Array(60).fill(20); // 0-40 range, midline 20

  const el = (id) => document.getElementById(id);

  function statusColor(status) {
    if (status === "healthy") return "healthy";
    if (status === "degraded") return "degraded";
    return "critical";
  }

  function renderPulse(cpuPercent) {
    // Fold cpu load into a wandering EKG-like line: mostly flat with
    // occasional spikes proportional to load, so the line visibly
    // gets busier as the server gets busier.
    const spike = Math.random() < 0.18 + cpuPercent / 300;
    const amplitude = 10 + (cpuPercent / 100) * 55;
    const value = spike ? 20 + (Math.random() > 0.5 ? amplitude : -amplitude) : 20 + (Math.random() - 0.5) * 6;
    pulseHistory.push(Math.max(2, Math.min(38, value)));
    pulseHistory.shift();

    const stepX = 1000 / (pulseHistory.length - 1);
    const points = pulseHistory
      .map((v, i) => `${(i * stepX).toFixed(1)},${(180 - v * 4).toFixed(1)}`)
      .join(" ");
    pulseLine.setAttribute("points", points);
  }

  function renderMetrics(data) {
    el("cpu-value").textContent = data.cpu_percent.toFixed(1);
    el("cpu-bar").style.width = `${Math.min(100, data.cpu_percent)}%`;

    el("mem-value").textContent = data.memory_percent.toFixed(1);
    el("mem-bar").style.width = `${Math.min(100, data.memory_percent)}%`;

    el("rpm-value").textContent = data.requests_per_min;
    el("rpm-bar").style.width = `${Math.min(100, (data.requests_per_min / 500) * 100)}%`;

    el("mem-mb-value").textContent = data.memory_used_mb.toFixed(0);
    el("mem-mb-bar").style.width = `${Math.min(100, (data.memory_used_mb / 4096) * 100)}%`;

    const pill = statusColor(data.overall_status);
    el("overall-dot").className = `dot ${pill}`;
    el("overall-label").textContent = data.overall_status;

    const h = Math.floor(data.uptime_seconds / 3600);
    const m = Math.floor((data.uptime_seconds % 3600) / 60);
    const s = data.uptime_seconds % 60;
    el("uptime").textContent = `uptime ${h}h ${m}m ${s}s`;

    renderServices(data.services);
    renderPulse(data.cpu_percent);
  }

  function renderServices(services) {
    const list = el("service-list");
    list.innerHTML = "";
    services.forEach((svc) => {
      const li = document.createElement("li");
      const cls = statusColor(svc.status);
      li.innerHTML = `
        <span class="service-name"><span class="dot ${cls}"></span>${svc.name}</span>
        <span class="service-latency">${svc.latency_ms} ms</span>
      `;
      list.appendChild(li);
    });
  }

  function renderEvents(events) {
    const list = el("event-list");
    list.innerHTML = "";
    events.forEach((ev) => {
      const li = document.createElement("li");
      li.className = ev.level;
      li.innerHTML = `<span class="ev-time">${ev.time}</span><span class="ev-msg">${ev.message}</span>`;
      list.appendChild(li);
    });
  }

  async function tick() {
    try {
      const [statusRes, eventsRes] = await Promise.all([
        fetch("/api/status"),
        fetch("/api/events"),
      ]);
      renderMetrics(await statusRes.json());
      renderEvents(await eventsRes.json());
    } catch (err) {
      el("overall-label").textContent = "unreachable";
      el("overall-dot").className = "dot critical";
    }
  }

  function tickClock() {
    el("clock").textContent = new Date().toUTCString().slice(17, 25) + " UTC";
  }

  tick();
  tickClock();
  setInterval(tick, POLL_MS);
  setInterval(tickClock, 1000);
})();
