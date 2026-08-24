# 코어 랩 최소 경로와 복구 체크포인트

핵심 흐름이 지연될 때 범위를 줄이는 강사용 기준이다. 답을 바로 제공하지 않고, 정해진 cutover 시각에만 사용한다.

## Lab 1 체크포인트

최소 결정 질문은 세 개다.

1. 어느 지역에서 cloud inference를 금지하는가?
2. 제한 지역에서 on-device 실행이 불가능하면 blocked와 cloud 중 무엇을 선택하는가?
3. telemetry opt-out은 이벤트 생성과 어떤 관계인가?

30분 시점에 질문이 없으면 이 세 질문을 제공하되 답은 제공하지 않는다. 종료 시 `docs/spec.md`와 최소 세 개의 `wf:decision` Issue가 있어야 한다.

## Lab 2 체크포인트

최소 구현 경로는 두 task다.

1. 지역 정책과 라우팅: EU cloud 금지, incapable이면 blocked, KR cloud fallback 허용
2. telemetry opt-out: opt-out이면 event 0건, opt-in이면 event 1건

두 task는 독립적으로 시작 가능하게 두거나, 팀 설계상 공용 Policy가 먼저 필요하면 telemetry task만 Policy task에 block한다. 종료 시 `docs/plan.md`와 최소 한 개의 frontier가 있어야 한다.

## Lab 3 체크포인트

구현 종료 35분 전까지 첫 task가 green이 아니면 팀의 미완료 변경을 별도 branch에 보존하고 강사용 reference checkpoint를 적용한다.

```bash
git status --short
git switch -c recovery/team-work
git add seed docs/spec.md docs/plan.md
git commit -m "wip: preserve team work before recovery"
git switch main
WORKSHOP_CHECKPOINT_DIR=/secure/instructor/lab3-checkpoint \
  ./scripts/restore-lab3-checkpoint.sh --confirm
```

강사는 행사 전에 authoring checkout의 reference checkpoint를 강사 전용 외부 위치에 복사하고 participant bundle을 만든다. Git branch는 비밀 경계가 아니므로 participant 리포의 어떤 ref에도 정답을 push하지 않는다.

```bash
./scripts/build-participant-bundle.sh /tmp/workshop-participant.tar.gz --confirm
tar -tzf /tmp/workshop-participant.tar.gz |
  grep 'docs/instructor/reference-solution' && exit 1 || true
```

## Lab 4 진입 게이트

다음이 모두 없으면 Lab 4를 시작하지 않는다.

- 커밋된 `docs/spec.md`, `docs/plan.md`
- green 단위 테스트
- green 독립 acceptance test
- map Issue의 완전한 `## HANDOFF`

시간이 부족하면 Lab 5를 생략하고 Lab 4와 회고를 보존한다.
