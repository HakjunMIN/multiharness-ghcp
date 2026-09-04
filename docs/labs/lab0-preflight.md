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

터미널 A에서 환경을 점검하고 `.env`를 만듭니다.

```bash
./scripts/preflight.sh
cp .env.example .env
# 운영자가 준 APIM 값을 .env에 직접 넣는다. 채팅이나 커밋에 붙이지 않는다.
```

preflight는 toolchain과 의존성 설치만 FAIL로 막습니다. Node, uv, git,
web/API 의존성 설치와 Playwright Chromium 설치가 여기에 해당합니다. runway
test나 build 실패는 환경이 아니라 작업 중 코드 문제일 수 있으므로 WARN으로
보고하며, 랩 진행을 막지 않습니다.

이어서 터미널 A에서 두 서버를 띄웁니다. `dev.sh`는 종료할 때까지 터미널을
점유하므로 이 터미널은 그대로 둡니다.

```bash
./scripts/dev.sh
```

터미널 B에서 두 서버의 health를 확인합니다.

```bash
curl http://127.0.0.1:8000/healthz
curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:5173/
```

첫 명령은 설정된 브랜드가 포함된 JSON을, 두 번째 명령은 `200`을 반환해야
합니다.

같은 터미널 B에서 API 기본 테스트와 web 테스트를 실행합니다.

```bash
(cd app/api && uv run --frozen pytest -q)
(cd app/web && npm test && npm run build)
(cd app/web && npm run test:browser)
git check-ignore .env
```

`npm run test:browser`는 Lab 6에서 쓸 Playwright runway가 동작하는지 확인하는
예제 시나리오입니다. 여기서는 통과해야 하며, Lab 6에서 실제 인수 시나리오로
교체합니다.

합의된 project-scope 스킬 15개(외부 13개: Matt Pocock 12개와 Anthropic
`frontend-design`, 이 저장소에서 직접 작성한 2개: `workflow`,
`microsoft-agent-framework`)는 `.agents/skills/`에 미리 설치되어 있습니다.
잠금 파일과 설치 상태를 확인합니다.

```text
./scripts/check-repo.sh
/skills
```

Claude는 `github.copilot.chat.claudeAgent.enabled`가 활성화됐는지 확인하고
Copilot 또는 Anthropic 인증 경로를 설정합니다. Codex는 `chat.agentHost.codexAgent.enabled`를 활성화합니다.
Terra 검증에는 GitHub 로그인과 Copilot Pro+ 혹은 Business, Enterprise가 필요합니다.

VS Code Chat view(또는 Agents 창)에서 다음 권장 조합을 확인합니다.

- Copilot + GPT-5.6 Sol: 요구사항 디스커버리와 필수 prototype
- Claude + Claude Opus 4.8: 설계, 아키텍처
- Copilot + GPT-5.6 Sol: 구현
- Codex + GPT-5.6 Terra: 독립 검증

권장 조합을 사용할 수 없으면 역할에 필요한 skill을 지원하는 다른 조합으로
진행할 수 있습니다. 역할별 fresh session과 구현/검증 분리는 유지하고 실제
조합을 `HANDOFF`와 UAT report에 기록합니다. strict preflight를 실행할 때
권장 조합 확인 결과는 다음처럼 전달합니다.

```bash
WORKSHOP_GPT56_SOL_CONFIRMED=1 \
WORKSHOP_CLAUDE_OPUS48_CONFIRMED=1 \
WORKSHOP_CODEX_TERRA_CONFIRMED=1 \
  ./scripts/preflight.sh --strict
```

## 종료 조건

- 리포를 clone했고 최종 PR이 필요하면 자신의 fork를 origin으로 설정했다.
- 필수 project skill을 확인했고 네 역할의 권장 harness/model 가용성을 점검했다.
- 두 서버가 시작되고 health가 설정된 브랜드를 반환한다.
- API 기본 테스트, web test/build와 브라우저 runway smoke가 통과한다.
- `.env`가 무시되며 APIM key가 채팅이나 commit에 없다.
- Python `e2e`가 실제 APIM을 호출하는 운영자 승인 gate임을 확인했다.

## 막힐 때

- 권장 모델이나 harness가 없으면 대체 조합과 실제 선택을 durable artifact에 기록한다.
- 역할에 필요한 skill 자체가 없으면 운영자에게 알린다.
- health만 실패하면 APIM보다 먼저 8000 포트와 Python 환경을 확인한다.
- 5173이 응답하지 않으면 터미널 A의 `dev.sh`가 아직 살아 있는지 확인한다.
- `npm run test:browser`가 브라우저를 못 찾으면 `cd app/web && npx playwright
  install chromium`을 실행한다.
- `.env`가 추적되면 값을 지우고 운영자에게 key rotation을 요청한다.
- 최종 PR 단계에서 push 권한이 없으면 자신의 fork를 origin으로 설정한다.
