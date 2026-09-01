# Foundry IQ와 APIM 운영자 설정

이 문서는 운영자용 운영 절차다. 참가자는 Azure 원본 자격 증명을 받지 않고 APIM을 통해서만 모델과 검색을 호출한다. 고정 Search API 버전은 `2026-04-01`이며 preview answer synthesis는 사용하지 않는다.

## D-7 프로비저닝

1. Agentic retrieval을 지원하는 public Azure 지역에 Azure AI Search를 만든다. Web Knowledge Source는 private cloud와 sovereign cloud에서 지원되지 않으므로 해당 환경에서는 이 실습을 진행하지 않는다.
2. 웹 요약에 사용할 모델 deployment를 만들고 용량을 확인한다. knowledge base가 참조할 수 있는 모델은 `gpt-5.4` 계열까지이므로 그보다 새 모델만 있는 프로젝트라면 `gpt-5.4-mini` 같은 지원 모델을 따로 배포한다. 참가자 채팅용 모델은 이 제약과 무관하다.
3. 공개 제품 근거를 검색하도록 Web Knowledge Source를 만든다.
4. 이 source와 모델을 참조하는 knowledge base를 만들고 retrieve API를 `2026-04-01`로 고정한다.
5. OpenAI-compatible 모델 base route를 `${APIM_BASE_URL}/model/v1`에 두고 `workshop-model` alias를 실제 deployment로 rewrite한다. Agent Framework는 `/chat/completions`가 아니라 **`/responses`** 를 호출하므로 두 operation을 모두 노출한다. Search의 `knowledgebases/{name}/retrieve` route도 같은 APIM base 뒤에 둔다.
6. backend로 전달하기 전에 참가자의 `Authorization`과 `Ocp-Apim-Subscription-Key` header를 제거한다. APIM managed identity 또는 Key Vault-backed named value로 origin 인증을 policy 안에서 주입한다.
7. 참가자별 subscription key를 발급하고 한 사람에게 하나만 배정한다.
8. key별 request rate를 적용한다. 초과 시 APIM은 429와 재시도 가능한 안내를 반환해야 한다. APIM **Consumption SKU는 `rate-limit-by-key`와 `azure-openai-token-limit`을 지원하지 않으므로** product scope의 `rate-limit`·`quota`로 구독별 한도를 건다. token 단위 제한이 필요하면 v2 SKU를 쓴다.
9. retrieve smoke request를 한 번 실행한다. `2026-04-01`은 `messages`가 아니라 `intents`를 받는다.

   ```json
   { "intents": [ { "type": "semantic", "search": "질문" } ] }
   ```

   endpoint, key, resource name을 제거한 응답을 contract test fixture 후보로 보관한다.

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
LIVE_SMOKE_QUESTION="공개 제품 정보와 출처를 요청하는 질문"
```

`LIVE_SMOKE_QUESTION`은 Web Knowledge Source에서 실제로 답과 citation을
반환할 수 있는 공개 제품 질문이어야 한다. 값에 공백이 있으면 따옴표로 감싼다.

참가자는 값을 gitignored `.env`에만 넣는다. 채팅, Issue, commit, UAT 캡처에는 key를 남기지 않는다. Lab gate에서 다음 live smoke를 한 번 실행한다.

```bash
./scripts/test-live.sh
```

기본 `uv run --frozen pytest -q`는 live marker를 제외하며 네트워크를 호출하지 않는다.

## 장애 라우팅

| 상태 | 운영자 조치 |
| --- | --- |
| 401/403 | 참가자 key와 APIM product assignment를 확인한다 |
| 404 | APIM route와 `KNOWLEDGE_BASE_NAME`이 일치하는지 확인한다 |
| 429 | 해당 key의 quota와 reset 시각을 확인한다. 다른 참가자의 key를 빌려주지 않는다 |
| 5xx | APIM backend health, 모델 deployment, Search resource health를 확인한다 |
| citation 없음 | Web Knowledge Source 접근 가능성과 질문이 공개 웹 근거로 답할 수 있는지 확인한다 |
| 모델 route만 404 | APIM에 `/responses` operation이 있는지 확인한다. Agent Framework는 Responses API를 호출한다 |
| retrieve 400 | 요청 payload가 `intents`인지 확인한다. `messages`는 preview 전용이다 |

## 종료와 폐기

과정 종료 후 participant subscriptions를 revoke하고 key를 rotate한다. 임시 APIM policy, Search knowledge base, model deployment의 보존 여부를 기록한 뒤 불필요한 리소스를 삭제한다.

key가 노출되면 즉시 회전한다. 회전은 해당 참가자에게만 영향을 준다.

```bash
APIM=".../providers/Microsoft.ApiManagement/service/<apim-name>"
az rest --method post --url "$APIM/subscriptions/<participant-id>/regeneratePrimaryKey?api-version=2022-08-01"
az rest --method post --url "$APIM/subscriptions/<participant-id>/listSecrets?api-version=2022-08-01" --query primaryKey -o tsv
```

APIM에 logger나 diagnostic setting을 붙이면 요청 header가 기록될 수 있다. key를 로그에 남기지 않으려면 과정 기간에는 진단을 끄거나, 켤 경우 `Ocp-Apim-Subscription-Key`를 header masking 대상으로 지정한다.
