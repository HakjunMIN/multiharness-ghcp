# Lab 6 - 상담 UX와 오류 상태 개선

## 이 랩에서 배우는 것

- 두 번째 ticket도 focused red-green으로 구현한다.
- no-evidence와 오류 동작을 React UI까지 연결한다.
- API 동작과 UI가 같은 HTTP contract를 사용하게 한다.

## Runtime card

```text
Host: VS Code
Recommended agent runtime: Copilot harness (New Chat → Session Target: Copilot)
Recommended model: GPT-5.6 Sol (chat 입력창의 language model picker)
Context: ticket 하나의 fresh session
```

Lab 4의 상담 흐름에 no-evidence behavior와 actionable한 error/429 UI를
추가합니다. answer와 structured citations가 함께 유지되는지도 검증합니다.

New Chat으로 fresh session을 엽니다. 권장 조합은 Session Target Copilot과
GPT-5.6 Sol입니다. 다른 조합을 사용하면 `HANDOFF`에 실제 host, harness, model,
skill을 기록합니다. 채팅에 다음을 입력합니다.

```text
/implement docs/work/<feature>/tickets/<behavior-or-ui-ticket>.md

no-evidence 동작과 actionable하고 secret-safe한 오류/429 UI를 API와 React
focused failing test로 먼저 실패시키고 최소 구현으로 green을 만드세요. Lab
3에서 실패한 채로 남겨 둔 no-evidence와 오류 브라우저 시나리오도 같은 구현으로
green이 되어야 하고 answer와 structured citations는 계속 통과해야 합니다. UI는
POST /api/consult 외에 별도 domain logic을 만들지 마세요. 새 화면을 추가하지
말고 기존 상담 화면의 상태 전환으로 처리하세요. 오류 문구에 APIM key, origin,
provider payload를 노출하지 마세요. 끝나면 구현 commit과 루트 HANDOFF를 남기고
실제로 사용한 host, harness, model, skill을 기록하세요.
```

API와 React focused failing test, 최소 구현, focused GREEN, 전체 suite 순서를
지킨다. 경로를 frontier의 실제 local ticket으로 바꾼다.

## 종료 조건

- no-evidence 또는 오류 상태 ticket 하나가 red-green 근거와 함께 commit됐다.
- React에서 질문, loading, answer, citations, no-evidence와 오류 상태를 검증했다.
- Lab 3에서 남겨 둔 no-evidence와 오류 시나리오가 `npm run test:e2e`에서
  green이 되고, deterministic suite 전체가 통과한다.
- API 기본 suite와 web test/build가 통과한다.

## 막힐 때

- 상태가 많아지면 새 화면을 추가하지 말고 기존 상담 화면의 상태 전환에 집중한다.
- live 429가 필요하면 운영자와 test window를 정하고 다른 참가자 key를 쓰지 않는다.
