"""Gunicorn production configuration for the app.

Tunable via environment variables so the same config works locally,
in Docker, and behind whatever process manager deploy.sh uses.
"""

import multiprocessing
import os

bind = f"0.0.0.0:{os.environ.get('PORT', '5000')}"

# A common, safe default: 2x CPU cores + 1. Override with WEB_CONCURRENCY.
workers = int(os.environ.get("WEB_CONCURRENCY", multiprocessing.cpu_count() * 2 + 1))
worker_class = "sync"
threads = int(os.environ.get("WEB_THREADS", 2))

timeout = int(os.environ.get("GUNICORN_TIMEOUT", 30))
graceful_timeout = 30
keepalive = 5

accesslog = "-"
errorlog = "-"
loglevel = os.environ.get("LOG_LEVEL", "info")

pidfile = os.environ.get("GUNICORN_PIDFILE", "/tmp/pulse.pid")

# Recycle workers periodically to guard against slow memory leaks.
max_requests = 1000
max_requests_jitter = 100
