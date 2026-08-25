# 독립 UAT 보고서

## 검증 조합

- 하네스:
- 모델:
- source branch:
- source commit:
- 구현과 달라진 축:
- 새 세션 확인:

## 기준과 결과

| ID | 수락 기준 | 명령 | 기대 결과 | 실제 결과 | 판정 |
|---|---|---|---|---|---|
| UAT-01 | EU capable request | acceptance test | on-device | 실행 출력 기록 | PASS 또는 FAIL |
| UAT-02 | EU incapable request | acceptance test | blocked | 실행 출력 기록 | PASS 또는 FAIL |
| UAT-03 | KR incapable online request | acceptance test | cloud | 실행 출력 기록 | PASS 또는 FAIL |
| UAT-04 | telemetry opt-out | acceptance test | event 0건 | 실행 출력 기록 | PASS 또는 FAIL |
| UAT-05 | telemetry opt-in | acceptance test | event 1건 | 실행 출력 기록 | PASS 또는 FAIL |

## 결함 Issue

실패한 기준별 `wf:verify` Issue 링크와 재현 명령을 기록한다.

## 결론

수락 여부와 남은 위험을 기록한다.
