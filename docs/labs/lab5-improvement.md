# Lab 5 - 상담 UX와 오류 상태 개선

## 이 랩에서 배우는 것

- 두 번째 ticket도 focused red-green으로 구현한다.
- no-evidence와 오류 동작을 React UI까지 연결한다.
- API 동작과 UI가 같은 HTTP contract를 사용하게 한다.

## Runtime card

```text
Host: VS Code
Agent runtime: Copilot harness (New Chat → Session Target: Copilot)
Model: GPT-5.6 Sol (chat 입력창의 language model picker)
Context: ticket 하나의 fresh session
```

Lab 3의 상담 흐름에 no-evidence behavior와 actionable한 error/429 UI를
추가합니다. answer와 structured citations가 함께 유지되는지도 검증합니다.

New Chat으로 fresh session을 열고 Session Target을 Copilot로, model picker에서
GPT-5.6 Sol을 선택한 뒤 채팅에 다음을 입력합니다.

```text
/implement docs/work/<feature>/tickets/<behavior-or-ui-ticket>.md
```

API와 React focused failing test, 최소 구현, focused GREEN, 전체 suite 순서를
지킨다. UI는 `POST /api/consult` 외에 별도 domain logic을 만들지 않는다.

## 종료 조건

- no-evidence 또는 오류 상태 ticket 하나가 red-green 근거와 함께 commit됐다.
- React에서 질문, loading, answer, citations, no-evidence와 오류 상태를 검증했다.
- API 기본 suite와 web test/build가 통과한다.

## 막힐 때

- 상태가 많아지면 새 화면을 추가하지 말고 기존 상담 화면의 상태 전환에 집중한다.
- live 429가 필요하면 운영자와 test window를 정하고 다른 참가자 key를 쓰지 않는다.
