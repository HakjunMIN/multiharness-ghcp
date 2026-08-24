#!/usr/bin/env bash
set -euo pipefail

# Show the child issues of a map that can be started right now.
# frontier = open AND unassigned AND no open blockedBy.
# Usage: ./scripts/frontier.sh <map-issue-number>

if [ $# -lt 1 ] || [ -z "${1:-}" ]; then
  printf 'usage: %s <map-issue-number>\n' "$0" >&2
  exit 2
fi

map="$1"

if ! gh repo view --json nameWithOwner >/dev/null 2>&1; then
  printf 'FAIL: 이 스크립트는 GitHub 리포 안에서 실행해야 합니다. 먼저 실행: gh repo create\n' >&2
  exit 1
fi

owner="$(gh repo view --json owner --jq '.owner.login')"
name="$(gh repo view --json name --jq '.name')"

query='query($o:String!, $n:String!, $num:Int!) {
  repository(owner:$o, name:$n) {
    issue(number:$num) {
      subIssues(first:100) {
        nodes {
          number title state
          assignees(first:5){ nodes { login } }
          labels(first:20){ nodes { name } }
          blockedBy(first:20){ nodes { number state } }
        }
      }
    }
  }
}'

filter='.data.repository.issue.subIssues.nodes[]
  | select(.state == "OPEN")
  | select((.assignees.nodes | length) == 0)
  | select(([.blockedBy.nodes[] | select(.state == "OPEN")] | length) == 0)
  | "#\(.number)  [\((.labels.nodes | map(.name) | map(select(startswith("phase:"))) | first // "phase:-") | sub("^phase:"; ""))]  \(.title)"'

out="$(gh api graphql -f query="$query" -F o="$owner" -F n="$name" -F num="$map" --jq "$filter")"

if [ -z "$out" ]; then
  printf 'frontier: 착수 가능한 이슈가 없습니다 (모두 차단되었거나 할당되었습니다)\n'
  exit 0
fi
printf '%s\n' "$out"
