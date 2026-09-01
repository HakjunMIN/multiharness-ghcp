# 진행 시간표

각 날짜는 점심 60분을 포함해 정확히 330분입니다.

| 일차 | 모듈 | 시간 | 누적 |
| --- | --- | ---: | ---: |
| 1 | Lab 0 runway preflight | 30분 | 0:30 |
| 1 | Lab 1 discovery | 60분 | 1:30 |
| 1 | Lab 2 spec/tickets | 45분 | 2:15 |
| 1 | 점심 | 60분 | 3:15 |
| 1 | Lab 3 tracer bullet | 90분 | 4:45 |
| 1 | HANDOFF 작성 | 15분 | 5:00 |
| 1 | 여유 | 30분 | 5:30 |
| 1일차 합계 | 330분 |
| 2 | Lab 4 cold-start | 30분 | 0:30 |
| 2 | Lab 5 improvement | 75분 | 1:45 |
| 2 | 점심 | 60분 | 2:45 |
| 2 | Lab 6 independent verification | 60분 | 3:45 |
| 2 | Lab 7 runtime comparison | 30분 | 4:15 |
| 2 | Lab 8 integration | 45분 | 5:00 |
| 2 | 여유 | 30분 | 5:30 |
| 2일차 합계 | 330분 |

## 절삭 우선순위

**Lab 7 생략 -> Lab 8 발표/회고 축소 -> Lab 5의 full UI 확장 축소.**

Lab 3 vertical slice, Lab 4 cold-start, Lab 6 independent verification은 자르지 않습니다. ticket 수를 줄여도 세 세션 경계와 evidence는 보존합니다.

## 개입 checkpoint

- Day 1 0:30: health/test/build 또는 필수 runtime이 없으면 진행하지 않는다.
- Day 1 1:30: `CONTEXT.md`와 ADR이 없으면 질문을 HTTP/evidence/test 경계로 줄인다.
- Day 1 2:15: ready tracer ticket이 없으면 horizontal decomposition을 되돌린다.
- Day 1 4:45: vertical commit이 없으면 범위를 질문 하나로 고정한다.
- Day 2 0:20: durable state로 복구하지 못하면 checkpoint를 사용하고 누락 artifact를 기록한다.
- Day 2 3:45: UAT가 끝나지 않으면 수정 대신 local defect 문서까지 완료한다.
