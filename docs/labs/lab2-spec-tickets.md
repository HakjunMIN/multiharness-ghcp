# Lab 2 - Spec과 ticket (45분)

## 이 랩에서 배우는 것

- 발견 결과를 검증 가능한 spec Issue로 발행한다.
- 한 세션에서 끝나는 vertical tracer-bullet ticket을 만든다.
- 실제 선행 조건만 blocking edge로 표현한다.

## Runtime card

```text
Host: GitHub Copilot
Agent runtime: Claude (/agent Claude)
Model: Claude Opus 5 (/model Claude Opus 5)
Context: Lab 1 대화를 그대로 사용
```

## Spec

```text
/to-spec
```

Problem, solution, user stories, HTTP contract, policy decisions, testing decisions, out of scope를 검토한다. 승인 후 GitHub spec Issue를 발행한다.

## Tickets

```text
/to-tickets
```

첫 ticket은 질문 하나가 `POST /api/consult`에서 시작해 Foundry IQ retrieve를 거쳐 answer와 구조화된 citations로 돌아오는 tracer bullet이어야 한다. model layer, search layer 같은 horizontal ticket은 거부한다. region policy, telemetry opt-out, no-evidence behavior, React UI는 후속 ticket으로 둔다.

각 ticket에 observable acceptance criteria, focused test, 전체 검증 명령, `ready-for-agent`, 실제 blocking edge를 기록한다.

## 종료 조건

- 승인된 spec Issue가 있다.
- 실행 가능한 tracer-bullet ticket이 `ready-for-agent` 상태다.
- acceptance criteria가 `POST /api/consult`로 관찰 가능하다.
- 설계 대화를 닫아도 필요한 상태가 Issue와 repo에 남는다.

## 막힐 때

- ticket이 계층 이름이면 사용자 질문 한 번의 흐름으로 다시 자른다.
- 모든 ticket이 막혀 있으면 edge를 제거하고 첫 vertical slice를 찾는다.
- spec이 흔들리면 Lab 1 결정으로 돌아가며 구현으로 추측하지 않는다.
