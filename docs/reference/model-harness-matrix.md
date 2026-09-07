# Host, agent runtime, model 매트릭스

세 축은 독립적입니다.

- **Host:** 대화와 도구를 제공하는 VS Code (Chat view 또는 Agents 창)
- **Agent runtime(harness):** Session Target 컨트롤에서 고르는 Copilot, Claude, Codex
- **Model:** 해당 세션이 사용하는 추론 모델
- **Skill:** 선택한 runtime이 수행할 절차와 quality gate
- **Durable state:** 세션 밖의 local work items, docs, commits, tests

아래 조합은 과정의 **권장 기본값**입니다. 특정 harness/model 자체보다 역할별
fresh session, 필요한 skill 실행, durable state 전달, 구현과 검증의 분리가
워크플로의 필수 interface입니다.

| 역할 | Host | 권장 agent runtime | 권장 model | Matt skill |
| --- | --- | --- | --- | --- |
| 발견 | VS Code | Copilot harness, fresh session | GPT-5.6 Sol | `grill-with-docs`, `grilling`, `domain-modeling`, `research` |
| Prototype | VS Code | Copilot harness, fresh session | GPT-5.6 Sol | `prototype`, `frontend-design` |
| 아키텍처·기획 | VS Code | Claude harness, fresh session | Claude Opus 4.8 | `codebase-design`, `to-spec`, `to-tickets` |
| 구현 | VS Code | Copilot harness, fresh session | GPT-5.6 Sol | `implement`, `tdd` |
| 독립 검증 | VS Code | Codex harness, fresh session | GPT-5.6 Terra | `code-review` |

## 세션에서 harness와 model을 고르는 방법

harness 이름 뒤에 model 이름을 붙이는 슬래시 명령은 존재하지 않습니다.
VS Code Chat view 또는 Agents 창에서 **New Chat**으로 새 세션을 열면
**Session Target** 컨트롤에 harness 목록(Copilot, Claude, Codex, Cloud 등)이
나타나고, 여기서 이번 역할에 맞는 harness를 선택합니다. Model은 별도로
chat 입력창의 **language model picker**(드롭다운)에서 고릅니다. 이름이
비슷해도 harness와 model은 같은 개념이 아니라 서로 다른 컨트롤입니다.

기존 세션에서 harness를 바꾸면 VS Code는 이를 **handoff**로 취급해 full
conversation history와 누적 context를 새 harness로 옮깁니다. 이 과정은 발견,
prototype, 기획, 구현, 검증 역할을 모두 New Chat의 fresh session으로
분리하므로 handoff를 사용하지 않습니다. 역할 사이의 문맥은 커밋된 durable
artifact로만 전달합니다. 자세한 개념은
[Sessions and handoff](https://code.visualstudio.com/docs/agents/concepts/sessions)
문서를 참고합니다.

권장 조합이 Session Target/model picker에 없으면 역할에 필요한 skill을 지원하는
다른 조합을 선택할 수 있습니다. 실제 host, harness, model, skill은 `HANDOFF`와
UAT report에 기록합니다. 독립 검증은 구현 세션과 분리된 fresh session이어야
합니다. 권장 Codex + GPT-5.6 Terra 경로는 local Codex의 Copilot-backed
provider입니다. fresh session은 model memory 대신 durable state로 복구합니다.

## Astra / Fable 5.1과 간결한 스킬

모델 이름을 바꾸기 위해 스킬을 복제하거나 별도 모델별 프롬프트를 만들지 않습니다.
Astra, Fable 5.1도 실제 picker에서 제공되고 필요한 도구·project skill을 지원하면
후보로 평가합니다. 위 표는 실습 권장값이지 최신 모델 순위나 호환성 보증이 아닙니다.
개발 에이전트의 모델 선택은 앱의 고정 APIM runtime 설정과 별개입니다.

간결화 기준은 **일반 설명·중복은 줄이고, 프로젝트 계약·실패 시 행동은 남긴다**입니다.
짧은 스킬도 이전 채팅에 의존하거나 역할 경계를 넘으면 부적합합니다.
`CLAUDE.md`는 이미 짧은 정본 포인터이므로 규칙을 다시 넣지 않습니다.

### 비교 검증

같은 저장소 commit·입력 artifact·도구 권한·harness·모델 설정에서 기존/수정 스킬을
각각 fresh session으로 여러 번 비교합니다. 모델 간 비교는 별도 축으로 기록합니다.
원문 질문·답변이나 credential 대신 시나리오 ID, 결과, 검증 근거만 남깁니다.

| 시나리오 | 필수 관찰 결과 |
| --- | --- |
| discovery 승인 또는 prototype 정적 참조 누락 | 기획·구현을 시작하지 않고 blocker 보고 |
| 승인된 discovery와 prototype만 있는 fresh 기획 | 이전 채팅 없이 전체 spec과 tickets를 local 경로에 작성 |
| API/브라우저 인수 ticket | production 변경 없이 expected red와 재현 명령 기록 |
| backend ticket | APIM 단일 경계·payload 정본 준수, 기본 테스트 offline |
| frontend ticket | 선택된 token·landmark·나눔고딕과 loading/error/citation 상태 유지 |
| `/workflow status`, 같은 모델의 다른 역할 | 하위 스킬 미실행, 역할 변경에는 새 세션 안내 |
| 구현 완료 또는 verifier의 defect 발견 | 7필드 HANDOFF·두 commit, verifier는 production 미수정 |

먼저 계약 위반·승인 우회·정보 노출이 없는지 확인하고, 산출물 완결성·테스트 결과·
재작업 횟수를 비교합니다. 그 뒤 입력 토큰과 도구 호출량을 비교합니다.
글자·단어 수 감소는 실제 토큰 절감이나 모델 품질 향상의 증거가 아닙니다.
실행하지 못한 모델/시나리오는 통과가 아니라 미검증으로 기록합니다.

이번 변경은 정적 계약 감사와 저장소 회귀 검사입니다. Astra/Fable 5.1의 반복 A/B
실행이나 성능 향상을 입증한 결과는 아니며, 실제 모델별 적합성은 위 비교가 필요합니다.
