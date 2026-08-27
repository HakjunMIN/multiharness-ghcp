# Lab 0 - runway 사전 점검 (30분)

## 이 랩에서 배우는 것

- Python API와 React web runway를 재현한다.
- 실제 비밀은 gitignored `.env`에만 둔다.
- 역할별 agent runtime과 model을 시작 전에 확인한다.

## 시작 전 상태

Node 22.18 이상, Python 3.11 이상, `uv`, GitHub CLI가 설치되어 있고 worktree가 깨끗해야 한다.

## 저장소 준비

이 랩은 `to-tickets`에서 실제 GitHub Issue를, 검증 단계에서 실제 PR을 발행한다. 강사 리포를 직접 clone하면 push 권한이 없거나, 참가자 전원이 같은 Issue/브랜치 번호를 공유하게 된다. **강사 리포를 자신의 GitHub 계정으로 fork한 뒤 fork를 clone한다.**

```bash
gh repo fork <instructor-org>/<repo> --clone --remote
cd <repo>
git remote -v   # origin=내 fork, upstream=강사 리포 확인
```

이후 모든 `gh issue create`, `git push`, PR은 자신의 fork(origin) 기준으로 수행한다. 강사 리포 변경 사항을 받아야 하면 `git fetch upstream && git merge upstream/main`을 쓴다.

## 실행

```bash
./scripts/preflight.sh
cp .env.example .env
# 강사가 준 APIM 값을 .env에 직접 넣는다. 채팅이나 커밋에 붙이지 않는다.
./scripts/dev.sh
curl http://127.0.0.1:8000/healthz
```

별도 터미널에서 API 기본 테스트와 web 테스트를 실행한다.

```bash
(cd app/api && uv run --frozen pytest -q)
(cd app/web && npm test && npm run build)
git check-ignore .env
```

Matt 스킬을 project scope에 설치하고 `/skills`로 노출을 확인한다.

```text
!DISABLE_TELEMETRY=1 npx skills@latest add mattpocock/skills --agent github-copilot --copy
!DISABLE_TELEMETRY=1 npx skills update
/skills
/setup-matt-pocock-skills
```

VS Code Chat view(또는 Agents 창)에서 새 세션을 하나씩 열어 다음 세 조합이 Session Target/model picker에 있는지 확인한다: Claude harness + Claude Opus 5, Copilot(native) harness + GPT-5.6 Sol, Copilot(native) harness + Claude Sonnet 5. `/agent`, `/model`처럼 harness나 model을 지정하는 슬래시 명령은 없다 — [harness와 model 선택 방법](../reference/model-harness-matrix.md)을 참고한다.

## 종료 조건

- 자신의 fork를 clone했고 `origin`이 자신의 fork를 가리킨다.
- 필수 스킬과 세 모델을 열 수 있다.
- 두 서버가 시작되고 health가 설정된 브랜드를 반환한다.
- API 기본 테스트와 web test/build가 통과한다.
- `.env`가 무시되며 APIM key가 채팅이나 commit에 없다.

## 막힐 때

- 모델이나 skill이 없으면 임의 대체하지 말고 강사에게 알린다.
- health만 실패하면 APIM보다 먼저 8000 포트와 Python 환경을 확인한다.
- `.env`가 추적되면 값을 지우고 강사에게 key rotation을 요청한다.
- `git remote -v`에 `origin`이 강사 리포를 가리키면 fork를 잊은 것이다. 강사 리포는 참가자에게 write 권한이 없으므로 이후 Issue/PR 발행이 막힌다.
