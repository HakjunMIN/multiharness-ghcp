# Lab 4 - API 인수 시나리오

## 이 랩에서 배우는 것

- backend 구현 전에 실패하는 HTTP contract를 고정한다.
- network-free 통합 테스트와 실제 APIM e2e gate를 분리한다.
- 실패 이유가 시나리오 오류인지 미구현 동작인지 판정한다.

## Runtime card

```text
Host: VS Code
Recommended agent runtime: Copilot harness (New Chat → Session Target: Copilot)
Recommended model: GPT-5.6 Sol
Context: API 인수 시나리오 ticket 하나의 fresh session
```

## 시나리오 작성

```text
/implement docs/work/<feature>/tickets/<api-acceptance-ticket>.md

production code는 수정하지 마세요. 실패하는 API 시나리오만 남기고 단언을
약하게 바꾸지 마세요.
```

FastAPI `TestClient`로 APIM adapter만 stub하여 질문부터 answer와 URL을 가진
structured citations까지 in-process 전체 흐름을 검증합니다. no-evidence와
secret-safe 오류 envelope도 기록합니다. 기본 테스트는 외부 네트워크를 쓰지
않습니다.

별도의 `pytest.mark.e2e` 시나리오는 실제 APIM과 Foundry IQ를 호출합니다.
질문은 하드코딩하지 말고 `.env`의 `LIVE_SMOKE_QUESTION`을 읽어 사용합니다.
값이 없으면 시나리오를 통과시키지 말고 실패시킵니다. 실제 질문 문구와 응답
원문은 fixture나 로그에 남기지 않습니다.
명시적인 `pytest -m e2e` 실행에 credential이 없으면 조용히 skip하거나
통과하지 않고 실패해야 합니다. 이 suite는 운영자가 gate를 승인하기 전에는
실행하지 않습니다.

Python `uv run --frozen pytest -m e2e -q`는 실제 APIM을 호출합니다. Lab 6의
JavaScript `npm run test:browser`는 route interception을 사용하는 network-free
브라우저 suite이며 이름을 분리해 두었습니다.

```bash
(cd app/api && uv run --frozen pytest -q) || true
./scripts/check-repo.sh
```

## 종료 조건

- TestClient 통합 시나리오가 answer, citations, no-evidence, 오류를 덮는다.
- 실제 APIM용 `e2e` 시나리오가 기본 suite에서 제외되고 `LIVE_SMOKE_QUESTION`을 사용한다.
- 현재 실패가 미구현 동작 때문이라는 재현 근거가 있다.
- production code를 수정하지 않고 시나리오와 `HANDOFF`를 커밋했다.

## 막힐 때

- adapter보다 더 안쪽을 mock하고 싶으면 멈추고 HTTP 관찰 경계로 돌아간다.
- credential이 없으면 e2e 단언을 지우지 말고 운영자 gate를 기다린다.
- provider payload와 질문·답변 원문을 fixture나 로그에 남기지 않는다.
