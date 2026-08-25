# 멀티 하네스 · 멀티 모델 AI 개발 워크샵

모바일 단말 · 온디바이스 AI 도메인을 소재로, **하나의 작업을 여러 하네스(harness)와 여러 모델에 걸쳐 인수인계하며 완성**하는 1일 핸즈온 워크샵입니다.

## 무엇을 배우는가

- **하네스 · 모델 · 런타임은 서로 다른 축**임을 구분하고, 단계마다 적합한 조합을 고른다.
- 하네스가 바뀌어도 살아남는 **인수인계 규약(Handoff Contract)** 을 쓰고 지킨다.
- **GitHub Issue를 세션 간 유일한 상태 저장소**로 삼아 계획 · 결정 · 진척을 관리한다.
- 구현과 **최소 한 축 이상 다른 조합 · 새 세션**에서 검증(UAT)을 수행해 자기 검증의 함정을 피한다.

## 30초 요약

> 하네스와 모델은 갈아끼우는 부품이다. 인수인계는 채팅이 아니라 레포 파일과 GitHub Issue로 한다.

기획 · 요구정의는 Claude 하네스 + Claude Opus 5로, 구현은 Copilot 하네스 + GPT-5.6 Sol로, 검증 · 수락 테스트는 다른 하네스 또는 GPT-5.6 Terra의 새 세션으로 수행합니다. 세 단계를 잇는 것은 대화 히스토리가 아니라 커밋된 파일과 이슈입니다.

## 빠른 시작

```bash
./scripts/preflight.sh          # 환경 검증 (Lab 0)
cd seed && npm test && cd ..    # 시드 코드베이스 테스트 (의존성 설치 불필요)
./scripts/bootstrap-labels.sh   # 워크샵 이슈 라벨 생성
```

## 리포 구조

| 경로 | 내용 |
| --- | --- |
| `AGENTS.md` | 모든 하네스가 읽는 정본 작업 규칙 |
| `CLAUDE.md` | `AGENTS.md`를 가리키는 포인터 |
| `seed/` | 워크샵 과제의 출발점이 되는 의존성 0개 TypeScript SDK |
| `scripts/` | 환경 검증 · 이슈 오케스트레이션 · 리포 게이트 스크립트 |
| `docs/` | 개념 문서, 랩 가이드, 레퍼런스, 강사 자료 |
| `.github/agents/` | `architect` · `implementer` · `verifier` 에이전트 프로파일 |
| `.github/skills/` | `handoff-brief` · `issue-map` · `uat-verify` 스킬 |
| `docs/prompts/` | Claude native 역할과 GHEC Codex cloud 검증 계약 |
| `docs/templates/` | 요구사항 · 아키텍처 · UAT · 팀 규칙 산출물 템플릿 |
| `docs/uat/` | 구현과 독립적으로 고정된 수락 테스트 |

## 랩 목차

| 랩 | 제목 | 시간 | 하네스 / 모델 |
| --- | --- | --- | --- |
| [Lab 0](docs/labs/lab0-preflight.md) | 프리플라이트 | 30분 | — |
| [Lab 1](docs/labs/lab1-discovery.md) | 문제 발견과 요구 정의 | 60분 | Claude / Claude Opus 5 |
| [Lab 2](docs/labs/lab2-architecture.md) | 결정과 아키텍처 | 45분 | Claude / Claude Opus 5 |
| [Lab 3](docs/labs/lab3-implementation.md) | 구현 | 90분 | Copilot / GPT-5.6 Sol |
| [Lab 4](docs/labs/lab4-verification.md) | 검증과 수락 테스트 | 60분 | 기본: Copilot / GPT-5.6 Terra · 옵션: GHEC Codex cloud agent |
| [Lab 5](docs/labs/lab5-multiruntime.md) | 멀티 런타임 (옵션) | 45분 | Copilot / 임의 |
| [Lab 6](docs/labs/lab6-integration.md) | 통합과 회고 | 40분 | — |

## 참고 문서

랩을 진행하기 전에 [개념 문서](docs/00-concepts.md)를 먼저 읽으세요. 하네스 · 모델 · 런타임 세 축의 구분이 하루 전체의 전제입니다.

| 문서 | 언제 보는가 |
| --- | --- |
| [모델 · 하네스 호환성](docs/reference/model-harness-matrix.md) | 어떤 조합이 실제로 가능한지 확인할 때 |
| [인수인계 규약](docs/reference/handoff-contract.md) | 다음 단계로 넘기기 직전 |
| [이슈 규약](docs/reference/issue-conventions.md) | 맵 · 결정 · 작업 이슈를 만들 때 |
| [프레임워크 지형도](docs/reference/framework-landscape.md) | 워크샵 이후 팀에 무엇을 도입할지 정할 때 |
| [출처](docs/reference/sources.md) | 사실 확인이 필요할 때 |

강사용 자료는 [`docs/instructor/`](docs/instructor/timebox.md)에 있습니다: 타임박스, 사전 체크리스트, 트러블슈팅, 최소 복구 경로, 진행 노트, 평가 루브릭.

## 라이선스와 사용 조건

사내 교육 목적으로 제작되었습니다. 특정 고객사를 식별할 수 있는 정보는 포함하지 않으며, 소재로 쓰인 도메인(모바일 단말 · 온디바이스 AI)은 일반적인 예시입니다.
