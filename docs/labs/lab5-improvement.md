# Lab 5 - 정책 개선과 full 확장 (75분)

## 이 랩에서 배우는 것

- 두 번째 ticket도 focused red-green으로 구현한다.
- core와 full을 별도 트랙이 아니라 누적 범위로 다룬다.
- policy와 UI가 같은 HTTP contract를 사용하게 한다.

## Runtime card

```text
Host: VS Code
Agent runtime: Copilot harness (New Chat → Session Target: Copilot)
Model: GPT-5.6 Sol (chat 입력창의 language model picker)
Context: ticket 하나의 fresh session
```

core는 regional trusted domains, telemetry opt-out, no-evidence behavior 중 하나를 vertical ticket으로 끝낸다. full은 core policy 하나를 먼저 끝낸 뒤 React chat, loading/error/429 상태, structured citation rendering을 추가한다.

New Chat으로 fresh session을 열고 Session Target을 Copilot로, model picker에서
GPT-5.6 Sol을 선택한 뒤 채팅에 다음을 입력합니다.

```text
/implement docs/work/<feature>/tickets/<policy-or-ui-ticket>.md
```

focused failing test, 최소 구현, focused GREEN, 전체 suite 순서를 지킨다. UI는 `POST /api/consult` 외에 별도 domain logic을 만들지 않는다.

## 종료 조건

- core policy ticket 하나가 red-green 근거와 함께 commit됐다.
- full 선택자는 core를 포함하고 React 상담 흐름까지 검증했다.
- API 기본 suite와 web test/build가 통과한다.

## 막힐 때

- full UI가 지연되면 core policy를 먼저 완결하고 UI 범위를 줄인다.
- live 429가 필요하면 강사와 test window를 정하고 다른 참가자 key를 쓰지 않는다.
