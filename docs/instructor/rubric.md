# 평가 기준

| 기준 | 증거 |
| --- | --- |
| 재현 가능한 runway | health, frozen API tests, web test/build, secret-safe env |
| 도메인/설계 품질 | shared vocabulary, ADR, HTTP/policy/test seams |
| vertical ticket 품질 | 사용자 동작, acceptance criteria, 정확한 blocking edges |
| red-green 구현 | focused RED/GREEN, 전체 suite, commit |
| 실제 APIM smoke | 개인 key로 실행한 redacted live evidence |
| durable cold-start | `HANDOFF` verify와 새 세션 복구 기록 |
| 독립 검증 | Sonnet 5 review, UAT report, defect evidence |
| runtime 이해 | host, agent runtime, model, skill, durable state 구분 |
