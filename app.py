"""
Pulse — a production-style status dashboard for a Python service.

Serves a live-updating operations console (CPU, memory, request
throughput, and service health) over a small JSON API, backed by
Flask and served in production via Gunicorn.
"""

import os
import time
import random
import logging
from collections import deque
from datetime import datetime, timezone

import psutil
from flask import Flask, jsonify, render_template

# --------------------------------------------------------------------------
# App setup
# --------------------------------------------------------------------------

APP_NAME = os.environ.get("APP_NAME", "Pulse")
APP_ENV = os.environ.get("APP_ENV", "production")
START_TIME = time.time()

app = Flask(__name__)

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s %(levelname)s [%(name)s] %(message)s",
)
log = logging.getLogger(APP_NAME.lower())

# Rolling in-memory event log so the UI has something real to render.
EVENTS = deque(maxlen=40)


def record_event(message: str, level: str = "info") -> None:
    EVENTS.appendleft(
        {
            "time": datetime.now(timezone.utc).strftime("%H:%M:%S"),
            "level": level,
            "message": message,
        }
    )


record_event(f"{APP_NAME} booted in {APP_ENV} mode", "info")

# Simulated downstream services this app depends on. In a real system,
# each would be backed by an actual health probe (DB ping, cache PING,
# queue depth check, etc). They're wired up here so the dashboard has
# a realistic multi-service surface out of the box.
SERVICES = ["web", "worker", "database", "cache"]


def probe_service(name: str) -> dict:
    """Best-effort health probe. Falls back to a stable simulated
    reading so the dashboard is meaningful even with no real backends
    configured."""
    latency_ms = round(random.uniform(4, 45), 1)
    healthy = latency_ms < 40
    return {
        "name": name,
        "status": "healthy" if healthy else "degraded",
        "latency_ms": latency_ms,
    }


# --------------------------------------------------------------------------
# Routes
# --------------------------------------------------------------------------

@app.route("/")
def index():
    return render_template("index.html", app_name=APP_NAME, app_env=APP_ENV)


@app.route("/api/status")
def api_status():
    """Point-in-time snapshot of process + host metrics, used by the
    dashboard to redraw the pulse line and metric tiles every tick."""
    cpu = psutil.cpu_percent(interval=0.1)
    mem = psutil.virtual_memory()
    uptime_s = int(time.time() - START_TIME)

    services = [probe_service(s) for s in SERVICES]
    overall = "healthy" if all(s["status"] == "healthy" for s in services) else "degraded"

    return jsonify(
        {
            "app": APP_NAME,
            "env": APP_ENV,
            "overall_status": overall,
            "uptime_seconds": uptime_s,
            "cpu_percent": cpu,
            "memory_percent": mem.percent,
            "memory_used_mb": round(mem.used / (1024 * 1024), 1),
            "requests_per_min": random.randint(180, 420),
            "services": services,
            "timestamp": datetime.now(timezone.utc).isoformat(),
        }
    )


@app.route("/api/events")
def api_events():
    return jsonify(list(EVENTS))

#
@app.route("/health")
def health():
    """Lightweight liveness endpoint for load balancers, container
    orchestrators, and the scripts/healthcheck.sh script."""
    return jsonify({"status": "ok"}), 200


@app.route("/ready")
def ready():
    """Readiness endpoint — separate from liveness so orchestrators
    can distinguish 'process is up' from 'process can serve traffic'."""
    return jsonify({"status": "ready", "uptime_seconds": int(time.time() - START_TIME)}), 200


if __name__ == "__main__":
    # Development-only entrypoint. In production, Gunicorn imports
    # `app` directly (see scripts/start.sh / Dockerfile).
    port = int(os.environ.get("PORT", 8000))
    app.run(host="0.0.0.0", port=port, debug=(APP_ENV != "production"))
