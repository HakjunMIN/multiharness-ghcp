# Foundry IQ와 APIM 강사 설정

이 문서는 강사용 운영 절차다. 참가자는 Azure 원본 자격 증명을 받지 않고 APIM을 통해서만 모델과 검색을 호출한다. 고정 Search API 버전은 `2026-04-01`이며 preview answer synthesis는 사용하지 않는다.

## D-7 프로비저닝

1. Agentic retrieval을 지원하는 public Azure 지역에 Azure AI Search를 만든다. Web Knowledge Source는 private cloud와 sovereign cloud에서 지원되지 않으므로 해당 환경에서는 이 실습을 진행하지 않는다.
2. query planning과 웹 요약에 사용할 모델 deployment를 만들고 용량을 확인한다.
3. 강사가 정한 `BRAND_DOMAINS`로 Web Knowledge Source를 만든다. 공개 웹 전체가 아니라 교육용 신뢰 도메인만 허용한다.
4. 이 source와 모델을 참조하는 knowledge base를 만들고 retrieve API를 `2026-04-01`로 고정한다.
5. OpenAI-compatible 모델 base route를 `${APIM_BASE_URL}/model/v1`에 두고 `workshop-model` alias를 실제 deployment로 rewrite한다. Search의 `knowledgebases/{name}/retrieve` route도 같은 APIM base 뒤에 둔다.
6. backend로 전달하기 전에 참가자의 `Authorization`과 `Ocp-Apim-Subscription-Key` header를 제거한다. APIM managed identity 또는 Key Vault-backed named value로 origin 인증을 policy 안에서 주입한다.
7. 참가자별 subscription key를 발급하고 한 사람에게 하나만 배정한다.
8. key별 request rate와 model token limit을 적용한다. 초과 시 APIM은 429와 재시도 가능한 안내를 반환해야 한다.
9. retrieve smoke request를 한 번 실행한다. endpoint, key, resource name을 제거한 응답을 contract test fixture 후보로 보관한다.

## D-1 운영 점검

- 모델 deployment와 Search query capacity가 참가자 수를 감당하는지 확인한다.
- 각 key로 `workshop-model` alias와 retrieve route를 한 번씩 호출한다.
- 잘못된 key가 401 또는 403, rate limit이 429를 내는지 확인한다.
- APIM 로그에 subscription key나 원문 credential이 기록되지 않는지 확인한다.
- teardown 시각과 key rotation 담당자를 지정한다.

## 참가자 handout

아래 값은 형식만 보여 주는 non-routable 예시다. 실제 다섯 값은 개인별 보안 채널로 전달한다.

```dotenv
APIM_BASE_URL=https://workshop-apim.example.invalid
APIM_KEY=
KNOWLEDGE_BASE_NAME=workshop-products
BRAND_NAME=한빛전자
BRAND_DOMAINS=example.invalid
```

참가자는 값을 gitignored `.env`에만 넣는다. 채팅, Issue, commit, UAT 캡처에는 key를 남기지 않는다. Lab gate에서 다음 live smoke를 한 번 실행한다.

```bash
./scripts/test-live.sh
```

기본 `uv run --frozen pytest -q`는 live marker를 제외하며 네트워크를 호출하지 않는다.

## 장애 라우팅

| 상태 | 강사 조치 |
| --- | --- |
| 401/403 | 참가자 key와 APIM product assignment를 확인한다 |
| 404 | APIM route와 `KNOWLEDGE_BASE_NAME`이 일치하는지 확인한다 |
| 429 | 해당 key의 quota와 reset 시각을 확인한다. 다른 참가자의 key를 빌려주지 않는다 |
| 5xx | APIM backend health, 모델 deployment, Search resource health를 확인한다 |
| citation 없음 | `BRAND_DOMAINS`와 Web Knowledge Source 접근 가능성을 확인한다 |

## 종료와 폐기

워크숍 종료 후 participant subscriptions를 revoke하고 key를 rotate한다. 임시 APIM policy, Search knowledge base, model deployment의 보존 여부를 기록한 뒤 불필요한 리소스를 삭제한다.
