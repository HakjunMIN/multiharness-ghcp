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
conversation history와 누적 context를 새 harness로 옮깁니다. 이 과정은 네
역할을 모두 New Chat의 fresh session으로 분리하므로 handoff를 사용하지
않습니다. 역할 사이의 문맥은 커밋된 durable artifact로만 전달합니다. 자세한
개념은
[Sessions and handoff](https://code.visualstudio.com/docs/agents/concepts/sessions)
문서를 참고합니다.

권장 조합이 Session Target/model picker에 없으면 역할에 필요한 skill을 지원하는
다른 조합을 선택할 수 있습니다. 실제 host, harness, model, skill은 `HANDOFF`와
UAT report에 기록합니다. 독립 검증은 구현 세션과 분리된 fresh session이어야
합니다. 권장 Codex + GPT-5.6 Terra 경로는 local Codex의 Copilot-backed
provider입니다. cold-start는 model memory가 아니라 durable state의 품질을
평가합니다.
