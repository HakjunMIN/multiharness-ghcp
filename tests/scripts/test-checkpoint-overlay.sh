#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TEMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TEMP_DIR"' EXIT INT TERM

cp -R "$ROOT/app/api/." "$TEMP_DIR/"
cp -R "$ROOT/docs/instructor/checkpoint/app/api/src/." "$TEMP_DIR/src/"
cp -R "$ROOT/docs/instructor/checkpoint/app/api/tests/." "$TEMP_DIR/tests/"

cd "$TEMP_DIR"
export PYTHONPATH=src
export UV_DEFAULT_INDEX=https://packagefeedproxy.microsoft.io/pypi/simple
uv run --frozen pytest -q