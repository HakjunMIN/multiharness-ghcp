# 진행 시간표

| 모듈 | 시간 | 누적 | 잘라낼 수 있는가 |
|---|---:|---:|---|
| Lab 0 프리플라이트 | 30분 | 0:30 | 아니오 |
| Lab 1 발견 | 60분 | 1:30 | 아니오 |
| Lab 2 아키텍처 | 45분 | 2:15 | 30분으로 축소 가능 |
| 점심 | 60분 | 3:15 | — |
| Lab 3 구현 | 90분 | 4:45 | 아니오 |
| Lab 4 검증 | 60분 | 5:45 | 아니오 |
| Lab 5 멀티런타임 | 45분 | 6:30 | 예 — 첫 번째 절삭 대상 |
| Lab 6 통합·회고 | 40분 | 7:10 | 25분으로 축소 가능 |

## 절삭 우선순위

**Lab 5 → Lab 2 축소 → Lab 6 축소.**

Lab 3과 Lab 4는 절대 자르지 않는다. 둘 중 하나라도 없으면 이 워크샵의 실제 주제인 **인수인계**가 존재하지 않는다. 지연이 발생해도 구현 세션과 새 검증 세션 사이의 단절은 보존한다.

## 시각별 개입 checkpoint

- **Lab 0, 0:30:** `./scripts/preflight.sh`가 fail 0이고 label 11개가 생성된 상태가 아니면 인증·권한 문제를 강사가 직접 분리해 개입한다.
- **Lab 1, 1:30:** map Issue 1개, `wf:decision` 자식 Issue 3개 이상, `## HANDOFF` 코멘트가 없으면 질문 범위를 세 가지 핵심 결정으로 줄인다.
- **Lab 2, 2:15:** `./scripts/frontier.sh <map-issue-number>`가 시작 가능한 `wf:task`를 1개 이상 출력하지 않으면 열린 결정을 닫고 dependency 연결을 바로잡는다.
- **Lab 3, 4:45:** 모든 `wf:task`가 닫히고 `npm test`가 green이며 지역 routing과 telemetry opt-out이 동작하지 않으면 미완료 범위를 Issue에 명시하고 핵심 acceptance path부터 완성하게 한다.
- **Lab 4, 5:45:** 새 session의 verifier가 모든 acceptance criterion을 판정하고 실패마다 `wf:verify` Issue를 만들지 못했으면 구현 파일을 닫고 decision/task Issue부터 다시 읽게 한다.
- **Lab 5, 6:30:** 세 runtime의 관찰 결과가 정리되지 않았으면 즉시 실습을 중단하고 Lab 6으로 이동한다.
- **Lab 6, 7:10:** map의 `## Decisions so far`와 세 회고 질문의 다음 행동이 기록되지 않았으면 발표를 줄이고 Issue 기록을 먼저 끝낸다.
