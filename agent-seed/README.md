# agent-seed — 한빛전자 제품 상담 에이전트

Microsoft Agent Framework 로 만든 **웹검색 기반 지식 검색 상담 에이전트**입니다. 워크샵 에이전트 트랙의 출발점입니다.

> `한빛전자`는 가상의 회사입니다. 실습에서 실제 고객사 이름을 쓰지 않습니다. 리포 게이트가 이를 검사합니다.

## 실행

```bash
cd agent-seed
uv sync
uv run pytest -q
```

리포 루트에서는 이 한 줄로 충분합니다.

```bash
(cd agent-seed && uv run --frozen pytest -q)
```

## 테스트는 네트워크를 쓰지 않는다

두 군데에서 네트워크를 끊었습니다.

| 무엇 | 어떻게 |
| --- | --- |
| 웹검색 | `OfflineIndex`가 `src/hanbit_consult/fixtures/*.json`을 읽습니다 |
| 모델 호출 | `ScriptedChatClient`가 정해진 응답을 돌려줍니다 |

`ScriptedChatClient`가 `Agent`에 들어갈 수 있는 이유는 Agent Framework 의 `SupportsChatGetResponse`가 **상속이 아니라 구조적 프로토콜**이기 때문입니다. `additional_properties` 속성과 awaitable 을 돌려주는 `get_response`만 있으면 됩니다. 덕분에 에이전트 배선 전체를 오프라인에서 검증할 수 있습니다.

실제 모델로 돌리려면 `build_agent`에 진짜 클라이언트를 넣으면 됩니다. `agent.py`는 바뀌지 않습니다.

```python
from agent_framework_openai import OpenAIChatClient
from hanbit_consult import build_agent

agent = build_agent(OpenAIChatClient(model_id="gpt-4o-mini"))
```

## 구조

| 파일 | 책임 |
| --- | --- |
| `types.py` | 값 객체. 정책 없음 |
| `search.py` | 웹검색 도구와 백엔드 계약 |
| `answer.py` | 언제 검색하고 무엇을 근거로 답할지 정하는 정책 |
| `telemetry.py` | 상담 기록 |
| `agent.py` | Agent 조립과 테스트용 클라이언트 |

## 알려진 설계 부채

**이 부채는 의도된 것입니다. 워크샵 전에 고치지 마세요.** 참가자가 발견하고, 결정 이슈로 만들고, 고치는 것이 실습입니다.

각 부채는 이름이 `test_known_gap_`으로 시작하는 **통과하는** 테스트로 고정되어 있습니다. 그 테스트들은 지금의 *잘못된* 동작을 기록합니다. 동작을 고치면 테스트를 지우지 말고 **기대값을 뒤집고, 그 이유를 커밋 메시지에 적으세요.**

### 1. 지역을 보지 않는다

`Question.region`은 존재하지만 `answer.py`가 한 번도 읽지 않습니다. EU 사용자의 질문도 그대로 외부 검색으로 나갑니다.

- 고정 테스트: `test_known_gap_the_region_is_not_consulted_before_web_search`

### 2. 출처가 구조화되어 있지 않다

`Answer.citations`가 항상 비어 있습니다. 출처 URL 은 본문 문자열 안에만 있어서 기계가 검증할 수 없습니다.

- 고정 테스트: `test_known_gap_the_answer_carries_no_structured_citations`

### 3. 텔레메트리 옵트아웃이 무시된다

`Question.telemetry_opt_out`이 `True`여도 `TelemetrySink.record`가 그대로 기록합니다.

- 고정 테스트: `test_known_gap_the_opt_out_flag_does_not_stop_recording`

### 4. 질문 원문이 그대로 저장된다

`TelemetryEvent.question_text`에 사용자가 쓴 문장이 그대로 들어갑니다. 개인정보가 섞여 들어올 수 있는 경로입니다.

- 고정 테스트: `test_known_gap_the_raw_question_text_is_stored`

### 5. `needs_web_search`가 읽기 어렵다

중첩된 `if`/`else`가 다섯 겹입니다. 어떤 입력이 어느 분기로 가는지 눈으로 따라가기 어렵고, 규칙을 하나 더 넣으면 더 나빠집니다. 규칙이 늘어날 때 이 구조가 버티는지가 Lab 2 의 재료입니다.

## 의존성

| 패키지 | 버전 | 왜 |
| --- | --- | --- |
| `agent-framework-core` | `1.14.0` | Agent, Message, ChatResponse, tool |
| `agent-framework-openai` | `1.13.0` | 실제 모델로 돌릴 때 쓰는 클라이언트 |
| `pytest` | `8.4.2` | 테스트 |
| `pytest-asyncio` | `1.2.0` | `async def` 테스트 |

버전을 정확히 고정합니다. 워크샵 도중에 상위 버전이 나와서 API 가 흔들리면 실습이 멈춥니다. `uv.lock`이 커밋되어 있고 검증은 `uv run --frozen pytest -q`로 실행합니다.
