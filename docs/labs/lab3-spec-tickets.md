# Lab 3 - Spec과 tickets

## 이 랩에서 배우는 것

- discovery와 선택된 prototype을 검증 가능한 spec으로 발행한다.
- backend와 frontend를 HTTP contract로 연결된 두 vertical slice로 자른다.
- 실제 선행 조건만 ticket의 blocking edge로 표현한다.

## Runtime card

```text
Host: VS Code
Recommended agent runtime: Claude harness (New Chat → Session Target: Claude)
Recommended model: Claude Opus 4.8
Context: fresh session. Lab 1~2 대화가 아니라 커밋된 artifact만 읽는다.
```

## Spec

먼저 `AGENTS.md`, `CONTEXT.md`, `discovery.md`, `prototype.md`,
`docs/work/<feature>/prototype/`와 연결된 ADR을 읽습니다.

```text
/to-spec

커밋된 결정만 사용해 docs/work/<feature>/spec.md를 발행하세요.
문서에 없는 결정은 추측하지 말고 열린 질문으로 구분하세요.
```

spec은 `POST /api/consult` envelope, evidence와 no-evidence behavior, 선택된 UI
상태와 token, network-free 통합 테스트, gated API e2e, deterministic/live
브라우저 e2e 경계를 포함합니다.

## Tickets

```text
/to-tickets docs/work/<feature>/spec.md

contract-first 2단 vertical로 ticket을 만드세요. API 인수 시나리오, backend,
브라우저 인수 시나리오, frontend 통합 순서이며 UX/오류 개선은 후속 ticket입니다.
```

- API 인수 시나리오 ticket은 production code를 수정하지 않고 실패하는
  TestClient 시나리오와 gated API e2e 시나리오를 남깁니다.
- backend ticket은 `POST /api/consult`의 answer와 structured citations가 HTTP로
  관찰되는 지점까지 자릅니다.
- 브라우저 인수 시나리오 ticket은 production code를 수정하지 않고 실패하는
  Playwright 시나리오를 남깁니다.
- React frontend ticket은 backend ticket을 blocker로 두고 질문부터 화면 렌더링과
  prototype 시각 일치까지 자릅니다.
- model, search, component layer 같은 horizontal ticket은 거부합니다.

각 문서는 `docs/work/<feature>/tickets/` 아래 하나씩 두고 `What to build`,
`Blocked by`, `Status: ready-for-agent`, 체크박스 acceptance criteria, focused
test와 전체 검증 명령을 포함합니다.

## 종료 조건

- 승인된 spec이 discovery와 prototype 결정을 빠짐없이 반영한다.
- API 인수 → backend → 브라우저 인수 → frontend의 dependency가 명시됐다.
- 첫 frontier ticket이 `ready-for-agent`이고 HTTP로 관찰 가능하다.
- 구현을 막는 열린 질문이 없다.

## 막힐 때

- ticket 이름이 계층 이름이면 HTTP 또는 브라우저에서 관찰되는 결과로 다시 자른다.
- prototype 결정이 불명확하면 구현으로 추측하지 말고 Lab 2 artifact를 보강한다.
- 모든 ticket이 막혀 있으면 실제 blocker만 남기고 첫 frontier를 복구한다.
