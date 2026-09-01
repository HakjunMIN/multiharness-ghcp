# 에이전틱 개발 워크플로

이 워크샵은 역할별 harness, model, skill, durable state를 조합하는 에이전틱
개발 워크플로를 local work item에 맞게 사용합니다. 이 저장소에 설치된
`mattpocock/skills`는 이 워크플로를 구현하는 샘플 스킬 세트이며,
Superpowers나 Ouroboros 등 다른 스킬 세트로 대체하거나 함께 활용할 수 있습니다.

```text
Copilot grill-with-docs → Claude handoff → to-spec → to-tickets
→ fresh Copilot implement → fresh Codex code-review + UAT
```

## 역할별 실행

발견은 New Chat에서 Session Target을 Copilot, model을 GPT-5.6 Sol로 선택하고
`/grill-with-docs`를 실행합니다. 결정 frontier가 닫히면 같은 세션의 Session
Target을 Claude로 바꿔 handoff하고 Claude Opus 4.8을 선택합니다. 이어서
`codebase-design`, `/to-spec`, `/to-tickets`로 local work item을 만듭니다.

구현은 local ticket마다 fresh session을 열고 Session Target을 Copilot,
model picker에서 GPT-5.6 Sol을 선택한 뒤
`/implement docs/work/<feature>/tickets/<ticket>.md`를 사용합니다.

검증은 handoff하지 않고 New Chat을 엽니다. Session Target을 Codex, provider를
Copilot-backed, model을 GPT-5.6 Terra로 선택합니다. local spec과 acceptance
matrix를 먼저 읽고 `/code-review main`을 수행한 뒤 독립 UAT를 실행합니다.

harness(Session Target)와 model(picker)은 서로 다른 컨트롤입니다. 자세한
전환 방법은 [Host/harness/model 매트릭스](model-harness-matrix.md)를,
세션 개념은 [VS Code Sessions and handoff](https://code.visualstudio.com/docs/agents/concepts/sessions)
문서를 참고합니다.

## Session boundaries

발견에서 기획까지는 handoff로 문맥을 유지하고, `to-tickets` 뒤에는 ticket이 다음 세션의
입력이 됩니다. Day 1 종료에는 `HANDOFF`에 첫 verify 명령을 남기고, Day 2는
이전 채팅 없이 commit된 durable state로 시작합니다. 구현은 ticket마다 새
세션, 검증은 구현 문맥과 분리된 새 세션을 사용합니다.

core는 Python API vertical slice이고 full은 core에 React UI를 더한 strict
superset입니다. 둘 다 같은 `POST /api/consult` contract를 사용합니다.

## 샘플 스킬 설치와 업데이트

```text
npx skills experimental_install
npx skills update code-review codebase-design \
  domain-modeling grill-with-docs grilling implement research tdd to-spec to-tickets
```

샘플 스킬은 `.agents/skills/`에 미리 설치되어 있습니다.
`skills-lock.json`과 설치 파일을 함께 커밋하며 업데이트 diff를 검토합니다.
Matt Pocock skills는 이 워크플로의 참고 구현체일 뿐 필수 전제는 아닙니다.
