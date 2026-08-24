# 강사 진행 노트

## 반드시 지킬 개입 원칙

- **Lab 1에서 정답을 말하지 않는다.** 부채 발견이 학습의 절반이다. 참가자가 탐색하게 두되 **30분 룰**만 지킨다. 30분이 지나도 결정 질문을 만들지 못하면 답을 주는 대신 관찰 범위를 좁혀 준다.
- **Lab 3~4 사이에 반드시 세션을 끊게 한다.** 이 워크샵의 유일한 핵심 체험이다. 같은 세션에서 검증하면 아무것도 배우지 못한다. 터미널과 partner harness session이 실제로 종료됐는지 확인한 뒤 verifier를 시작시킨다.
- 인수인계 브리프가 부실한 조를 일부러 통과시켜 Lab 4에서 막히게 한다. 구두로 빈칸을 메워 주지 말고, 막힌 field를 적게 한 뒤 Lab 6 회고에서 다룬다.

## 도구 장애 시 fallback

- partner harness가 동작하지 않으면 전원이 **경로 B**, 즉 Copilot + `GPT-5.6 Terra`의 새 session으로 전환한다.
- cloud sandbox 또는 cloud agent가 동작하지 않으면 Lab 5를 생략하고 Lab 6으로 이동한다.
- `gh`가 동작하지 않으면 Issue 대신 `docs/` 아래 파일로 인계한다. 저장 위치만 달라질 뿐 `## HANDOFF` field, decision/task/verify 구분, claim, 재현 명령 규약은 동일하게 유지한다. 이 제약 자체가 durable state와 protocol의 가치를 보여 주는 좋은 교보재다.

## 압축 demo script

워크샵 시작 15분에 강사가 Lab 1~2 흐름을 짧게 시연한다. 시연 대상은 `seed/src/router.ts`의 `region` 미사용 결함 **하나만**이다.

1. 과제를 읽고 구현을 제안하지 않은 채 `region`이 routing decision에 쓰이는지 관찰한다.
2. “어느 region이 cloud inference를 허용하는가?”를 단일 `wf:decision` 질문으로 만든다.
3. 결정의 선택지와 trade-off를 map Issue의 결정 지형에 연결한다.
4. 결정이 닫혔다고 가정하고, acceptance criterion이 있는 `wf:task`로 변환한다.
5. `./scripts/frontier.sh <map-issue-number>`가 해당 task를 시작 가능 상태로 보여 주는 지점에서 멈춘다.

시연 중 policy 정답, telemetry opt-out 해법, 구체적 code structure는 공개하지 않는다. 목표는 답이 아니라 **발견 → 결정 → 작업 가능 frontier**의 흐름을 보여 주는 것이다.
