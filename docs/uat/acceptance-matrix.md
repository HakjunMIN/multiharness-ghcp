# 독립 UAT 기준

이 표는 구현 전에 고정하는 black-box 계약이다. verifier는 구현 코드보다 spec과 이 표를 먼저 읽으며 production implementation을 수정하지 않는다.

| ID | Behavior | Evidence | Verdict |
| --- | --- | --- | --- |
| UAT-01 | `/api/consult`가 answer envelope를 반환한다 | request/response capture | pass/fail |
| UAT-02 | response에 URL을 포함한 structured citations가 있다 | response JSON | pass/fail |
| UAT-03 | 근거가 없으면 answer를 꾸며내지 않는다 | controlled query | pass/fail |
| UAT-04 | 429가 actionable하고 secret-safe하다 | APIM response/UI | pass/fail |

full 범위가 구현된 경우에만 React에서 질문, loading, answer, citations, 429 상태를 추가 검증한다. live 호출은 개인 APIM key로 정해진 window에만 수행하고 key를 evidence에 남기지 않는다.
