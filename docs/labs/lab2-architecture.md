# Lab 2 — Spec과 tracer-bullet tickets (30분)

## 이 랩에서 배우는 것

- 합의된 설계를 실행 가능한 spec으로 고정한다.
- 새 세션 하나에 들어가는 좁은 tracer-bullet ticket으로 쪼갠다.
- layer별 horizontal 분해가 왜 인수인계를 깨뜨리는지 체감한다.
- 설계 대화를 종료해도 안전한 상태를 만든다.

## Runtime card

```text
Host: GitHub Copilot CLI
Agent runtime: Claude (/agent Claude)
Model: Claude Opus 5 (/model Claude Opus 5)
Context: Lab 1 대화를 그대로 사용
```

## 시작 전 상태

- Lab 1의 종료 조건을 만족했다.
- 같은 설계 대화가 아직 살아 있다.

## Spec

Lab 1 대화에서 실행합니다.

```text
/to-spec
```

Problem, solution, user stories, implementation decisions, testing decisions,
out of scope를 확인합니다. 특히 public test seam을 승인한 뒤 GitHub spec
Issue를 발행하고 `ready-for-agent`를 붙입니다.

## Tickets

```text
/to-tickets
```

각 ticket은 한 새 세션에 들어가는 좁고 완결된 tracer bullet이어야 합니다.
각 ticket에 사용자 관점 동작, 수락 기준, native blocking edges가 있어야
합니다. layer별 horizontal ticket은 거부합니다.

## 종료 조건

- GitHub에 승인된 spec Issue가 있다.
- 시작 가능한 `ready-for-agent` ticket이 하나 이상 있다.
- blocking edges가 실제 선행 조건만 나타낸다.
- 이제 설계 대화를 종료해도 모든 상태가 리포와 Issue에 남는다.

## 막힐 때

- ticket이 "모델 계층", "라우터 계층"처럼 나뉘면 사용자 관점 동작으로 다시 자른다.
- 모든 ticket이 서로를 막으면 blocking edge가 과하게 걸린 것이다.
- spec이 흔들리면 Lab 1로 돌아가고 코딩으로 추측하지 않는다.
