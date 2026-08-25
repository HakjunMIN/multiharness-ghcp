# Matt Pocock 스킬 기반 개발 워크플로

이 워크샵은 `mattpocock/skills`의 main flow를 그대로 사용합니다.

```text
grill-with-docs → to-spec → to-tickets → implement → code-review + UAT
```

## 역할별 실행

설계 세션에서는 GHCP의 `/agent Claude`, `/model Claude Opus 5`를 선택하고
`/grill-with-docs`, `/to-spec`, `/to-tickets`를 한 문맥에서 수행합니다.
public test seam이 불명확하면 `codebase-design`, 여러 세션 규모의 안개 낀
작업일 때만 `wayfinder`를 사용합니다.

구현은 티켓마다 `/new`로 시작해 `/model GPT-5.6 Sol`과 `/implement #42`
를 사용합니다. `#42`는 실제 `ready-for-agent` 티켓 번호로 바꿉니다.

검증은 다시 `/new`로 시작해 GHCP native agent와
`/model Claude Sonnet 5`를 선택합니다. spec과 acceptance matrix를 먼저
읽고 `/code-review main`을 수행한 뒤 독립 UAT를 실행합니다.

## Session boundaries

설계 중에는 문맥을 유지하고, `to-tickets` 뒤에는 티켓이 다음 세션의
입력이 됩니다. Day 1 종료에는 `HANDOFF`에 첫 verify 명령을 남기고, Day 2는
이전 채팅 없이 commit된 durable state로 시작합니다. 구현은 ticket마다 새
세션, 검증은 구현 문맥과 분리된 새 세션을 사용합니다.

core는 Python API vertical slice이고 full은 core에 React UI를 더한 strict
superset입니다. 둘 다 같은 `POST /api/consult` contract를 사용합니다.

## 설치와 업데이트

```text
!DISABLE_TELEMETRY=1 npx skills@latest add mattpocock/skills --agent github-copilot --copy
!DISABLE_TELEMETRY=1 npx skills update
/setup-matt-pocock-skills
```

`skills-lock.json`과 설치 파일을 함께 커밋하며 업데이트 diff를 검토합니다.
