# Lab 10 (선택) - VS Code에서 클라우드 에이전트

## 이 랩에서 배우는 것

- 비밀이 필요 없는 bounded task만 cloud agent에 위임한다.
- local과 cloud 실행의 권한 및 context 차이를 확인한다.
- cloud 결과도 같은 review와 검증 gate를 통과시킨다.

## 시작

이 랩은 평가 경로 밖의 선택 실습입니다. 이미 승인된 spec 안에서 문서 정리,
network-free unit test 보강, 작은 리팩터링 중 하나를 고릅니다. Cloud session은
운영자의 gitignored `.env`를 받지 않으므로 실제 APIM retrieval이나 browser live
동작을 위임하지 않습니다.

VS Code에서 별도 cloud session을 만들고 bounded prompt, 정확한 파일 경로,
검증 명령을 전달합니다. APIM key, 고객 식별 정보, 질문·답변 원문과 provider
payload를 prompt나 log에 포함하지 않습니다.

Python `e2e` marker가 붙은 테스트와 `npm run test:e2e:live`는 cloud session에서
실행하지 않습니다. 결과 diff를 local에서 검토하고 network-free suite와
`./scripts/check-repo.sh`를 다시 실행합니다.

## 종료 조건

- cloud에 전달한 작업이 비밀 없는 bounded task다.
- 결과 diff를 local에서 검토하고 관련 기본 suite를 통과시켰다.
- 실제 host, harness, model과 명령을 durable artifact에 기록했다.

## 막힐 때

- 작업이 APIM credential을 요구하면 local gated session으로 되돌린다.
- cloud 결과가 spec 밖을 수정하면 해당 변경을 채택하지 않는다.
- 권한이 불명확하면 자동 승인보다 review 가능한 plan mode를 사용한다.
