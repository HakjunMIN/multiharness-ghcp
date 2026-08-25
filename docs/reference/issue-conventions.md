# GitHub Issue 운영 규칙

GitHub Issues는 하네스 전환을 견디는 유일한 지속 상태 저장소다. 결정, 작업, 검증 상태를 채팅에만 남기지 않는다.

## 레이블 집합

| 이름 | 색상 | 의미 |
|---|---|---|
| `wf:map` | `0e8a16` | 맵 이슈 |
| `wf:decision` | `1d76db` | 결정이 필요한 열린 질문 |
| `wf:task` | `5319e7` | 구현 가능한 작업 |
| `wf:verify` | `b60205` | 검증/UAT 항목 |
| `phase:discovery` | `fbca04` | 발견 단계 |
| `phase:architecture` | `fbca04` | 아키텍처 단계 |
| `phase:implementation` | `fbca04` | 구현 단계 |
| `phase:verification` | `fbca04` | 검증 단계 |
| `harness:claude` | `c5def5` | Claude 하네스 담당 |
| `harness:copilot` | `c5def5` | Copilot 하네스 담당 |
| `harness:codex` | `c5def5` | GHEC Codex cloud agent 담당 |

## 계층과 작업 가능 범위

하나의 맵 이슈(map issue) 아래에 결정(`wf:decision`), 구현 작업(`wf:task`), 검증(`wf:verify`) 자식 이슈를 둔다. 네이티브 하위 이슈(native sub-issues)는 **부모 하나당 최대 100개 자식과 최대 8단계 중첩**을 지원한다.

**프런티어(frontier)**는 다음 조건을 모두 만족하는 이슈다.

- 열려 있다(open).
- 담당자가 없다(unassigned).
- 열려 있는 `blockedBy` 이슈가 없다.

담당자(assignee)는 작업 선점(claim)을 나타내는 잠금이다. 시작하기 전에 반드시 자신을 담당자로 지정해 다른 에이전트의 중복 작업을 막는다.

## `gh` 버전과 GraphQL 사용

`gh` 2.65.0에는 `gh issue create --parent`와 `--blocked-by` 옵션이 없다. 이 때문에 워크숍 스크립트는 GraphQL API를 직접 호출한다. 아래 예제의 `OWNER`, `REPO`, 이슈 번호, 노드 ID를 실제 값으로 바꾸면 그대로 실행할 수 있다.

Mutation 이름과 입력 필드는 [참고 자료](sources.md)에 연결된 GitHub GraphQL mutation reference에서 행사 전날 다시 확인한다.

### 이슈 번호를 노드 ID로 변환

```bash
gh api graphql -f query='query($o:String!,$n:String!,$num:Int!){repository(owner:$o,name:$n){issue(number:$num){id}}}' -F o=OWNER -F n=REPO -F num=12 --jq '.data.repository.issue.id'
```

### 하위 이슈 연결

```bash
gh api graphql \
  -f query='mutation($parent:ID!,$child:ID!){addSubIssue(input:{issueId:$parent,subIssueId:$child}){issue{number}}}' \
  -f parent='PARENT_NODE_ID' \
  -f child='CHILD_NODE_ID'
```

사용하는 변형(mutation)은 `addSubIssue(input: { issueId: $parent, subIssueId: $child })`이며 `issue { number }`를 반환한다.

### 의존성 추가

```bash
gh api graphql \
  -f query='mutation($blocked:ID!,$blocker:ID!){addBlockedBy(input:{issueId:$blocked,blockingIssueId:$blocker}){issue{number}}}' \
  -f blocked='BLOCKED_ISSUE_NODE_ID' \
  -f blocker='BLOCKING_ISSUE_NODE_ID'
```

사용하는 변형은 `addBlockedBy(input: { issueId: $blocked, blockingIssueId: $blocker })`이다.

조회에 사용할 수 있는 `Issue` 필드는 `parent`, `subIssues`, `subIssuesSummary`, `blockedBy`, `issueDependenciesSummary`다.

기존 “task lists” 문서는 현재 네이티브 하위 이슈 문서로 리디렉션된다. 따라서 이 워크숍은 체크박스 기반 task list 대신 네이티브 sub-issues를 사용한다. 최신 관련 자료는 [참고 자료](sources.md)에서 확인한다.
