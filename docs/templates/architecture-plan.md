# Feature Gate 아키텍처 계획

## 결정 근거

관련 `wf:decision` Issue 링크와 최종 결정을 기록한다.

## 구성 요소

| 구성 요소 | 책임 | 의존성 |
|---|---|---|
| Policy | 지역별 cloud 허용 여부와 fallback 정책 | `RequestContext.region` |
| Router | 단말 능력과 Policy 결과를 조합해 target 결정 | Policy, DeviceCapabilities |
| Gate | 공개 API와 텔레메트리 opt-out 적용 | Router, Telemetry |

## 변경 순서

1. 정책 테스트를 먼저 추가한다.
2. 지역 정책과 라우팅 책임을 분리한다.
3. 텔레메트리 opt-out 테스트를 뒤집고 구현한다.
4. 독립 UAT를 실행한다.

## 작업 Issue

각 `wf:task` Issue 번호, acceptance criteria, blocker를 표로 기록한다.

## 위험과 완화

- 정책과 단말 능력 판정의 결합
- 기존 호출자의 API 호환성
- 구현 테스트와 독립 UAT의 중복 또는 누락

## 검증

```bash
(cd seed && npm test)
node --disable-warning=ExperimentalWarning --test docs/uat/acceptance.test.ts
./scripts/check-repo.sh
```
