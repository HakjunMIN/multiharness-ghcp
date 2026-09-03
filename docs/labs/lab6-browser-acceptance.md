# Lab 6 - 브라우저 인수 시나리오

## 이 랩에서 배우는 것

- frontend 구현 전에 실패하는 사용자 시나리오를 고정한다.
- deterministic Playwright와 gated live Playwright를 분리한다.
- prototype의 상태와 접근성 landmark를 browser contract로 옮긴다.

## Runtime card

```text
Host: VS Code
Recommended agent runtime: Copilot harness (New Chat → Session Target: Copilot)
Recommended model: GPT-5.6 Sol
Context: 브라우저 인수 시나리오 ticket 하나의 fresh session
```

## 시나리오 작성

```text
/implement docs/work/<feature>/tickets/<browser-acceptance-ticket>.md

production code는 수정하지 마세요. 실패하는 브라우저 시나리오만 남기고
통과시키려고 단언을 약하게 바꾸지 마세요.
```

`npm run test:e2e`는 `/healthz`와 `POST /api/consult`를 route interception으로
통제하며 외부 네트워크 없이 loading, answer, URL citations, no-evidence와
actionable 오류를 검증합니다. role, label과 Lab 2에서 정한 landmark를 사용합니다.

`npm run test:e2e:live`는 interception 없이 React → FastAPI → APIM → Foundry IQ
전체 흐름을 검증합니다. API와 web 서버가 모두 떠 있어야 하며 운영자가 승인한
gate 밖에서는 실행하지 않습니다. 두 suite 모두 trace, screenshot, video와
provider payload capture를 꺼 credential이 report에 남지 않게 합니다.

```bash
(cd app/web && npm test && npm run build)
(cd app/web && npm run test:e2e) || true
./scripts/check-repo.sh
```

## 종료 조건

- `test:e2e`와 `test:e2e:live` script가 분리되어 있다.
- deterministic Playwright가 다섯 UI 상태를 사용자 관점으로 덮는다.
- 실패 이유가 미구현 frontend라는 근거가 있다.
- production code를 수정하지 않고 시나리오와 `HANDOFF`를 커밋했다.

## 막힐 때

- 문구에 과도하게 묶이면 role, label과 landmark로 selector를 바꾼다.
- live gate가 없으면 suite를 삭제하지 말고 실행하지 않은 이유를 기록한다.
- screenshot 비교는 구현 랩의 책임이며 이 랩의 Playwright artifact로 남기지 않는다.
