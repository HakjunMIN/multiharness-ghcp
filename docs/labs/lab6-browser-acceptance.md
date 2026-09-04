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

## 준비된 runway

Playwright는 이미 `app/web`에 설치되어 있고 Lab 0의 preflight가 Chromium
바이너리까지 확인합니다. 새로 설치하지 말고 아래 구조를 그대로 씁니다.

| 자산 | 역할 |
| --- | --- |
| `app/web/playwright.config.ts` | `deterministic`과 `live` 두 project. trace, screenshot, video는 꺼져 있다 |
| `app/web/e2e/deterministic/` | `npm run test:browser`가 실행하는 network-free suite |
| `app/web/e2e/live/` | `npm run test:browser:live`가 실행하는 운영자 gate suite |

두 디렉터리의 `runway-*.spec.ts`는 runway가 동작하는지만 확인하는 예제입니다.
이 랩에서 실제 인수 시나리오로 **교체**하세요.

## 시나리오 작성

```text
/implement docs/work/<feature>/tickets/<browser-acceptance-ticket>.md

production code는 수정하지 마세요. 실패하는 브라우저 시나리오만 남기고
통과시키려고 단언을 약하게 바꾸지 마세요.
```

`npm run test:browser`는 `/healthz`와 `POST /api/consult`를 route interception으로
통제하며 외부 네트워크 없이 loading, answer, URL citations, no-evidence와
actionable 오류를 검증합니다. role, label과 Lab 2에서 정한 landmark를 사용합니다.

`npm run test:browser:live`는 interception 없이 React → FastAPI → APIM → Foundry IQ
전체 흐름을 검증합니다. `./scripts/dev.sh`로 API와 web이 모두 떠 있어야 하고
`WORKSHOP_LIVE_GATE=1`이 있을 때만 실행되며, 그 밖에서는 skip됩니다. 두 suite
모두 trace, screenshot, video와 provider payload capture를 꺼 credential이
report에 남지 않게 합니다.

```bash
(cd app/web && npm test && npm run build)
(cd app/web && npm run test:browser) || true
./scripts/check-repo.sh
```

두 번째 명령의 기대 결과는 **red**입니다. frontend가 아직 없으므로 실패해야
정상이고, 실패 이유가 미구현이라는 근거를 `HANDOFF`의 `verify`에 적습니다.

## 종료 조건

- `test:browser`와 `test:browser:live` script가 분리되어 있다.
- deterministic Playwright가 다섯 UI 상태를 사용자 관점으로 덮는다.
- 예제 `runway-*.spec.ts`를 실제 시나리오로 교체했다.
- 실패 이유가 미구현 frontend라는 근거가 있다.
- production code를 수정하지 않고 시나리오와 `HANDOFF`를 커밋했다.

## 막힐 때

- 문구에 과도하게 묶이면 role, label과 landmark로 selector를 바꾼다.
- live gate가 없으면 suite를 삭제하지 말고 실행하지 않은 이유를 기록한다.
- screenshot 비교는 구현 랩의 책임이며 이 랩의 Playwright artifact로 남기지 않는다.
- 한글 서체가 기본 sans-serif로 보이면 [문제 해결](../setup/troubleshooting.md)의
  서체 항목을 확인한다. 서체는 인수 기준이 아니다.
