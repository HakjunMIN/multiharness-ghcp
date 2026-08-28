# Lab 2 - Spec과 ticket (45분)

## 이 랩에서 배우는 것

- 발견 결과를 검증 가능한 local spec 문서로 발행한다.
- 한 세션에서 끝나는 vertical tracer-bullet ticket을 만든다.
- 실제 선행 조건만 blocking edge로 표현한다.

## Runtime card

```text
Host: VS Code
Agent runtime: Claude harness (기존 Lab 1 세션 → Session Target: Claude로 handoff)
Model: Claude Opus 4.8 (chat 입력창의 language model picker)
Context: Lab 1 세션을 Claude로 handoff
```

## Spec

```text
/to-spec
```

Lab 1 세션의 Session Target을 Claude로 바꿔 handoff하고 model picker에서
Claude Opus 4.8을 선택합니다. Problem, solution, user stories, HTTP contract,
policy decisions, testing decisions, out of scope를 검토한 뒤
`docs/work/<feature>/spec.md`에 발행합니다.

## Tickets

```text
/to-tickets
```

첫 ticket은 질문 하나가 `POST /api/consult`에서 시작해 Foundry IQ retrieve를 거쳐 answer와 구조화된 citations로 돌아오는 tracer bullet이어야 한다. model layer, search layer 같은 horizontal ticket은 거부한다. region policy, telemetry opt-out, no-evidence behavior, React UI는 후속 ticket으로 둔다.

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
- spec이 흔들리면 Lab 1 결정으로 돌아가며 구현으로 추측하지 않는다.
