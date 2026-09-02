# Lab 3 - tracer bullet 구현

## 이 랩에서 배우는 것

- ticket 하나를 fresh session에서 red-green으로 완결한다.
- React UI, API, Microsoft Agent Framework, Foundry IQ adapter, citations를 한 vertical slice로 연결한다.
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
```

경로를 frontier의 실제 local ticket으로 바꿉니다. recorded Foundry IQ
response를 사용하는 API test와 사용자의 질문부터 answer/citations 렌더링까지
검증하는 React test를 먼저 실패시킵니다. production code는 APIM adapter
경계를 통해 모델과 `knowledgebases/{name}/retrieve`를 호출합니다. key를 log,
exception, fixture에 남기지 않습니다.

첫 vertical slice는 React 질문 입력, loading, API 호출, answer와 structured
citations 렌더링까지 포함합니다. backend나 frontend만 완성한 상태는 이 랩의
완료가 아닙니다.

브라우저 검증은 Playwright로 추가하고 `app/web`에 다음 두 script를 남깁니다.
`test:e2e`는 route interception이나 verifier가 통제하는 test adapter를 사용해
네트워크 없이 실행하고, `test:e2e:live`는 실제 React → FastAPI → APIM →
Foundry IQ 상담 흐름만 검증합니다. live script는 `.env`가 준비된 명시적
Lab gate 밖에서 자동 실행되면 안 됩니다.

```bash
(cd app/api && uv run --frozen pytest -q)
(cd app/web && npm test && npm run build && npm run test:e2e)
./scripts/test-live.sh
./scripts/check-repo.sh
```

기본 suite는 네트워크 없이 통과해야 한다. live suite는 운영자 APIM을 통해
질문 하나와 citations를 확인한다. `npm run test:e2e:live`는 최종 독립 검증인
Lab 6에서 실행한다.

## 15분 인계

구현 commit 후 [handoff contract](../reference/handoff-contract.md)에 따라 루트 `HANDOFF`를 작성한다. 현재 ticket, commit, 결정, 남은 위험, 첫 `verify` 명령을 포함하고 commit한다.

## 종료 조건

- 질문 하나가 React UI에서 API와 Foundry IQ를 거쳐 answer와 citations로 표시된다.
- deterministic Playwright E2E와 gated live Playwright script가 분리되어 있다.
- focused RED와 GREEN, 기본 suite, live smoke 근거가 있다.
- 구현이 commit됐고 ticket 상태가 갱신됐다.
- 다음 세션이 실행할 `HANDOFF`가 commit됐다.

## 막힐 때

- live 응답이 흔들리면 recorded contract test를 먼저 green으로 만들고 401/404/429를 운영자에게 분류해 전달한다.
- no-evidence나 429 같은 추가 UI 상태는 후속 ticket으로 남긴다.
- APIM key가 출력되면 작업을 멈추고 운영자에게 rotation을 요청한다.
