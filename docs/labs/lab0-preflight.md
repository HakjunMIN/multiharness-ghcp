# Lab 0 - runway 사전 점검

## 이 랩에서 배우는 것

- Python API와 React web runway를 재현한다.
- 실제 비밀은 gitignored `.env`에만 둔다.
- 역할별 agent runtime과 model을 시작 전에 확인한다.

## 시작 전 상태

VS Code 1.128.0 이상, Node 22.18 이상, Python 3.11 이상, `uv`가 설치되어
있고 trusted workspace의 worktree가 깨끗해야 합니다. GitHub CLI(`gh`)는
최종 PR을 위해 자신의 fork를 origin으로 설정하는 참가자만 필요합니다.

## 저장소 준비

운영자가 제공한 리포를 clone합니다. spec, ticket, defect는 저장소 문서이므로
별도 tracker 권한이 필요하지 않습니다. 최종 PR을 만들 때만 자신의
fork를 origin으로 사용합니다.

```bash
git clone <repo-url>
cd <repo>
git remote -v
```

최종 PR을 만들 참가자는 자신의 fork를 origin으로 설정합니다. 운영자 리포 변경
사항을 받아야 하면 upstream을 추가하고 merge합니다.

## 실행

```bash
./scripts/preflight.sh
cp .env.example .env
# 운영자가 준 APIM 값을 .env에 직접 넣는다. 채팅이나 커밋에 붙이지 않는다.
./scripts/dev.sh
curl http://127.0.0.1:8000/healthz
```

별도 터미널에서 API 기본 테스트와 web 테스트를 실행한다.

```bash
(cd app/api && uv run --frozen pytest -q)
(cd app/web && npm test && npm run build)
git check-ignore .env
```

합의된 project-scope 스킬 12개(Matt Pocock 11개와 Anthropic `frontend-design`)는
`.agents/skills/`에 미리 설치되어 있습니다. 잠금 파일과 설치 상태를 확인합니다.

```text
./scripts/check-repo.sh
/skills
```

Claude는 `github.copilot.chat.claudeAgent.enabled`가 활성화됐는지 확인하고
Copilot 또는 Anthropic 인증 경로를 설정합니다. Codex는 OpenAI Codex
extension을 설치하거나 `chat.agentHost.codexAgent.enabled`를 활성화합니다.
Terra 검증에는 GitHub 로그인과 Copilot Pro+가 필요합니다.

VS Code Chat view(또는 Agents 창)에서 다음 네 조합을 확인합니다.

- Copilot + GPT-5.6 Sol: 발견
- Claude + Claude Opus 4.8: 아키텍처·기획
- Copilot + GPT-5.6 Sol: 구현
- local Codex의 Copilot-backed provider + GPT-5.6 Terra: 독립 검증

Cloud Codex, Auto, 다른 model로 대체하지 않습니다. strict preflight를 실행할
때는 확인 결과를 다음처럼 전달합니다.

```bash
WORKSHOP_GPT56_SOL_CONFIRMED=1 \
WORKSHOP_CLAUDE_OPUS48_CONFIRMED=1 \
WORKSHOP_CODEX_TERRA_CONFIRMED=1 \
  ./scripts/preflight.sh --strict
```

## 종료 조건

- 리포를 clone했고 최종 PR이 필요하면 자신의 fork를 origin으로 설정했다.
- 필수 스킬과 네 역할의 exact harness/model 조합을 열 수 있다.
- 두 서버가 시작되고 health가 설정된 브랜드를 반환한다.
- API 기본 테스트와 web test/build가 통과한다.
- `.env`가 무시되며 APIM key가 채팅이나 commit에 없다.

## 막힐 때

- 모델이나 skill이 없으면 임의 대체하지 말고 운영자에게 알린다.
- health만 실패하면 APIM보다 먼저 8000 포트와 Python 환경을 확인한다.
- `.env`가 추적되면 값을 지우고 운영자에게 key rotation을 요청한다.
- 최종 PR 단계에서 push 권한이 없으면 자신의 fork를 origin으로 설정한다.
