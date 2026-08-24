# Feature Gate 요구사항

## 문제

지역별 프라이버시 정책과 사용자의 텔레메트리 선택을 현재 라우팅 SDK가 일관되게 적용하지 못한다.

## 범위

- 지역별 cloud inference 허용 정책
- 단말 능력에 따른 on-device 또는 blocked fallback
- 텔레메트리 opt-out

## 지역 정책

| 지역 | Cloud inference | 단말 실행 불가 시 |
|---|---|---|
| EU | 금지 | blocked |
| KR | 허용 | cloud |

## 수락 기준

1. EU 요청은 cloud로 전송되지 않는다.
2. EU 요청을 단말에서 처리할 수 없으면 blocked가 된다.
3. KR 요청은 단말 실행이 불가능하고 network가 online이면 cloud를 사용할 수 있다.
4. `userOptedOutTelemetry: true`이면 텔레메트리 이벤트가 발생하지 않는다.
5. opt-out이 아니면 라우팅 결정 이벤트가 정확히 한 건 발생한다.

## 범위 밖

- 실제 법률 자문
- 원격 정책 배포 시스템
- 실제 단말 하드웨어 probe

## 검증

```bash
(cd seed && npm test)
node --disable-warning=ExperimentalWarning --test docs/uat/acceptance.test.ts
./scripts/check-repo.sh
```
