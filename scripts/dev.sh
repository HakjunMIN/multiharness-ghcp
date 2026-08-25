#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
set -a
[ ! -f "$ROOT/.env" ] || source "$ROOT/.env"
set +a

pids=()
cleanup() {
  for pid in "${pids[@]}"; do
    kill "$pid" 2>/dev/null || true
  done
}
trap cleanup EXIT INT TERM

(cd "$ROOT/app/api" && uv run uvicorn consult.main:app --reload --port 8000) &
pids+=("$!")
(cd "$ROOT/app/web" && npm run dev -- --host 127.0.0.1 --port 5173) &
pids+=("$!")
while kill -0 "${pids[0]}" 2>/dev/null && kill -0 "${pids[1]}" 2>/dev/null; do
  sleep 1
done
