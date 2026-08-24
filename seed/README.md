# feature-gate (워크샵 시드 코드베이스)

## 무엇을 하는 코드인가

모바일 단말에서 AI 기능 요청이 들어왔을 때, 그 추론을 **단말에서 수행할지(on-device)**, **클라우드로 보낼지(cloud)**, **아예 막을지(blocked)** 결정하는 작은 SDK입니다. 의존성이 하나도 없으며 Node.js 22.18 이상의 네이티브 타입 스트리핑으로 TypeScript를 그대로 실행합니다.

## 실행

```bash
npm test          # 의존성 설치 불필요. npm install 을 하지 마세요.
```

## 공개 API

| 심볼 | 위치 | 역할 |
| --- | --- | --- |
| `route(caps, ctx)` | `src/gate.ts` | 공개 진입점. 라우팅을 결정하고 텔레메트리를 발생시킵니다. |
| `decideRoute(caps, ctx)` | `src/router.ts` | 순수한 라우팅 결정 로직. |
| `probeDevice(overrides?)` | `src/device.ts` | 단말 능력값을 반환합니다. 워크샵용 스텁이며 실제 하드웨어를 조회하지 않습니다. |
| `emit(name, props)` / `drain()` | `src/telemetry.ts` | 텔레메트리 버퍼. |

핵심 타입은 `src/types.ts`에 있습니다: `DeviceCapabilities`, `RequestContext`, `RouteDecision`, `InferenceTarget`.

## 알려진 설계 부채

이 코드는 **의도적으로** 다음 상태로 놓여 있습니다. 해결책은 여기 적지 않습니다 — Lab 1에서 직접 찾아내는 것이 학습의 절반입니다.

- `RequestContext.region`은 타입에 존재하지만 라우팅 결정에 전혀 쓰이지 않습니다.
- `decideRoute`는 중첩 조건문 하나로 된 단일 함수이며, 단말 능력 판정과 정책 판정이 한 덩어리에 섞여 있습니다.
- RAM · 배터리 · 페이로드 임계값이 함수 본문에 숫자 그대로 박혀 있습니다.
- `RouteDecision.reason`은 자유 문자열입니다. 열거된 값이 아니므로 호출자가 안정적으로 분기하거나 단언하기 어렵습니다.
- `route()`는 `RequestContext.userOptedOutTelemetry`를 확인하지 않으며, 텔레메트리에 `region`을 실어 보냅니다.

`tests/`에는 위 상태를 **현재 동작 그대로 고정한** 테스트가 두 개 있습니다. 이름이 `known gap:` 으로 시작합니다. 동작을 바꾸면 이 테스트를 지우지 말고 기대값을 뒤집은 뒤, 그 이유를 커밋 메시지에 적으세요.

## 워크샵 과제

> 지역별 프라이버시 규제에 따라 추론 라우팅을 강제하고, 텔레메트리 옵트아웃을 지원하라.

이 한 문장이 Lab 1의 요구 정의부터 Lab 4의 수락 테스트까지 하루 전체를 관통합니다.
