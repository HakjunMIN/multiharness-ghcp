# Host, agent runtime, model 매트릭스

세 축은 독립적입니다.

- **Host:** 대화와 도구를 제공하는 VS Code (Chat view 또는 Agents 창)
- **Agent runtime(harness):** Session Target 컨트롤에서 고르는 Copilot(native) 또는 third-party Claude
- **Model:** 해당 세션이 사용하는 추론 모델
- **Skill:** 선택한 runtime이 수행할 절차와 quality gate
- **Durable state:** 세션 밖의 docs, Issues, commits, tests

| 역할 | Host | Agent runtime | Model | Matt skill |
| --- | --- | --- | --- | --- |
| 발견·아키텍처·기획 | VS Code | Claude harness | Claude Opus 5 | `grill-with-docs`, `to-spec`, `to-tickets` |
| 구현 | VS Code | Copilot(native) harness | GPT-5.6 Sol | `implement`, `tdd` |
| 독립 검증 | VS Code | Copilot(native) harness, fresh session | Claude Sonnet 5 | `code-review` |

## 세션에서 harness와 model을 고르는 방법

harness 이름 뒤에 model 이름을 붙이는 슬래시 명령은 존재하지 않습니다.
VS Code Chat view 또는 Agents 창에서 **New Chat**으로 새 세션을 열면
**Session Target** 컨트롤에 harness 목록(Copilot, Claude, Codex, Cloud 등)이
나타나고, 여기서 이번 역할에 맞는 harness를 선택합니다. Model은 별도로
chat 입력창의 **language model picker**(드롭다운)에서 고릅니다. 이름이
비슷해도 harness와 model은 같은 개념이 아니라 서로 다른 컨트롤입니다.

기존 세션에서 harness를 바꾸면 VS Code는 이를 **handoff**로 취급해 대화
history와 context를 새 harness로 그대로 옮깁니다. 자세한 개념은
[Sessions and handoff](https://code.visualstudio.com/docs/agents/concepts/sessions)
문서를 참고합니다.

필수 조합이 Session Target/model picker에 없으면 다른 모델로 대체하지
않고 강사에게 알립니다. Day 2 cold-start는 model memory가 아니라 durable
state의 품질을 평가합니다.
