# Lab 6 — 통합과 회고 (25분)

## 이 랩에서 배우는 것

- spec·tickets·검증 기록이 연결된 PR로 작업을 닫는다.
- 결함을 검증자가 고치지 않고 구현 흐름으로 되돌린다.
- 팀이 실제로 채택할 규칙만 골라 남긴다.

## 시작 전 상태

Lab 4의 review와 UAT report가 존재한다.

## 통합

구현 브랜치를 push하고 PR을 만듭니다. Sonnet 검증의 결함 Issue가 있으면
새 `ready-for-agent` ticket으로 되돌리고, 구현 세션과 검증 세션의
독립성을 유지합니다.

PR에는 spec Issue, 완료 tickets, UAT report를 연결합니다. merge할 때는
체크포인트 커밋을 **squash merge**해 main history를 간결하게 유지합니다.

## 회고

1. 어느 단계에서 가장 많은 재작업이 생겼는가?
2. 어떤 durable artifact가 실제로 세션을 구했는가?
3. 우리 팀에서 다음 주에 바로 적용할 규칙 하나는 무엇인가?

마지막으로 팀이 재사용할 규칙을 `docs/templates/team-adoption.md`에
기록합니다.

## 종료 조건

- spec·tickets·UAT report가 연결된 PR이 열렸다.
- 남은 결함이 ticket으로 되돌아갔다.
- 팀 채택 규칙이 기록됐다.

## 막힐 때

시간이 부족하면 발표를 줄이고 PR 링크와 채택 규칙 기록을 먼저 끝낸다.
