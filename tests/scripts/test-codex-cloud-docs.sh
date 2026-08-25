#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

fail=0
require() {
  if ! grep -Fq -- "$2" "$1"; then
    printf 'FAIL: %s must contain: %s\n' "$1" "$2" >&2
    fail=1
  fi
}
reject() {
  if grep -Fq -- "$2" "$1"; then
    printf 'FAIL: %s must not contain: %s\n' "$1" "$2" >&2
    fail=1
  fi
}

require docs/labs/lab4-verification.md "A — 옵션"
require docs/labs/lab4-verification.md "Optional GHEC Codex cloud agent"
require docs/labs/lab4-verification.md 'test "$(gh pr diff "$PR" --name-only)" = "docs/uat/report.md"'
require docs/labs/lab4-verification.md 'SOURCE_BRANCH="workshop-verify-${SOURCE_COMMIT:0:12}"'
require docs/labs/lab4-verification.md 'git push -u origin "$SOURCE_BRANCH"'
require docs/labs/lab4-verification.md 'git ls-remote origin "refs/heads/$SOURCE_BRANCH"'
require docs/labs/lab4-verification.md 'grep -Fx -- "- Source commit: $SOURCE_COMMIT"'
require docs/labs/lab4-verification.md 'grep -Fx -- "- Source branch: $SOURCE_BRANCH"'
require docs/labs/lab4-verification.md '$SOURCE_BRANCH`를 starting branch로 선택한다.'
require docs/labs/lab4-verification.md '.state == "OPEN" and .isDraft == true'
require docs/labs/lab4-verification.md 'PR_HEAD="$(gh pr view "$PR" --json headRefOid --jq .headRefOid)"'
require docs/labs/lab4-verification.md 'baseRefName)" = "$SOURCE_BRANCH"'
require docs/labs/lab4-verification.md 'baseRefOid --jq .baseRefOid)" = "$SOURCE_COMMIT"'
require docs/labs/lab4-verification.md 'codex-cloud) HARNESS_LABEL="harness:codex"'
require docs/labs/lab4-verification.md 'copilot-terra) HARNESS_LABEL="harness:copilot"'
require docs/labs/lab4-verification.md 'export WORKSHOP_VERIFY_ROUTE=codex-cloud'
require docs/labs/lab4-verification.md 'export WORKSHOP_VERIFY_ROUTE=copilot-terra'
require docs/labs/lab4-verification.md 'git pull --ff-only origin "$SOURCE_BRANCH"'
require docs/labs/lab4-verification.md 'gh pr checks "$PR" --watch --fail-fast'
require docs/labs/lab4-verification.md 'gh pr merge "$PR" --merge --match-head-commit "$PR_HEAD"'
require docs/labs/lab4-verification.md 'state --jq .state)" = "MERGED"'
require docs/labs/lab4-verification.md 'github.raw+json'
require docs/labs/lab4-verification.md 'grep -Fx -- "- source branch: $SOURCE_BRANCH"'
require docs/labs/lab4-verification.md 'grep -Fx -- "- source commit: $SOURCE_COMMIT"'
require docs/templates/uat-report.md "- source branch:"
require docs/templates/uat-report.md "- source commit:"
require docs/prompts/codex-verifier.md "branch 이름은 비교하지 않는다."
require docs/labs/lab4-verification.md "경로 B — Copilot + GPT-5.6 Terra"
require docs/prompts/codex-verifier.md "허용된 유일한 변경 경로는 \`docs/uat/report.md\`다."
require docs/templates/codex-cloud-verification-issue.md "The only allowed changed file is:"
require docs/templates/codex-cloud-verification-issue.md "- Source commit:"
require docs/templates/codex-cloud-verification-issue.md "- Source branch:"
require scripts/preflight.sh 'codex-cloud)'
require scripts/preflight.sh 'WORKSHOP_VERIFY_ROUTE=codex-cloud'

reject scripts/preflight.sh "command -v codex"
reject docs/labs/lab4-verification.md "새 Codex 세션"
reject docs/labs/lab4-verification.md "Codex 하네스 UI"
reject docs/labs/lab4-verification.md "codex CLI"

fail_closed_blocks="$(grep -cF 'set -euo pipefail' docs/labs/lab4-verification.md)"
if [ "$fail_closed_blocks" -lt 3 ]; then
  printf 'FAIL: Path A setup, review, and merge blocks must fail closed\n' >&2
  fail=1
fi

checks_line="$(grep -nF 'gh pr checks "$PR" --watch --fail-fast' docs/labs/lab4-verification.md | cut -d: -f1)"
post_check_base_line="$(grep -nF 'baseRefOid --jq .baseRefOid)" = "$SOURCE_COMMIT"' docs/labs/lab4-verification.md | tail -1 | cut -d: -f1)"
merge_line="$(grep -nF 'gh pr merge "$PR" --merge --match-head-commit "$PR_HEAD"' docs/labs/lab4-verification.md | cut -d: -f1)"
if [ "$checks_line" -ge "$post_check_base_line" ] ||
   [ "$post_check_base_line" -ge "$merge_line" ]; then
  printf 'FAIL: source base must be revalidated after checks and before merge\n' >&2
  fail=1
fi

route_block="$(sed -n '/case "${WORKSHOP_VERIFY_ROUTE:-}"/,/esac/p' scripts/preflight.sh)"
route_count="$(printf '%s\n' "$route_block" |
  grep -Ec '^    (codex-cloud|copilot-terra)\)')"
if [ "$route_count" -ne 2 ]; then
  printf 'FAIL: strict preflight must define exactly codex-cloud and copilot-terra routes\n' >&2
  fail=1
fi
if printf '%s\n' "$route_block" |
   grep -E '^    [a-z][a-z0-9-]*\)' |
   grep -Ev '^    (codex-cloud|copilot-terra)\)' >/dev/null; then
  printf 'FAIL: strict preflight contains an unsupported verification route\n' >&2
  fail=1
fi

if [ "$fail" -ne 0 ]; then
  exit 1
fi
printf 'OK: Codex cloud documentation contract passed\n'
