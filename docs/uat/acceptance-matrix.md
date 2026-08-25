# 독립 UAT 기준

이 기준은 구현 세션이 시작되기 전에 확정된 블랙박스 계약이다. 검증자는 구현 코드나 구현자가 추가한 테스트보다 이 표를 먼저 읽는다.

트랙마다 표가 하나씩 있다. 자신이 고른 트랙의 표만 보면 된다. 트랙 선택은 [Lab 1](../labs/lab1-discovery.md)에서 한다.

## 트랙 ts — 온디바이스 추론 라우팅 (`seed/`)

| ID | 입력 | 기대 target / event | 검증 목적 |
|---|---|---|---|
| UAT-01 | EU, capable, online, large payload | `on-device` | 제한 지역은 payload 크기와 무관하게 cloud 금지 |
| UAT-02 | EU, incapable, online | `blocked` | 제한 지역에서 단말 fallback 불가 시 차단 |
| UAT-03 | KR, incapable, online | `cloud` | 허용 지역의 cloud fallback |
| UAT-04 | telemetry opt-out true | event 0건 | 사용자 선택 적용 |
| UAT-05 | telemetry opt-out false | event 1건 | 정상 관측 유지 |

실행:

```bash
node --disable-warning=ExperimentalWarning --test docs/uat/acceptance.test.ts
```

## 트랙 agent — 한빛전자 제품 상담 에이전트 (`agent-seed/`)

| ID | 입력 | 기대 | 검증 목적 |
|---|---|---|---|
| AUAT-01 | EU 지역의 제품 질문 | `used_web_search == False` | 제한 지역은 외부 검색으로 나가지 않는다 |
| AUAT-02 | KR 지역의 제품 질문 | `used_web_search == True` | 허용 지역의 검색은 그대로 동작한다 |
| AUAT-03 | KR 지역의 제품 질문 | `citations` 1건 이상, 각 항목에 URL | 출처가 기계로 검증 가능해야 한다 |
| AUAT-04 | telemetry opt-out true | event 0건 | 사용자 선택 적용 |
| AUAT-05 | telemetry opt-out false | event 1건 | 정상 관측 유지 |
| AUAT-06 | 기록된 이벤트 | 질문 원문이 그대로 없음 | 개인정보 유입 경로 차단 |

실행:

```bash
(cd agent-seed && uv run --frozen pytest ../docs/uat/acceptance_agent_test.py)
```

## 공통 규칙

두 테스트 파일 모두 **시드 상태에서 실패하는 것이 정상이다.** Lab 3 구현 후 Lab 4의 새 검증 세션에서 통과해야 한다. 참가자는 이 파일들을 수정하지 않는다.
