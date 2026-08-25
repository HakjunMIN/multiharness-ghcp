# Lab 2 — Spec과 tracer-bullet tickets (45분)

## Runtime card

```text
Host: GitHub Copilot CLI
Agent runtime: Claude (/agent Claude)
Model: Claude Opus 5 (/model Claude Opus 5)
Context: Lab 1 대화를 그대로 사용
```

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
