# Host, agent runtime, model 매트릭스

세 축은 독립적입니다.

- **Host:** 대화와 도구를 제공하는 GitHub Copilot CLI
- **Agent runtime:** GHCP native 또는 GHCP 안에서 선택한 third-party Claude
- **Model:** 해당 세션이 사용하는 추론 모델
- **Skill:** 선택한 runtime이 수행할 절차와 quality gate
- **Durable state:** 세션 밖의 docs, Issues, commits, tests

| 역할 | Host | Agent runtime | Model | Matt skill |
| --- | --- | --- | --- | --- |
| 발견·아키텍처·기획 | GHCP | Claude agent | Claude Opus 5 | `grill-with-docs`, `to-spec`, `to-tickets` |
| 구현 | GHCP | native coding agent | GPT-5.6 Sol | `implement`, `tdd` |
| 독립 검증 | GHCP | native coding agent, fresh session | Claude Sonnet 5 | `code-review` |

Claude agent 선택은 `/agent Claude`, 모델 선택은 `/model Claude Opus 5`로
각각 수행합니다. 이름이 비슷해도 agent와 model은 같은 개념이 아닙니다.

필수 조합이 계정에 없으면 다른 모델로 대체하지 않고 강사에게 알립니다.
Day 2 cold-start는 model memory가 아니라 durable state의 품질을 평가합니다.
