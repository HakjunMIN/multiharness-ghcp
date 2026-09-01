#!/usr/bin/env bash
set -euo pipefail

if WORKSHOP_CHECKPOINT_DIR=docs/setup/checkpoint ./scripts/restore-checkpoint.sh; then
  echo 'restore unexpectedly succeeded without --confirm' >&2
  exit 1
fi
grep -Fq 'worktree가 깨끗하지 않습니다' scripts/restore-checkpoint.sh
grep -Fq 'app/api' scripts/restore-checkpoint.sh
printf 'OK: checkpoint guards passed\n'
