# Lab 0 — 아우터 하네스 조립 (45분)

## 목표

Matt Pocock 스킬을 프로젝트에 설치·갱신하고 GHCP에서 사용할 개발
워크플로를 직접 조립합니다.

## 1. 환경 기준선

채팅에서 에이전트에게 다음을 요청합니다.

```text
scripts/preflight.sh를 실행해 환경과 두 sample track의 기준선을 확인하세요.
```

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
