# Lab 1 — 문제 발견과 요구 정의 (60분)

## 이 랩에서 배우는 것

해결책을 먼저 구현하지 않고 코드에서 설계 부채와 열린 질문을 발견한다. 발견한 결정을 GitHub Issue 계층에 기록해 하네스가 바뀌어도 유지되는 작업 지도를 만든다.

## 하네스 / 모델

| 하네스 | 모델 |
|---|---|
| Claude | Claude Opus 5 |

## 시작 전 상태

Lab 0의 프리플라이트가 `FAIL` 0개이고 seed 테스트가 통과하며, 현재 GitHub 저장소에 11개 워크숍 레이블이 존재한다. 실행 과제에 대한 map issue와 decision issue는 아직 없다.

## 단계

1. 실행 과제로 map issue를 만들고, 출력되는 이슈 번호를 현재 셸에 저장한다.

   ```bash
   cd /Users/andy/works/ai/multiharness-ghcp
   export MAP_ISSUE="$(./scripts/new-map.sh "지역별 프라이버시 규제에 따른 추론 라우팅과 텔레메트리 옵트아웃")"
   printf 'MAP_ISSUE=%s\n' "$MAP_ISSUE"
   ```

2. Claude 하네스에서 architect 프로파일을 선택한다.

   ```text
   /agent architect
   ```

3. architect에게 `seed/src/`를 읽고 실행 과제를 막는 미결정 사항을 찾도록 요청한다. 해결책을 구현하거나 코드를 수정하지 말고, 각 질문이 왜 결정되어야 하는지 설명하게 한다.

   ```text
   seed/src/를 읽고 "지역별 프라이버시 규제에 따라 추론 라우팅을 강제하고, 텔레메트리 옵트아웃을 지원하라"를 막는 미결정 사항을 찾아 주세요. 코드는 수정하지 말고 결정이 필요한 질문과 근거만 제시하세요.
   ```

4. 발견한 질문마다 하나씩, 최소 3개의 `wf:decision` 이슈를 생성한다. architect에게 각 이슈를 `phase:discovery`, `harness:claude`로 표시하고 생성된 번호를 알려 달라고 요청한다.

   ```text
   발견한 질문 중 서로 독립적인 항목을 최소 3개 골라, 질문 하나당 GitHub Issue 하나를 생성하세요. 각 이슈에 wf:decision, phase:discovery, harness:claude 레이블을 붙이고 이슈 번호를 목록으로 보고하세요.
   ```

5. 각 decision issue를 map issue에 native sub-issue로 연결한다. 프롬프트가 나오면 실제 번호를 공백으로 나열한다.

   ```bash
   printf 'Decision issue numbers (space-separated): '
   read -r DECISION_ISSUES
   export DECISION_ISSUES
   read -r OWNER REPO <<<"$(gh repo view --json owner,name --jq '.owner.login + " " + .name')"
   MAP_NODE="$(gh api graphql -f query='query($o:String!,$n:String!,$num:Int!){repository(owner:$o,name:$n){issue(number:$num){id}}}' -F o="$OWNER" -F n="$REPO" -F num="$MAP_ISSUE" --jq '.data.repository.issue.id')"
   for issue in $DECISION_ISSUES; do
     CHILD_NODE="$(gh api graphql -f query='query($o:String!,$n:String!,$num:Int!){repository(owner:$o,name:$n){issue(number:$num){id}}}' -F o="$OWNER" -F n="$REPO" -F num="$issue" --jq '.data.repository.issue.id')"
     gh api graphql -f query='mutation($parent:ID!,$child:ID!){addSubIssue(input:{issueId:$parent,subIssueId:$child}){issue{number}}}' -f parent="$MAP_NODE" -f child="$CHILD_NODE"
   done
   ```

   mutation 규약은 [GitHub Issue 운영 규칙](../reference/issue-conventions.md)을 따른다.

6. `handoff-brief` 스킬로 map issue에 게시할 인계 브리프를 만들고 파일로 저장한다.

   ```text
   handoff-brief 스킬을 사용해 현재 discovery 결과를 다음 Claude/Claude Opus 5 아키텍처 세션으로 넘기는 브리프를 작성하고 handoff-lab1.md에 저장하세요. artifacts는 커밋된 경로만 포함하고 verify는 복사해 실행할 수 있게 작성하세요.
   ```

7. 브리프를 map issue에 게시하고 `## HANDOFF` 코멘트가 보이는지 확인한다.

   ```bash
   ./scripts/handoff.sh "$MAP_ISSUE" handoff-lab1.md
   gh issue view "$MAP_ISSUE" --comments
   ```

> 강사 유의
>
> 설계 부채의 답을 먼저 공개하지 않는다. 30분이 지나도 진전이 없을 때만 `seed/README.md`의 `## 알려진 설계 부채` 섹션을 읽게 한다.

## 끝난 뒤 상태

실행 과제를 나타내는 map issue 1개 아래에 최소 3개의 열린 `wf:decision` 자식 이슈가 연결되어 있다. map issue 코멘트에는 다음 세션이 실행 가능한 검증 명령을 포함한 `## HANDOFF` 브리프가 1개 존재한다.

## 흔한 실패

- **증상:** map issue 번호 대신 설명 문장이 변수에 들어간다 → **원인:** 지정된 `./scripts/new-map.sh` 대신 다른 명령으로 이슈를 만들었다 → **조치:** 정확한 스크립트를 실행하고 숫자만 출력되는지 확인한다.
- **증상:** decision issue는 있지만 map에서 자식으로 보이지 않는다 → **원인:** 레이블만 붙이고 `addSubIssue` mutation을 실행하지 않았다 → **조치:** 각 이슈의 node ID를 조회한 뒤 `addSubIssue`를 실행한다.
- **증상:** architect가 바로 코드를 수정한다 → **원인:** architect 프로파일을 선택하지 않았거나 질문을 구현 요청으로 전달했다 → **조치:** `/agent architect`를 다시 선택하고 “코드는 수정하지 말라”고 명시한다.
- **증상:** `handoff.sh`가 브리프를 거부한다 → **원인:** 필수 필드가 빠졌거나 `artifacts`에 미커밋 경로가 있다 → **조치:** [하네스 간 인계 계약](../reference/handoff-contract.md)의 모든 필드를 채우고 경로의 Git 추적 상태를 확인한다.
