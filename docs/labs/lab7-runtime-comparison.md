# Lab 7 - runtime 비교 (30분)

## 이 랩에서 배우는 것

- 같은 bounded prompt를 다른 허용 조합으로 다시 실행한다.
- 모델 인상 대신 결과 evidence로 비교한다.
- host, agent runtime, model, skill을 분리해 기록한다.

이미 끝난 작은 ticket 또는 review prompt 하나를 별도 branch/worktree에서 다시 실행한다. correctness, test quality, durable artifacts, 사람 개입 횟수를 비교한다. 대체 구현은 기본적으로 merge하지 않는다.

| 항목 | 원래 조합 | 비교 조합 |
| --- | --- | --- |
| Host / runtime / model / skill | 기록 | 기록 |
| acceptance 통과 | 기록 | 기록 |
| test quality | 기록 | 기록 |
| durable artifacts | 기록 | 기록 |
| intervention count | 기록 | 기록 |

## 종료 조건

- 동일한 bounded prompt와 평가 기준을 사용했다.
- 비교 결과가 evidence와 함께 기록됐다.
- 대체 구현이 main 작업을 오염시키지 않았다.

## 막힐 때

- 시간이 부족하면 구현 대신 review prompt만 비교한다.
- 범위가 달라지면 결과를 비교하지 말고 prompt부터 맞춘다.
