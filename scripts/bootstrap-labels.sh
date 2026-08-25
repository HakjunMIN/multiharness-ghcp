#!/usr/bin/env bash
set -euo pipefail

# Create the workshop label set. Idempotent: --force updates existing labels.

if ! gh repo view --json nameWithOwner >/dev/null 2>&1; then
  printf 'FAIL: 이 스크립트는 GitHub 리포 안에서 실행해야 합니다. 먼저 실행: gh repo create\n' >&2
  exit 1
fi

labels=(
  "wf:map|0e8a16|워크샵 맵 이슈 (워크샵당 1개)"
  "wf:decision|1d76db|결정이 필요한 열린 질문"
  "wf:task|5319e7|결정이 끝나 구현 가능한 작업"
  "wf:verify|b60205|독립 검증 / UAT 항목"
  "phase:discovery|fbca04|Lab 1 문제 발견과 요구 정의"
  "phase:architecture|fbca04|Lab 2 결정과 아키텍처"
  "phase:implementation|fbca04|Lab 3 구현"
  "phase:verification|fbca04|Lab 4 검증과 수락 테스트"
  "harness:claude|c5def5|Claude 하네스에서 다룰 이슈"
  "harness:copilot|c5def5|Copilot 하네스에서 다룰 이슈"
  "harness:codex|c5def5|GHEC Codex cloud agent에서 다룰 이슈"
)

for entry in "${labels[@]}"; do
  IFS='|' read -r name color desc <<<"$entry"
  gh label create "$name" --color "$color" --description "$desc" --force >/dev/null
  printf 'label: %s\n' "$name"
done

printf 'OK: %d labels ready\n' "${#labels[@]}"
