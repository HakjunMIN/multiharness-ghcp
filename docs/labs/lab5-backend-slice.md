# Lab 5 - Backend 상담 slice

## 이 랩에서 배우는 것

- 실패하는 API 인수 시나리오를 backend 구현으로 green으로 만든다.
- Microsoft Agent Framework와 Foundry IQ를 APIM adapter 경계로 연결한다.
- backend 완료를 HTTP contract로 판정하고 frontend와 분리해 인계한다.

## Runtime card

```text
Host: VS Code
Recommended agent runtime: Copilot harness (New Chat → Session Target: Copilot)
Recommended model: GPT-5.6 Sol
Context: backend ticket 하나의 fresh session
```

## 구현

`HANDOFF`의 verify를 먼저 실행한 뒤 다음을 사용합니다.

```text
/implement docs/work/<feature>/tickets/<backend-ticket>.md
```

Lab 4의 focused RED를 확인하고 최소 구현으로 green을 만듭니다. production
runtime은 `APIM_BASE_URL`과 `APIM_KEY`만 사용하며 별도 model endpoint나 model
ID 설정을 추가하지 않습니다. Foundry IQ retrieval, Microsoft Agent Framework
synthesis, answer, structured citations, no-evidence와 secret-safe 오류를 고정
`POST /api/consult` contract로 제공합니다.

```bash
(cd app/api && uv run --frozen pytest -q)
./scripts/check-repo.sh
```

기본 suite는 네트워크 없이 통과해야 합니다. 운영자가 승인한 gate에서만 다음을
실행합니다.

```bash
./scripts/test-e2e.sh
```

production code, tests, ticket 상태를 하나의 구현 commit으로 남긴 뒤 구현 SHA를
가리키는 7개 필드의 루트 `HANDOFF`를 별도 documentation commit으로 남깁니다.

## 종료 조건

- `POST /api/consult`가 answer와 structured citations를 반환한다.
- Lab 4의 network-free 통합 시나리오가 모두 green이다.
- 기본 suite가 APIM 없이 통과하고 gated e2e 결과가 별도로 기록됐다.
- backend 구현 commit과 별도 `HANDOFF` commit이 있다.

## 막힐 때

- live 응답이 흔들리면 TestClient 통합 suite를 먼저 green으로 유지한다.
- 401, 404, 429는 key나 provider payload 없이 route와 status만 기록한다.
- frontend를 함께 구현하지 않는다. Lab 7이 HTTP contract를 소비한다.
