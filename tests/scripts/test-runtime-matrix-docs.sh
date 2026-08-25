#!/usr/bin/env bash
set -euo pipefail

for file in AGENTS.md README.md docs/reference/workflow.md docs/reference/model-harness-matrix.md; do
  grep -Fq 'grill-with-docs' "$file"
  grep -Fq 'GPT-5.6 Sol' "$file"
  grep -Fq 'Claude Sonnet 5' "$file"
done

grep -Fq 'Claude agent' docs/reference/model-harness-matrix.md
grep -Fq 'Claude Opus 5' docs/reference/model-harness-matrix.md

if grep -rInE '\./wf|wf:decision|wf:task|phase:|harness:' \
  AGENTS.md README.md docs/reference 2>/dev/null; then
  echo "legacy workflow reference found" >&2
  exit 1
fi

printf 'OK: runtime matrix documentation contract passed\n'
