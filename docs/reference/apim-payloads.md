# APIM payload 계약

이 문서는 고정 APIM runtime 경계(`AGENTS.md`)에서 실제로 오가는 **wire payload의 정본**이다.
구현 세션과 인수 시나리오 세션은 이 shape을 기준으로 adapter와 fixture를 만든다.
여기 실린 예시 값은 전부 위생 처리한 non-routable 값이며 실제 응답 원문이 아니다.

두 요청 모두 `APIM_KEY`를 `Ocp-Apim-Subscription-Key` header로,
`Content-Type: application/json`으로 보낸다. `Authorization` header는 보내지 않는다.

| 용도 | Method | URL |
| --- | --- | --- |
| 근거 검색 | POST | `${APIM_BASE_URL}/search/knowledgebases/${KNOWLEDGE_BASE_NAME}/retrieve?api-version=2026-04-01` |
| 답변 합성 | POST | `${APIM_BASE_URL}/model/v1/responses` |

---

## 1. Foundry IQ retrieve

API 버전은 `2026-04-01`로 고정한다. preview의 `messages` 필드는 쓰지 않는다.

### Request

```json
{
  "intents": [
    { "type": "semantic", "search": "제품 보증 기간이 어떻게 되나요?" }
  ]
}
```

- `intents`는 배열이고 최소 한 개가 필요하다. 사용자의 질문 문자열을 `search`에 그대로 넣는다.
- `type`은 `semantic`을 쓴다.

### Response (200)

```json
{
  "@odata.context": "https://search.example.invalid/$metadata#...Agents.RetrieveResponse",
  "response": [
    {
      "content": [
        {
          "type": "text",
          "text": "[{\"url\":\"https://docs.example.invalid/a\",\"ref_id\":0,\"title\":\"제품 A 사양\",\"content\":\"보증 기간은 …\"}]"
        }
      ]
    }
  ],
  "activity": [
    {
      "type": "web",
      "id": 0,
      "knowledgeSourceName": "workshop-web",
      "queryTime": "2026-01-01T00:00:00.0000000Z",
      "count": 3,
      "elapsedMs": 704,
      "webArguments": { "search": "제품 보증 기간이 어떻게 되나요?" }
    },
    { "type": "agenticReasoning", "id": 1, "reasoningTokens": 0 },
    { "type": "modelWebSummarization", "id": 2, "inputTokens": 0, "outputTokens": 0, "elapsedMs": 0 }
  ],
  "references": [
    {
      "type": "web",
      "id": "0",
      "activitySource": 0,
      "url": "https://docs.example.invalid/a",
      "title": "제품 A 사양",
      "sourceData": null
    }
  ]
}
```

실습에서 자주 틀리는 지점:

- **`response[0].content[0].text`는 문자열이지 객체가 아니다.** 그 안에 JSON 배열이
  문자열로 한 번 더 인코딩되어 있으므로 한 번 더 파싱해야 근거 본문을 얻는다.
  파싱 실패는 no-evidence로 처리하고 예외를 그대로 올리지 않는다.
- 내부 배열의 각 항목 키는 `url`, `ref_id`(int), `title`, `content`다.
- `references[].id`는 **문자열**이고 내부 배열의 `ref_id`는 **정수**다. 둘을 이어
  붙일 때 타입을 맞춘다.
- `activity[]`는 항목마다 키가 다른 union이다. `type`으로 분기하고 모르는 `type`은
  무시한다. `activity`에 의존해 답변을 만들지 않는다.
- `references`와 내부 배열의 길이는 다를 수 있다. citation은 `references`를 기준으로
  만들고 본문은 `ref_id`로 결합한다.
- 근거가 없으면 `references`가 빈 배열이고 `text`도 빈 배열 문자열(`"[]"`)이 된다.
  이때 no-evidence 동작으로 간다.

### citation 매핑

| 응답 UI 필드 | 출처 |
| --- | --- |
| 제목 | `references[].title` |
| 링크 | `references[].url` |
| 발췌 | 내부 배열에서 `ref_id == int(references[].id)`인 항목의 `content` |

`sourceData`는 `null`일 수 있으므로 citation의 필수 입력으로 쓰지 않는다.

---

## 2. Model responses

Agent Framework는 `/chat/completions`가 아니라 Responses API를 호출한다.
`OpenAIChatClient`의 base URL은 `${APIM_BASE_URL}/model/v1`이며 client가 `/responses`를 붙인다.

### Request

```json
{
  "model": "workshop-model",
  "input": [
    {
      "role": "user",
      "content": [{ "type": "input_text", "text": "질문과 근거를 담은 프롬프트" }]
    }
  ],
  "max_output_tokens": 512
}
```

- `model`은 APIM alias `workshop-model`이며 코드 상수다. runtime 환경 변수로 만들지 않는다.
- 입력 content의 `type`은 `input_text`, 출력은 `output_text`로 서로 다르다.

### Response (200)

```json
{
  "id": "resp_0000",
  "object": "response",
  "status": "completed",
  "model": "workshop-model",
  "error": null,
  "incomplete_details": null,
  "output": [
    {
      "id": "msg_0000",
      "type": "message",
      "status": "completed",
      "role": "assistant",
      "phase": "final_answer",
      "content": [
        { "type": "output_text", "text": "…답변…", "annotations": [], "logprobs": [] }
      ]
    }
  ],
  "usage": {
    "input_tokens": 7,
    "output_tokens": 5,
    "total_tokens": 12,
    "input_tokens_details": { "cached_tokens": 0, "cache_write_tokens": 0 },
    "output_tokens_details": { "reasoning_tokens": 0 }
  },
  "content_filters": []
}
```

실습에서 자주 틀리는 지점:

- **`output[0]`이 항상 답변 message는 아니다.** reasoning 모델은 `type`이 `reasoning`인
  항목을 앞에 넣을 수 있다. `type == "message"`인 항목만 고른 뒤 그 안에서
  `type == "output_text"`인 content를 이어 붙인다.
- `status`가 `incomplete`이면 `incomplete_details.reason`(예: `max_output_tokens`)을 보고
  잘린 답변으로 처리한다. `completed`가 아닐 때 텍스트를 그대로 확정 답변으로 쓰지 않는다.
- `error`는 성공 시 `null`이다. HTTP 200이어도 `error`가 채워질 수 있으므로 함께 확인한다.
- `usage`, `content_filters`, `reasoning` 같은 필드는 늘어날 수 있다. 모르는 키는 무시한다.

### 답변 텍스트 추출

```text
"".join(
    part.text
    for item in body["output"] if item.get("type") == "message"
    for part in item.get("content", []) if part.get("type") == "output_text"
)
```

---

## 3. 오류 응답

| 상태 | 의미 | 애플리케이션 처리 |
| --- | --- | --- |
| 400 | retrieve payload가 `intents`가 아님 | 요청 형식을 고친다. 사용자에게는 일반 오류 |
| 401 / 403 | key 또는 product assignment 문제 | key를 로그에 남기지 않고 route와 status만 기록 |
| 404 | route 또는 `KNOWLEDGE_BASE_NAME` 불일치 | 설정 확인. 사용자에게는 일반 오류 |
| 429 | rate limit | 재시도 가능 안내를 반환 |
| 5xx | backend 장애 | 재시도 가능 안내를 반환 |

오류 경로에서도 `APIM_KEY`, 실제 base URL, provider 응답 원문을 로그·commit·Issue에 남기지 않는다.

---

## 4. Fixture와 검증

- 기본 unit/contract test는 이 문서의 shape을 위생 처리한 JSON fixture로 고정하고
  네트워크를 호출하지 않는다.
- 실제 APIM 호출은 `e2e` marker로 분리하고 운영자가 지정한 gate에서만 실행한다.

```bash
(cd app/api && uv run --frozen pytest -q)        # offline, fixture 기반
(cd app/api && uv run --frozen pytest -m e2e -q) # gate에서만
```

이 문서와 실제 응답이 어긋나면 운영자가 `docs/setup/azure-setup.md`의 smoke 절차로
응답을 다시 캡처하고, 위생 처리한 뒤 이 문서를 먼저 갱신한다.
