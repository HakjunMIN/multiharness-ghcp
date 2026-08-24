# Lab 2 — 결정과 아키텍처 (45분)

## 이 랩에서 배우는 것

열린 질문의 대안을 비교해 근거 있는 결정을 내리고, 결정 결과를 바로 구현 가능한 작업으로 변환한다. 의존성을 명시해 다음 구현 세션이 안전하게 시작할 frontier를 만든다.

## 하네스 / 모델

| 하네스 | 모델 |
|---|---|
| Claude | Claude Opus 5 |

## 시작 전 상태

map issue 1개에 최소 3개의 열린 `wf:decision` 자식 이슈가 연결되어 있고, map issue에는 discovery 단계의 `## HANDOFF` 코멘트가 존재한다. 구현 코드와 `wf:task` 이슈는 아직 만들지 않았다.

## 단계

1. 새 Claude 세션에서 map과 decision 이슈 번호를 복구한 뒤 architect 프로파일을 선택하고 해당 이슈들을 읽는다.

   ```bash
   cd /Users/andy/works/ai/multiharness-ghcp
   printf 'Map issue number: '
   read -r MAP_ISSUE
   export MAP_ISSUE
   printf 'Decision issue numbers (space-separated): '
   read -r DECISION_ISSUES
   export DECISION_ISSUES
   ```

   ```text
   /agent architect
   ```

   ```text
   현재 map issue와 모든 wf:decision 자식 이슈를 읽고, 아직 코드를 수정하지 않은 채 결정 순서를 제안하세요.
   ```

2. 각 decision issue에 가능한 대안 2~3개와 trade-off를 코멘트로 작성한다. 비용, 프라이버시 안전성, API 안정성, 테스트 가능성을 비교하되 선택은 아직 기록하지 않는다.

   ```text
   각 wf:decision 이슈에 대안 2~3개를 만들고 비용, 프라이버시 안전성, API 안정성, 테스트 가능성의 trade-off를 비교한 코멘트를 게시하세요. 이 단계에서는 선택하지 마세요.
   ```

3. 각 이슈에서 대안 하나를 선택하고 선택 근거를 명시한 코멘트를 게시한다.

   ```text
   각 wf:decision 이슈에서 대안 하나를 선택하고, 버린 대안보다 적합한 이유와 수용한 trade-off를 명시한 코멘트를 게시하세요.
   ```

4. 선택한 결정을 map issue 본문의 `## Decisions so far` 아래에 한 줄씩 추가한다.

   ```text
   확정된 각 결정을 출처 decision issue 링크와 함께 한 줄로 요약해 map issue의 ## Decisions so far 섹션에 추가하세요. 기존 본문의 다른 섹션은 보존하세요.
   ```

5. 결정 기록을 확인한 뒤 모든 decision issue를 닫는다.

   ```bash
   for issue in $DECISION_ISSUES; do gh issue close "$issue" --comment "대안, trade-off, 선택 근거와 map 반영을 완료했습니다."; done
   ```

6. 결정에서 파생되는 구현 단위를 `wf:task` 자식 이슈로 만든다. 각 이슈는 한 세션에서 완료 가능해야 하며 명확한 acceptance criteria와 검증 명령을 포함해야 한다.

   ```text
   확정된 결정을 한 세션에서 완료 가능한 구현 단위로 나눠 wf:task, phase:implementation, harness:copilot 레이블의 이슈를 생성하세요. 각 본문에 관찰 가능한 acceptance criteria와 `cd seed && npm test && cd ..` 검증 명령을 포함하고, 생성한 이슈 번호를 보고하세요.
   ```

7. 생성한 task issue를 map issue에 `addSubIssue`로 연결하고, 선행 작업이 필요한 순서를 `addBlockedBy`로 연결하도록 architect에게 요청한다.

   ```text
   생성한 모든 wf:task 이슈를 현재 map issue의 native sub-issue로 addSubIssue 하세요. 반드시 선행되어야 하는 작업만 addBlockedBy로 연결하고, 독립 작업에는 불필요한 의존성을 만들지 마세요.
   ```

8. 현재 frontier에 착수 가능한 task가 있는지 확인한다.

   ```bash
   ./scripts/frontier.sh "$MAP_ISSUE"
   ```

9. `handoff-brief` 스킬로 구현 세션에 전달할 브리프를 만들고 map issue에 게시한다.

   ```text
   handoff-brief 스킬을 사용해 Claude/Claude Opus 5에서 Copilot/GPT-5.6 Sol로 넘길 브리프를 작성하고 handoff-lab2.md에 저장하세요. 확정된 결정 이슈, 시작 가능한 task, 검증 명령, 남은 위험을 포함하세요.
   ```

   ```bash
   ./scripts/handoff.sh "$MAP_ISSUE" handoff-lab2.md
   ```

**이 랩에서도 코드를 수정하지 않는다.** `architect` 프로파일이 이 규칙을 강제한다. 이 단계의 산출물은 코드가 아니라 결정 기록, 구현 이슈, 의존성 그래프다.

## 끝난 뒤 상태

모든 `wf:decision` 이슈가 대안·trade-off·선택 근거를 남긴 채 닫혀 있고, map의 `## Decisions so far`에 각 결정이 한 줄로 기록되어 있다. 파생된 `wf:task` 이슈가 map에 연결되고 필요한 `addBlockedBy` 순서가 설정되어, `./scripts/frontier.sh <map>`이 시작 가능한 `wf:task`를 최소 1개 출력한다.

## 흔한 실패

- **증상:** 결정 코멘트에 선택안만 있고 비교 근거가 없다 → **원인:** 대안 탐색과 선택을 한 단계로 합쳤다 → **조치:** 2~3개 대안과 trade-off를 먼저 기록하고 별도 코멘트로 선택 근거를 남긴다.
- **증상:** 닫힌 decision issue의 결정을 map에서 찾을 수 없다 → **원인:** `## Decisions so far` 인덱스를 갱신하지 않았다 → **조치:** 결정 요약과 원본 이슈 링크를 map에 한 줄씩 추가한다.
- **증상:** `frontier.sh` 출력이 비어 있다 → **원인:** 모든 task가 닫히지 않은 작업에 막혔거나 담당자가 이미 지정되어 있다 → **조치:** `addBlockedBy` 방향과 assignee를 확인해 적어도 하나의 시작점을 만든다.
- **증상:** 작업 전환 전에 구현 파일이 변경되었다 → **원인:** architect에게 코드 수정을 허용했다 → **조치:** 변경을 되돌리고 `/agent architect`를 선택한 새 세션에서 이슈 산출물만 작성한다.

이슈 계층과 frontier 정의는 [GitHub Issue 운영 규칙](../reference/issue-conventions.md)을 따른다.
