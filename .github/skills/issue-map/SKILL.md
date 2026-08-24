---
name: issue-map
description: 맵을 만든다, 작업을 쪼갠다, 다음에 뭐 하지, frontier 요청이 나오면 이슈 계층과 의존성을 구성한다
---

# Issue Map

## 절차

1. 현재 리포와 기존 맵을 먼저 확인한다. 맵이 없고 사용자가 생성을 요청한 경우에만 새 맵을 만든다.

```bash
gh repo view --json nameWithOwner
gh issue list --label "wf:map" --state open
read -r -p "Destination: " DESTINATION
MAP_ISSUE="$(./scripts/new-map.sh "$DESTINATION")"
printf '%s\n' "$MAP_ISSUE"
```

2. 결정 단위로 자식 이슈를 만들고 목적에 맞는 워크플로, 단계, 하네스 라벨을 붙인다. 생성 전 제목, 본문, 대상 리포를 사용자에게 보여 준다.

```bash
: "${DECISION_TITLE:?DECISION_TITLE을 설정하세요}"
: "${DECISION_BODY:?DECISION_BODY 파일을 설정하세요}"
test -f "$DECISION_BODY"
gh repo view --json nameWithOwner
printf 'Title: %s\nBody: %s\n' "$DECISION_TITLE" "$DECISION_BODY"
gh issue create --title "$DECISION_TITLE" --label "wf:decision,phase:architecture,harness:claude" --body-file "$DECISION_BODY"
```

3. 저장소 소유자와 이름을 확인하고 각 이슈 번호를 node ID로 변환한다.

```bash
read -r OWNER REPO <<EOF
$(gh repo view --json owner,name --jq '.owner.login + " " + .name')
EOF
: "${ISSUE_NUMBER:?ISSUE_NUMBER를 설정하세요}"
[[ "$ISSUE_NUMBER" =~ ^[0-9]+$ ]]
gh api graphql -f query='query($o:String!,$n:String!,$num:Int!){repository(owner:$o,name:$n){issue(number:$num){id}}}' \
  -F o="$OWNER" -F n="$REPO" -F num="$ISSUE_NUMBER" --jq '.data.repository.issue.id'
```

4. GraphQL `addSubIssue`로 자식 이슈를 맵에 연결한다. 입력 필드는 `issueId`, `subIssueId`다.

```bash
: "${PARENT_NODE_ID:?PARENT_NODE_ID를 설정하세요}"
: "${CHILD_NODE_ID:?CHILD_NODE_ID를 설정하세요}"
gh api graphql -f query='mutation($parent:ID!,$child:ID!){addSubIssue(input:{issueId:$parent,subIssueId:$child}){issue{number}}}' \
  -F parent="$PARENT_NODE_ID" -F child="$CHILD_NODE_ID"
```

5. 선후관계는 GraphQL `addBlockedBy`로 연결한다. 입력 필드는 `issueId`, `blockingIssueId`다.

```bash
: "${BLOCKED_NODE_ID:?BLOCKED_NODE_ID를 설정하세요}"
: "${BLOCKER_NODE_ID:?BLOCKER_NODE_ID를 설정하세요}"
gh api graphql -f query='mutation($blocked:ID!,$blocker:ID!){addBlockedBy(input:{issueId:$blocked,blockingIssueId:$blocker}){issue{number}}}' \
  -F blocked="$BLOCKED_NODE_ID" -F blocker="$BLOCKER_NODE_ID"
```

6. 착수할 때 frontier를 조회한 뒤 선택한 이슈를 자신에게 할당해 클레임한다.

```bash
: "${MAP_ISSUE:?MAP_ISSUE를 설정하세요}"
: "${TASK_ISSUE:?TASK_ISSUE를 설정하세요}"
[[ "$MAP_ISSUE" =~ ^[0-9]+$ && "$TASK_ISSUE" =~ ^[0-9]+$ ]]
./scripts/frontier.sh "$MAP_ISSUE"
gh issue view "$TASK_ISSUE" --json number,title,state,assignees
gh issue edit "$TASK_ISSUE" --add-assignee "@me"
```

## GitHub CLI 호환성

`gh` 2.65.0은 `gh issue create --parent`와 `gh issue create --blocked-by`를 지원하지 않는다. 따라서 위의 검증된 GraphQL 호출을 사용해야 한다.

GraphQL의 `Issue`에서 조회 가능한 관련 필드는 `parent`, `subIssues`, `subIssuesSummary`, `blockedBy`, `issueDependenciesSummary`다. 부모 하나에는 최대 100개의 하위 이슈를 연결할 수 있고 중첩은 최대 8단계다.

## 라벨

- 워크플로: `wf:map`, `wf:decision`, `wf:task`, `wf:verify`
- 단계: `phase:discovery`, `phase:architecture`, `phase:implementation`, `phase:verification`
- 하네스: `harness:claude`, `harness:copilot`, `harness:codex`

## 원칙

**맵은 색인이다. 상세 내용은 자식 이슈에 쓴다.**
