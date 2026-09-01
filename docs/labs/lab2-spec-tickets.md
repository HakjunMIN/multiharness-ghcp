# Lab 2 - Spec과 ticket (45분)

## 이 랩에서 배우는 것

- 발견 결과를 검증 가능한 local spec 문서로 발행한다.
- 채팅 문맥 없이 커밋된 discovery 문서만으로 기획을 이어간다.
- 한 세션에서 끝나는 vertical tracer-bullet ticket을 만든다.
- 실제 선행 조건만 blocking edge로 표현한다.

## Runtime card

```text
Host: VS Code
Agent runtime: Claude harness (New Chat → Session Target: Claude)
Model: Claude Opus 4.8 (chat 입력창의 language model picker)
Context: fresh session. Lab 1 대화를 물려받지 않고 커밋된 문서만 읽는다.
```

## Spec

New Chat으로 fresh session을 열고 Session Target을 Claude로, model picker에서
Claude Opus 4.8을 선택합니다. Lab 1 세션은 닫아 두고, 먼저 `AGENTS.md`,
`CONTEXT.md`, `docs/work/<feature>/discovery.md`와 연결된 ADR을 읽습니다.
이전 채팅 요약을 붙여넣지 않습니다.

```text
/to-spec
```

Problem, solution, user stories, HTTP contract, behavior decisions, testing
decisions, out of scope를 검토한 뒤 `docs/work/<feature>/spec.md`에 발행합니다.
discovery 문서에 없는 결정이 필요하면 추측하지 말고 Lab 1의 열린 질문으로
되돌립니다.

## Tickets

```text
/to-tickets
```

첫 ticket은 질문 하나가 `POST /api/consult`에서 시작해 Foundry IQ retrieve를
거쳐 answer와 구조화된 citations로 돌아오는 tracer bullet이어야 한다. model
layer, search layer 같은 horizontal ticket은 거부한다. no-evidence behavior,
429 handling, React UI는 후속 ticket으로 둔다.

각 ticket을 `docs/work/<feature>/tickets/` 아래의 개별 문서로 만들고 observable
acceptance criteria, focused test, 전체 검증 명령, `ready-for-agent`, 실제
blocking edge를 기록합니다.

## 종료 조건

- 승인된 local spec 문서가 있다.
- 실행 가능한 tracer-bullet ticket이 `ready-for-agent` 상태다.
- acceptance criteria가 `POST /api/consult`로 관찰 가능하다.
- 설계 대화를 닫아도 필요한 상태가 local work item과 repo에 남는다.

## 막힐 때

- ticket이 계층 이름이면 사용자 질문 한 번의 흐름으로 다시 자른다.
- 모든 ticket이 막혀 있으면 edge를 제거하고 첫 vertical slice를 찾는다.
- spec이 흔들리면 discovery 문서와 ADR로 돌아가며 구현으로 추측하지 않는다.
- discovery 문서가 부족해 spec을 못 쓰면 Lab 1로 되돌아가 문서를 보강한다.
  이것이 durable artifact 품질에 대한 피드백이다.
