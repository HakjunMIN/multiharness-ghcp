# Greenfield Product Consultation Agent Workshop

Microsoft Agent Framework Python backend와 React frontend로 공개 웹 근거 기반 제품 상담 app을 만드는 2일 hands-on workshop입니다. Foundry IQ retrieval과 model endpoint는 instructor APIM 뒤에 있으며, 참가자는 origin credentials를 받지 않습니다.

## 범위

- `core`: API에서 질문을 받아 answer와 structured citations를 반환하고 근거가 없을 때 답을 꾸며내지 않도록 처리
- `full`: core 전체에 React 상담 UI와 citation/error states 추가

full은 별도 출발점이 아니라 core의 strict superset입니다.

## 시작

강사가 제공한 리포를 clone합니다. 최종 PR이 필요한 과정에서는 자신의 fork를
사용하지만 spec, ticket, defect는 모두 저장소의 local work item으로 관리하므로
remote tracker 권한과 연결은 요구하지 않습니다.

```bash
git clone <instructor-repo-url>
cd <repo>
./scripts/preflight.sh
cp .env.example .env
./scripts/dev.sh
```

강사가 전달한 다섯 runtime 값은 `.env`에만 둡니다. 커밋된 예시는 non-routable입니다.

## Main flow

```text
Copilot /grill-with-docs -> docs/work/<feature>/discovery.md
  -- fresh --> Claude /to-spec -> /to-tickets
  -- fresh --> Copilot /implement <local-ticket-path>
  -- fresh --> Codex /code-review main
```

역할이 바뀌면 새 세션을 엽니다. 세션 사이의 문맥은 채팅 history가 아니라
커밋된 durable artifact로 전달합니다.

| 역할 | Agent runtime | Model | 다음 역할에 남기는 것 |
| --- | --- | --- | --- |
| 발견 | Copilot fresh session | GPT-5.6 Sol | `discovery.md`, `CONTEXT.md`, ADR |
| 아키텍처, 기획 | Claude fresh session | Claude Opus 4.8 | `spec.md`, `tickets/` |
| 구현 | Copilot fresh session | GPT-5.6 Sol | 구현 commit, `HANDOFF` |
| 독립 검증 | Codex fresh session | GPT-5.6 Terra | UAT report, `defects/` |

자세한 흐름은 [에이전틱 개발 워크플로](docs/reference/workflow.md), 조합의 의미는 [모델 하네스 매트릭스](docs/reference/model-harness-matrix.md)를 봅니다.

## VS Code와 harness 사전 설정

VS Code **1.128.0 이상**의 trusted workspace를 사용합니다. Chat view 또는
Agents 창에서 **Session Target**으로 harness를 고르고, 입력창의 **language
model picker**에서 model을 별도로 고릅니다. 공식 절차는
[Agent harnesses](https://code.visualstudio.com/docs/agents/run/agent-harnesses)를
따릅니다.

- Claude는 기본 활성화되며 `github.copilot.chat.claudeAgent.enabled`로
  제어합니다. GitHub Copilot provider 또는 Anthropic 인증 경로를 수업 전에
  설정하고 billing provider를 확인합니다.
- Codex는 OpenAI Codex extension을 설치하거나
  `chat.agentHost.codexAgent.enabled`를 활성화합니다. GPT-5.6 Terra는 local
  Codex의 Copilot-backed provider에서 확인하며 GitHub 로그인과
  **Copilot Pro+**가 필요합니다.
- **Cloud Codex**는 이 검증 경로가 아닙니다. Session Target과 provider 아래에
  exact model이 없으면 Auto나 다른 모델로 대체하지 말고 사전 점검을 중단합니다.

이 워크샵의 에이전틱 개발 워크플로는 특정 스킬 세트에 종속되지 않습니다.
Matt Pocock 스킬과 Anthropic의 `frontend-design`은 `.agents/skills/`에 포함된
project-scope 샘플 구현체입니다. 설치 계약은 `./scripts/check-repo.sh`로
확인합니다. 복원이 필요할 때만 잠금 파일에서 `npx skills experimental_install`을
실행하고, 선택 설치를 다시 만들어야 하면 Matt Pocock 스킬 11개와
`frontend-design`을 함께 지정합니다.

```bash
npx skills@latest add mattpocock/skills \
  --agent github-copilot --copy -y \
  --skill grill-with-docs grilling domain-modeling research codebase-design \
  to-spec to-tickets implement tdd code-review diagnosing-bugs
npx skills@latest add anthropics/skills@frontend-design \
  --agent github-copilot --copy -y
```

spec, ticket, defect 규약은 [local work item tracker](docs/agents/issue-tracker.md)를
따릅니다. `CONTEXT.md`, [`docs/adr/`](docs/adr/README.md),
[`docs/work/`](docs/work/README.md)는 비어 있는 상태로 시작하며 참가자가 랩을
진행하면서 직접 채웁니다.

## Labs

1. [Runway preflight](docs/labs/lab0-preflight.md)
2. [Discovery](docs/labs/lab1-discovery.md)
3. [Spec and tickets](docs/labs/lab2-spec-tickets.md)
4. [Tracer bullet](docs/labs/lab3-tracer-bullet.md)
5. [Cold-start recovery](docs/labs/lab4-cold-start.md)
6. [Behavior and full improvement](docs/labs/lab5-improvement.md)
7. [Independent verification](docs/labs/lab6-verification.md)
8. [Runtime comparison](docs/labs/lab7-runtime-comparison.md)
9. [Integration](docs/labs/lab8-integration.md)

## 검증

```bash
(cd app/api && uv run --frozen pytest -q)
(cd app/web && npm test && npm run build)
./scripts/check-repo.sh
```
