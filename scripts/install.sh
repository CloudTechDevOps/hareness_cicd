#!/usr/bin/env bash
# One-time / repeatable setup: creates a virtualenv and installs
# pinned dependencies from requirements.txt.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

PYTHON_BIN="${PYTHON_BIN:-python3}"
VENV_DIR="${VENV_DIR:-$ROOT_DIR/venv}"

echo "[install] using $($PYTHON_BIN --version)"

if [ ! -d "$VENV_DIR" ]; then
  echo "[install] creating virtualenv at $VENV_DIR"
  "$PYTHON_BIN" -m venv "$VENV_DIR"
fi

# shellcheck disable=SC1091
source "$VENV_DIR/bin/activate"

echo "[install] upgrading pip"
pip install --upgrade pip --quiet

echo "[install] installing requirements"
pip install -r requirements.txt

echo "[install] done. Activate with: source $VENV_DIR/bin/activate"
