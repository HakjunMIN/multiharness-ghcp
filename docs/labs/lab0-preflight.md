# Lab 0 — 아우터 하네스 조립 (30분)

## 이 랩에서 배우는 것

- 개발 워크플로를 스킬 설치로 조립한다. 스크립트를 외우지 않는다.
- 설치 결과를 lockfile로 고정해 다음 세션이 같은 하네스를 재현하게 한다.
- 모델을 바꾸지 않고 도메인 스킬로 하네스 능력을 확장한다.
- 세 역할에 필요한 agent runtime과 model이 실제로 열리는지 먼저 확인한다.

## 시작 전 상태

- GHCP CLI에 로그인되어 있고 `gh auth status`가 정상이다.
- Node와 `uv`가 설치되어 있다.
- 리포를 clone했고 `git status`가 깨끗하다.

## 1. 환경 기준선

채팅에서 에이전트에게 다음을 요청합니다.

```text
scripts/preflight.sh를 실행해 환경과 두 sample track의 기준선을 확인하세요.
```

`FAIL`이 하나라도 있으면 다음 단계로 넘어가지 않습니다. 이 시점의 seed
11개, agent-seed 27개 통과가 이후 모든 비교의 기준선입니다.

## 2. Matt 스킬 설치와 갱신

GHCP 채팅에서 실행합니다.

```text
!DISABLE_TELEMETRY=1 npx skills@latest add mattpocock/skills --agent github-copilot --copy
```

project scope에서 `scripts/required-matt-skills.txt`의 스킬을 모두
고릅니다. `--copy`는 설치 파일을 리포에 커밋할 수 있게 합니다. 이어서
갱신과 노출을 확인합니다.

```text
!DISABLE_TELEMETRY=1 npx skills update
/skills
```

업데이트 diff를 읽고 로컬 변경을 자동으로 덮어쓰지 않습니다.

## 3. 리포 설정

```text
/setup-matt-pocock-skills
```

GitHub Issues, 기본 triage labels, single-context domain docs를 선택합니다.
`skills-lock.json`, 설치된 스킬, `CONTEXT.md`, `docs/agents/*`를 커밋합니다.

## 4. 도메인 스킬 확장

`/skills`와 plugin 검색을 이용해 Microsoft Agent Framework 또는 Foundry
스킬을 설치합니다. 설치 전 manifest와 권한을 읽습니다. 이것이 모델을
바꾸지 않고 하네스의 능력을 확장하는 두 번째 경험입니다.

## 5. 런타임 확인

설계 조합:

```text
/agent Claude
/model Claude Opus 5
```

새 GHCP native 세션에서 구현·검증 모델도 확인합니다.

```text
/model GPT-5.6 Sol
/model Claude Sonnet 5
```

어느 조합이든 보이지 않으면 대체하지 말고 강사에게 알립니다. 마지막으로
`node scripts/check-matt-skills.mjs --required`와 리포 검사를 에이전트에게
실행시킵니다.

## 종료 조건

- 필수 Matt 스킬이 모두 `/skills`에 보인다.
- `node scripts/check-matt-skills.mjs --required`가 통과한다.
- `skills-lock.json`, 설치된 스킬, `CONTEXT.md`, `docs/agents/*`가 커밋됐다.
- 세 역할의 agent runtime과 model을 모두 직접 열어 봤다.

## 막힐 때

- 스킬이 안 보이면 project scope와 GitHub Copilot 대상을 확인하고 새 세션을 연다.
- 설치가 사내 프록시에서 막히면 승인된 package feed 설정을 확인한다.
- 모델이 없으면 다른 모델로 대체하지 말고 여기서 멈추고 강사에게 알린다.
