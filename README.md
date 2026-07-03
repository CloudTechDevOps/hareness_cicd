# Pulse

A small production-shaped Flask service with a live, animated ops
dashboard — CPU, memory, request throughput, dependent-service
health, and a rolling event log, all redrawn from real process
metrics every few seconds. Served by Gunicorn.

## Structure

```
python-app/
├── app.py                 Flask app + JSON API (/api/status, /api/events, /healthz, /readyz)
├── requirements.txt
├── Dockerfile              Production image, runs via Gunicorn as non-root
├── templates/index.html    Dashboard markup
├── static/style.css        Dark ambient design system
├── static/app.js           Polls the API, animates the pulse line + tiles
├── scripts/
│   ├── gunicorn.conf.py    Production Gunicorn config
│   ├── install.sh          Create venv + install deps
│   ├── start.sh            Launch via Gunicorn
│   ├── stop.sh              Graceful shutdown by pidfile
│   ├── healthcheck.sh       Probe /healthz + /readyz
│   ├── backup.sh            Timestamped tarball backup with retention
│   ├── deploy.sh            Backup → pull → install → restart → verify (auto rollback on failure)
│   └── rollback.sh          Restore the most recent backup
└── .github/workflows/ci-cd.yml   Lint, smoke test, build & push Docker image
```

## Run locally

```bash
./scripts/install.sh
source venv/bin/activate
./scripts/start.sh
# → http://localhost:5000
```

## Run with Docker

```bash
docker build -t pulse .
docker run -p 5000:5000 pulse
```

## Deploy

```bash
./scripts/deploy.sh      # backs up, updates, restarts, verifies, auto-rolls back on failure
./scripts/rollback.sh    # manual rollback to the last backup
```

## Configuration

All tunables are environment variables — see `.env.example`.
