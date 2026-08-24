# Lab 3 — 구현 (90분)

## 이 랩에서 배우는 것

결정 이슈에서 확정한 아키텍처를 작은 task 단위로 구현한다. failing test에서 시작하는 TDD, assignee 기반 claim, 이슈별 새 세션, 반복 가능한 검증과 커밋 규율을 연습한다.

## 하네스 / 모델

| 하네스 | 모델 |
|---|---|
| Copilot | GPT-5.6 Sol |

## 시작 전 상태

모든 decision issue가 닫혀 있고 구현 가능한 `wf:task` 이슈가 map에 연결되어 있다. `./scripts/frontier.sh <map>`은 담당자가 없고 열린 blocker가 없는 task를 최소 1개 출력하며, 구현 코드는 아직 해당 task의 acceptance criteria를 만족하지 않는다.

## 단계

1. 저장소 루트에서 map issue 번호를 복구하고 GPT-5.6 Sol을 지정한 **새 Copilot 세션**을 시작한다.

   ```bash
   cd /Users/andy/works/ai/multiharness-ghcp
   printf 'Map issue number: '
   read -r MAP_ISSUE
   export MAP_ISSUE
   copilot --model gpt-5.6-sol
   ```

2. implementer 프로파일을 선택한다.

   ```text
   /agent implementer
   ```

3. frontier에서 다음 이슈를 고르고, 프롬프트에 그 번호를 입력한 뒤 작업하기 전에 자신을 assignee로 지정해 claim한다.

   ```bash
   ./scripts/frontier.sh "$MAP_ISSUE"
   printf 'Task issue number: '
   read -r TASK_ISSUE
   export TASK_ISSUE
   gh issue edit "$TASK_ISSUE" --add-assignee "@me"
   gh issue view "$TASK_ISSUE"
   ```

   **이슈 하나 = 세션 하나**이며, 같은 세션에서 다른 task를 이어서 처리하지 않는다.

4. task의 acceptance criteria를 테스트로 먼저 작성한다. 구현을 바꾸기 전에 해당 테스트를 실행해 의도한 이유로 실패하는지 확인한다.

   ```text
   현재 task issue의 acceptance criteria를 기존 테스트 스타일에 맞는 failing test로 먼저 작성하세요. 구현 코드는 아직 바꾸지 마세요.
   ```

   ```bash
   cd seed && npm test && cd ..
   ```

5. 최소한의 구현으로 failing test를 통과시킨다. 확정된 decision issue의 범위를 벗어난 설계 선택이 필요하면 임의로 결정하지 말고 새 이슈에 기록한다.

   ```text
   방금 확인한 failing test를 통과시키는 최소 구현을 작성하세요. 기존 decision issue의 결정과 의존성 추가 금지 규칙을 지키세요.
   ```

6. 텔레메트리 옵트아웃 task에서는 `seed/tests/gate.test.ts`의 `known gap: telemetry is emitted even when the user opted out` 테스트를 반드시 뒤집는다. 테스트를 삭제하지 말고 opt-out이면 emit되지 않는다는 새 기대값으로 변경한다.

   ```bash
   grep -nF "known gap: telemetry is emitted even when the user opted out" seed/tests/gate.test.ts
   ```

   이 연습은 기존 테스트를 삭제하지 말라는 절대 규칙 2를 실천하는 핵심 구간이다. 커밋 메시지 본문에 기대값을 뒤집은 이유를 적는다.

7. 지역 라우팅 task에서도 같은 방법을 적용한다. `seed/tests/router.test.ts`의 sibling test인 `known gap: the region is not consulted when routing`을 삭제하지 말고 지역 정책을 반영한 기대값으로 뒤집는다.

   ```bash
   grep -nF "known gap: the region is not consulted when routing" seed/tests/router.test.ts
   ```

8. 각 task 구현 후 전체 테스트와 저장소 gate를 모두 실행한다.

   ```bash
   cd seed && npm test && cd ..
   ./scripts/check-repo.sh
   ```

9. 변경 범위를 확인하고 현재 task만 커밋한다. known-gap 기대값을 뒤집었다면 그 이유를 커밋 메시지 본문에 명시한다.

   ```bash
   git status --short
   git diff --check
   git add seed/src seed/tests
   git commit -m "feat: implement task acceptance criteria" -m "Flip the existing known-gap expectation because the accepted behavior now enforces the policy; the test is preserved rather than deleted."
   ```

10. 이슈에 검증 결과와 커밋을 남기고 닫는다.

    ```bash
    gh issue close "$TASK_ISSUE" --comment "Acceptance criteria를 구현했고 \`cd seed && npm test && cd ..\` 및 \`./scripts/check-repo.sh\`가 통과했습니다."
    ```

11. 다음 frontier를 확인한다. 새 task가 출력되면 현재 Copilot 세션을 종료하고 단계 1부터 **NEW session**으로 반복한다.

    ```bash
    ./scripts/frontier.sh "$MAP_ISSUE"
    ```

## 끝난 뒤 상태

map 아래의 모든 `wf:task` 이슈가 task별 커밋과 검증 결과를 남긴 채 닫혀 있다. `cd seed && npm test && cd ..`와 `./scripts/check-repo.sh`가 통과하며, 지역별 정책에 따른 라우팅과 텔레메트리 opt-out이 모두 동작한다.

## 흔한 실패

- **증상:** 구현 직후 테스트는 통과하지만 TDD의 실패 증거가 없다 → **원인:** 구현과 테스트를 동시에 작성했거나 failing test 실행을 생략했다 → **조치:** 구현을 잠시 되돌리고 acceptance criteria 테스트만 실행해 의도한 실패를 먼저 확인한다.
- **증상:** known-gap 테스트가 사라졌다 → **원인:** 바뀐 동작과 충돌하는 기존 테스트를 삭제했다 → **조치:** Git에서 테스트를 복구하고 이름을 보존한 채 기대값만 새 동작으로 뒤집는다.
- **증상:** 두 task의 변경이 한 커밋과 한 대화에 섞였다 → **원인:** “이슈 하나 = 세션 하나” 규칙을 지키지 않았다 → **조치:** 변경을 task별 커밋으로 분리하고 다음 task는 새 Copilot 세션에서 claim한다.
- **증상:** `frontier.sh`에 task가 보이지만 다른 작업과 충돌한다 → **원인:** 구현 전에 자신을 assignee로 지정하지 않았다 → **조치:** 작업 시작 전 `gh issue edit <issue> --add-assignee "@me"`로 claim하고 담당자가 있는 이슈는 건드리지 않는다.
- **증상:** `check-repo.sh`가 의존성 또는 금지 패턴 오류를 보고한다 → **원인:** task 범위를 넘어 manifest를 바꾸었거나 저장소 규칙을 위반했다 → **조치:** 불필요한 변경을 되돌리고 두 검증 명령이 모두 통과할 때까지 커밋하지 않는다.

하네스 전환 시 유지해야 할 상태와 브리프 형식은 [하네스 간 인계 계약](../reference/handoff-contract.md)을 따른다.
