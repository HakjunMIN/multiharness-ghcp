# 독립 UAT 기준

이 기준은 구현 세션이 시작되기 전에 확정된 블랙박스 계약이다. 검증자는 구현 코드나 구현자가 추가한 테스트보다 이 표를 먼저 읽는다.

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

이 테스트는 시드 상태에서 실패하는 것이 정상이다. Lab 3 구현 후 Lab 4의 새 검증 세션에서 통과해야 한다. 참가자는 이 파일을 수정하지 않는다.
