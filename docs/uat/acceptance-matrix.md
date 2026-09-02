# 독립 UAT 기준

이 표는 구현 전에 고정하는 black-box 계약이다. verifier는 구현 코드보다 spec과 이 표를 먼저 읽으며 production implementation을 수정하지 않는다.

| ID | Behavior | Deterministic evidence | Live evidence | Verdict |
| --- | --- | --- | --- | --- |
| UAT-01 | React에서 질문을 제출하면 loading 후 answer가 표시된다 | Playwright UI interaction + intercepted response | 실제 상담 흐름의 UI interaction | pass/fail |
| UAT-02 | answer와 URL을 포함한 structured citations가 함께 표시된다 | Playwright UI + intercepted response JSON | 실제 answer와 공개 citation URL | pass/fail |
| UAT-03 | 근거가 없으면 답을 꾸며내지 않고 그 상태를 UI에 표시한다 | controlled no-evidence response + UI | 선택 사항이며 실행 여부 기록 | pass/fail |
| UAT-04 | 429가 UI에서 actionable하고 secret-safe하다 | controlled 429 response + UI | 실행하지 않음; quota를 인위적으로 소진하지 않음 | pass/fail |
| UAT-05 | `/api/consult`가 answer와 citations envelope를 반환한다 | intercepted request/response capture | 실제 request/response envelope | pass/fail |

React와 API는 모두 필수 UAT 범위입니다. live 호출은 개인 APIM key로 정해진
window에만 수행하고 key, origin credential, provider payload를 evidence에
남기지 않습니다. deterministic suite와 live suite의 verdict를 서로 대체하지
않습니다.
