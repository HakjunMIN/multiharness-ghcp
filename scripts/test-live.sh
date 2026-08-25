#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
set -a
[ ! -f "$ROOT/.env" ] || source "$ROOT/.env"
set +a

cd "$ROOT/app/api"
exec uv run --frozen pytest -m live -q