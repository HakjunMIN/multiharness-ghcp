# 프레임워크 지형과 Wayfinder-lite

이 문서는 “이 워크숍의 Wayfinder-lite는 어디에서 왔고, 우리 팀은 다음에 무엇을 도입해야 하는가?”에 답한다.

| 프레임워크 | 해결하는 문제 | 도입 판단 기준 |
|---|---|---|
| Superpowers (obra) | 한 세션 안의 엔지니어링 규율과 명시적 검증 | 에이전트가 “다 됐습니다”라고 거짓 보고할 때 |
| Wayfinder (mattpocock) | 한 세션에 안 담기는 대규모 작업의 결정 매핑 | 무엇을 만들지가 아직 안 정해졌을 때 |
| GitHub Spec Kit | 스펙→플랜→태스크→구현 파이프라인, 30+ 에이전트 지원 | 요구사항이 명확하고 규모가 클 때 |
| BMAD-METHOD | Clarify→Plan→Build&verify→Learn, PRD/아키텍처 산출물 | 제품 문서 체계가 필요할 때 |
| OpenSpec | 벤더 중립 `.agents/skills/`, 하네스 중립성 최강 | 여러 하네스를 실제로 섞어 쓸 때 |
| Agent OS | 기존 코드베이스의 암묵적 표준을 발굴해 주입 | 레거시에 에이전트를 붙일 때 |

## Wayfinder: 구현 계획이 아닌 결정 계획

Wayfinder는 **구현 계획(implementation planning)이 아니라 결정 계획(decision planning)**이다. 아직 정해지지 않은 것을 질문 단위로 외부화하고, 여러 세션이 같은 결정 지형을 탐색하게 한다.

하나의 맵 이슈 본문은 다음 섹션을 가진다.

- `## Destination`
- `## Notes`
- `## Decisions so far`
- `## Not yet specified`
- `## Out of scope`

각 자식 이슈는 정확히 하나의 결정을 다룬다. 맵은 결정 내용을 중복 저장하는 장소가 아니라, 자식 결정 이슈를 찾아가는 인덱스다. 이후 흐름은 `wayfinder → to-spec → to-tickets → implement`다.

Wayfinder 스킬 설치 명령은 다음과 같다.

```bash
npx skills@latest add mattpocock/skills
```

원본과 설치 정보는 [참고 자료](sources.md)의 Wayfinder 항목에서 확인한다.

## 이 워크숍의 Wayfinder-lite

워크숍은 Wayfinder에서 다음 요소를 채택했다.

- 맵 이슈(map issue)
- 결정 이슈(decision issue)
- 프런티어(frontier)
- 담당자 지정에 의한 선점(claim-by-assignee)

반면 세밀한 결정 유형 레이블(`research|prototype|grilling`)과 장기 다중 세션 운영은 제외했다. 하루짜리 워크숍에는 운영 비용이 학습 효과보다 커 과도하기 때문이다.

## 다음 도입의 구체적 출발점

요구사항이 명확하고 큰 작업을 표준 파이프라인으로 운영하려면 GitHub Spec Kit의 `/speckit-*` 명령부터 검토한다. 주요 단계는 `/speckit-constitution`, `/speckit-specify`, `/speckit-plan`, `/speckit-tasks`, `/speckit-implement`, `/speckit-converge`, `/speckit-taskstoissues`다.

여러 하네스를 실제로 혼합하며 벤더 중립 워크플로가 필요하면 OpenSpec의 `/opsx:explore`, `/opsx:propose`, `/opsx:apply`, `/opsx:archive`를 도입 진입점으로 삼는다. 프레임워크 원본 링크는 [참고 자료](sources.md)에 정리되어 있다.
