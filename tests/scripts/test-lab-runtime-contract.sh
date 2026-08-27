#!/usr/bin/env bash
set -euo pipefail

grep -Fq 'npx skills@latest add mattpocock/skills' docs/labs/lab0-preflight.md
grep -Fq 'npx skills update' docs/labs/lab0-preflight.md
grep -Fq '/setup-matt-pocock-skills' docs/labs/lab0-preflight.md

for file in docs/labs/lab1-discovery.md docs/labs/lab2-spec-tickets.md; do
  grep -Fq 'Session Target: Claude' "$file"
  grep -Fq 'Claude Opus 5' "$file"
done
grep -Fq '/grill-with-docs' docs/labs/lab1-discovery.md
grep -Fq '/to-spec' docs/labs/lab2-spec-tickets.md
grep -Fq '/to-tickets' docs/labs/lab2-spec-tickets.md

grep -Fq 'GPT-5.6 Sol' docs/labs/lab3-tracer-bullet.md
grep -Fq 'Session Target: Copilot' docs/labs/lab3-tracer-bullet.md
grep -Fq '/implement' docs/labs/lab3-tracer-bullet.md
grep -Fq 'HANDOFF' docs/labs/lab4-cold-start.md
grep -Fq 'GPT-5.6 Sol' docs/labs/lab5-improvement.md
grep -Fq 'Claude Sonnet 5' docs/labs/lab6-verification.md
grep -Fq 'Session Target: Copilot' docs/labs/lab6-verification.md
grep -Fq '/code-review main' docs/labs/lab6-verification.md

# these runtime notations do not exist as literal chat commands in VS Code and must not reappear
if grep -rInE '\./wf|/agent (architect|implementer|verifier)|/agent Claude|/model (Claude|GPT)|GPT-5\.6 Terra' \
  docs/labs docs/instructor docs/reference 2>/dev/null; then
  echo "legacy runtime guidance found" >&2
  exit 1
fi

printf 'OK: lab runtime contract passed\n'
