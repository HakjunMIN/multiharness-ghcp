#!/usr/bin/env bash
set -euo pipefail

if [ "${1:-}" != "--confirm" ] || [ -z "${WORKSHOP_SMOKE_REPO:-}" ]; then
  printf 'usage: WORKSHOP_SMOKE_REPO=owner/disposable-repo %s --confirm\n' "$0" >&2
  printf 'This test creates and closes Issues in the disposable repository.\n' >&2
  exit 2
fi

export GH_REPO="$WORKSHOP_SMOKE_REPO"
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"

map_issue=""
child_issue=""
cleanup() {
  [ -n "$child_issue" ] && gh issue close "$child_issue" --comment "Instructor smoke test cleanup" >/dev/null 2>&1 || true
  [ -n "$map_issue" ] && gh issue close "$map_issue" --comment "Instructor smoke test cleanup" >/dev/null 2>&1 || true
}
trap cleanup EXIT

./scripts/bootstrap-labels.sh >/dev/null
map_issue="$(./scripts/new-map.sh "Instructor smoke test")"
child_url="$(gh issue create \
  --title "[decision] instructor smoke test" \
  --label "wf:decision,phase:discovery,harness:claude" \
  --body "Disposable Issue used to validate workshop permissions and GraphQL mutations.")"
child_issue="${child_url##*/}"

owner="${WORKSHOP_SMOKE_REPO%%/*}"
repo="${WORKSHOP_SMOKE_REPO#*/}"
map_node="$(gh api graphql \
  -f query='query($o:String!,$r:String!,$n:Int!){repository(owner:$o,name:$r){issue(number:$n){id}}}' \
  -F o="$owner" -F r="$repo" -F n="$map_issue" --jq '.data.repository.issue.id')"
child_node="$(gh api graphql \
  -f query='query($o:String!,$r:String!,$n:Int!){repository(owner:$o,name:$r){issue(number:$n){id}}}' \
  -F o="$owner" -F r="$repo" -F n="$child_issue" --jq '.data.repository.issue.id')"
gh api graphql \
  -f query='mutation($p:ID!,$c:ID!){addSubIssue(input:{issueId:$p,subIssueId:$c}){issue{number}}}' \
  -F p="$map_node" -F c="$child_node" >/dev/null

frontier="$(./scripts/frontier.sh "$map_issue")"
printf '%s\n' "$frontier" | grep -qF "#$child_issue"

brief="$(mktemp)"
trap 'rm -f "$brief"; cleanup' EXIT
cat > "$brief" <<EOF
## HANDOFF
- from/to: Instructor/smoke -> Instructor/verified
- artifacts: README.md
- done: labels, Issue write, addSubIssue, frontier query
- not done: participant implementation
- decisions: Issue $child_issue
- verify: ./scripts/check-repo.sh
- risks: disposable repository only
EOF
./scripts/handoff.sh "$map_issue" "$brief" >/dev/null

printf 'OK: instructor smoke test passed in %s\n' "$WORKSHOP_SMOKE_REPO"
