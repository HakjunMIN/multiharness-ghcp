# Lab 4 - tracer bullet 구현

## 이 랩에서 배우는 것

- ticket 하나를 fresh session에서 red-green으로 완결한다.
- React UI, API, Microsoft Agent Framework, Foundry IQ adapter, citations를 한 vertical slice로 연결한다.
- Lab 3의 실패 시나리오 하나를 실제 구현으로 green으로 만든다.
- live smoke와 deterministic test를 분리한다.

## Runtime card

```text
Host: VS Code
Recommended agent runtime: Copilot harness (New Chat → Session Target: Copilot)
Recommended model: GPT-5.6 Sol (chat 입력창의 language model picker)
Context: ticket마다 fresh session
```

## 구현

New Chat으로 fresh session을 엽니다. 권장 조합은 Session Target Copilot과
GPT-5.6 Sol입니다. 다른 조합을 사용하면 `HANDOFF`에 실제 host, harness, model,
skill을 기록합니다. 채팅에 다음을 입력합니다.

```text
/implement docs/work/<feature>/tickets/01-<ticket>.md

recorded Foundry IQ response를 사용하는 API test와 사용자의 질문부터
answer/citations 렌더링까지 검증하는 React test를 먼저 실패시키고 최소
구현으로 green을 만드세요. Lab 3에서 만든 tracer bullet 브라우저 시나리오도
같은 구현으로 green이 되어야 합니다. production code는 APIM adapter 경계를
통해서만 모델과 knowledgebases/{name}/retrieve를 호출하세요. key를 log,
exception, fixture, commit에 남기지 마세요. 새 E2E suite를 늘리지 말고
no-evidence와 오류 시나리오는 실패한 채로 두세요. 끝나면 구현 commit과 루트
HANDOFF를 남기고 실제로 사용한 host, harness, model, skill을 기록하세요.
```

경로를 frontier의 실제 local ticket으로 바꿉니다. 이 랩의 red-green은 API와
React 양쪽에서 동시에 성립해야 합니다. backend나 frontend만 완성한 상태는 이
랩의 완료가 아닙니다.

첫 vertical slice는 React 질문 입력, loading, API 호출, answer와 structured
citations 렌더링까지 포함합니다.

브라우저 검증은 Lab 3에서 만든 실패 시나리오로 판정합니다. 이 랩에서는 새
suite를 늘리지 않고 tracer bullet에 해당하는 deterministic 시나리오 하나를
green으로 만듭니다. no-evidence와 오류 시나리오는 실패한 채로 두고 Lab 6에서
갚습니다. `test:e2e`와 `test:e2e:live`의 분리와 gate 조건은 Lab 3에서 정한
그대로 유지하고, live script를 이 랩에서 자동 실행하지 않습니다.

```bash
(cd app/api && uv run --frozen pytest -q)
(cd app/web && npm test && npm run build && npm run test:e2e)
./scripts/test-live.sh
./scripts/check-repo.sh
```

기본 suite는 네트워크 없이 통과해야 한다. live suite는 운영자 APIM을 통해
질문 하나와 citations를 확인한다. `npm run test:e2e:live`는 최종 독립 검증인
Lab 7에서 실행한다.

## 15분 인계

구현 commit 후 [handoff contract](../reference/handoff-contract.md)에 따라 루트 `HANDOFF`를 작성한다. 현재 ticket, commit, 결정, 남은 위험, 첫 `verify` 명령을 포함하고 commit한다.

## 종료 조건

- 질문 하나가 React UI에서 API와 Foundry IQ를 거쳐 answer와 citations로 표시된다.
- Lab 3의 tracer bullet 시나리오가 `npm run test:e2e`에서 green이 된다.
- deterministic Playwright E2E와 gated live Playwright script가 분리되어 있다.
- focused RED와 GREEN, 기본 suite, live smoke 근거가 있다.
- 구현이 commit됐고 ticket 상태가 갱신됐다.
- 다음 세션이 실행할 `HANDOFF`가 commit됐다.

## 막힐 때

- live 응답이 흔들리면 recorded contract test를 먼저 green으로 만들고 401/404/429를 운영자에게 분류해 전달한다.
- no-evidence나 429 같은 추가 UI 상태는 후속 ticket으로 남긴다.
- APIM key가 출력되면 작업을 멈추고 운영자에게 rotation을 요청한다.
