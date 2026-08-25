# 진행 시간표

총 5시간 30분(점심 60분 포함)입니다. 스킬이 절차를 대신하므로 참가자가
직접 실행하는 셸 명령은 최소로 유지합니다.

| 모듈 | 시간 | 누적 | 잘라낼 수 있는가 |
| --- | ---: | ---: | --- |
| Lab 0 harness bootstrap | 30분 | 0:30 | 아니오 |
| Lab 1 discovery/architecture | 45분 | 1:15 | 아니오 |
| Lab 2 spec/tickets | 30분 | 1:45 | 20분으로 축소 가능 |
| 점심 | 60분 | 2:45 | — |
| Lab 3 implementation | 75분 | 4:00 | 아니오 |
| Lab 4 independent verification | 50분 | 4:50 | 아니오 |
| Lab 5 runtime comparison | 15분 | 5:05 | 예 — 첫 번째 절삭 대상 |
| Lab 6 integration/retrospective | 25분 | 5:30 | 15분으로 축소 가능 |

## 절삭 우선순위

**Lab 5 → Lab 6 축소 → Lab 2 축소.**

Lab 3과 Lab 4는 자르지 않습니다. 시간이 부족하면 ticket 수를 줄이되
구현 세션과 검증 세션의 새 세션 경계는 반드시 보존합니다.

## 시각별 개입 checkpoint

- **0:30** 필수 Matt 스킬이 `/skills`에 없거나 checker가 실패하면 설치 scope와
  entitlement를 강사가 직접 분리해 개입합니다.
- **1:15** `CONTEXT.md`와 ADR이 없으면 질문 범위를 Lab 1의 네 질문으로 줄입니다.
- **1:45** 시작 가능한 `ready-for-agent` ticket이 없으면 blocking edge를 정리하고
  ticket을 사용자 관점 동작으로 다시 자릅니다.
- **4:00** 닫힌 ticket이 하나도 없으면 범위를 한 ticket으로 고정합니다.
- **4:50** UAT 판정이 끝나지 않았으면 결함 수정을 멈추고 Issue 기록만 마칩니다.
- **5:30** PR과 팀 채택 규칙이 없으면 발표를 줄이고 기록을 먼저 끝냅니다.

코어 랩의 복구 기준은 `docs/instructor/minimum-path.md`를 따릅니다.
