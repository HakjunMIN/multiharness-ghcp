#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TEMP_DIR="$(mktemp -d)"
WEB_TEMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TEMP_DIR" "$WEB_TEMP_DIR"' EXIT INT TERM

cp -R "$ROOT/app/api/." "$TEMP_DIR/"
cp -R "$ROOT/docs/setup/checkpoint/app/api/src/." "$TEMP_DIR/src/"
cp -R "$ROOT/docs/setup/checkpoint/app/api/tests/." "$TEMP_DIR/tests/"

cd "$TEMP_DIR"
export PYTHONPATH=src
export UV_DEFAULT_INDEX=https://packagefeedproxy.microsoft.io/pypi/simple
uv run --frozen pytest -q

cp "$ROOT/app/web/package.json" "$ROOT/app/web/package-lock.json" \
  "$ROOT/app/web/tsconfig.json" "$ROOT/app/web/vite.config.ts" \
  "$ROOT/app/web/index.html" "$WEB_TEMP_DIR/"
mkdir -p "$WEB_TEMP_DIR/src/test"
cp "$ROOT/app/web/src/main.tsx" "$WEB_TEMP_DIR/src/"
cp "$ROOT/app/web/src/test/setup.ts" "$WEB_TEMP_DIR/src/test/"
ln -s "$ROOT/app/web/node_modules" "$WEB_TEMP_DIR/node_modules"
cp -R "$ROOT/docs/setup/checkpoint/app/web/src/." "$WEB_TEMP_DIR/src/"
cd "$WEB_TEMP_DIR"
npm test
npm run build