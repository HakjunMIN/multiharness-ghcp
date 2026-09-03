# 상담 UI 프로토타입 발견 결정

## 세션

- Host: VS Code
- Harness: Copilot SDK
- Model: host에서 구체 모델 ID를 노출하지 않음
- Skill: `brainstorming`
- Date: 2026-09-03

## 목적

제품 상담 앱의 production UI를 구현하기 전에 사용자가 실제 브라우저에서
구조적으로 다른 화면을 비교하고, 질문 입력부터 답변과 구조화된 출처 확인까지의
정보 구조를 결정한다.

## 승인된 결정

1. `mattpocock/skills`의 `prototype` 스킬만 저장소의
   `.agents/skills/prototype/`에 project scope로 설치한다.
2. 설치 출처와 해시는 `skills-lock.json`에 기록한다. 전역 스킬은 설치하거나
   사용하지 않는다.
3. UI prototype은 Matt Pocock 스킬의 UI branch와 기존 화면을 활용하는
   sub-shape A를 따른다.
4. 기존 `/` 화면에서 `?variant=A`, `?variant=B`, `?variant=C`로 세 가지 시안을
   전환한다. variant switcher는 개발 환경에서만 보인다.
5. 기존 health 조회와 브랜드 표시는 유지한다. 아직 구현되지 않은 상담 결과는
   네트워크를 사용하지 않는 고정 샘플 answer와 citations로 표현한다.
6. 세 시안은 색상만 달리하지 않고 레이아웃, 정보 우선순위와 주 동작을 다르게
   한다.
   - A: 질문 중심의 단일 대화 흐름
   - B: 답변과 출처를 나란히 두는 근거 우선 분할 화면
   - C: 질문, 핵심 결론과 출처를 단계별로 펼치는 상담 리포트
7. 사용자는 브라우저의 switcher 버튼이나 좌우 화살표 키로 시안을 바꾸고, 선택한
   시안과 이유를 이 feature의 durable artifact에 기록한다.
8. prototype에는 실제 mutation, persistence, live APIM 호출을 넣지 않는다.
9. prototype variant에는 production 수준의 테스트나 추상화를 추가하지 않는다.
   설치 무결성과 앱 실행성만 기존 저장소 검증으로 확인한다.
10. 선택 후 승자는 production 오류 처리와 테스트를 갖춘 코드로 다시 구현한다.
    prototype 전체는 throwaway branch에 primary source로 보존하고 main에는 선택된
    결정과 production 구현만 남긴다.

## 확인한 사실과 출처

- 현재 React runway의 `/` 화면은 health를 조회해 브랜드와 백엔드 준비 상태를
  표시하고 상담 작업 영역은 비어 있다:
  [`app/web/src/App.tsx`](../../../app/web/src/App.tsx).
- 웹 앱은 React 19, TypeScript, Vite와 Vitest를 사용한다:
  [`app/web/package.json`](../../../app/web/package.json).
- 저장소는 외부 project-scope 스킬을 `.agents/skills/`에 설치하고
  `skills-lock.json`으로 출처와 해시를 고정한다:
  [`docs/reference/workflow.md`](../../reference/workflow.md),
  [`skills-lock.json`](../../../skills-lock.json).
- Matt Pocock의 `prototype` UI 지침은 기존 route에서 `?variant=`로 구조적으로
  다른 시안을 전환하는 sub-shape A를 우선하고, 선택 후 prototype을 main에서
  제거해 throwaway branch에 보존하도록 한다:
  [mattpocock/skills prototype](https://github.com/mattpocock/skills/tree/main/skills/engineering/prototype).
- skills CLI는 GitHub 저장소의 skill을 project에 설치할 수 있다:
  [skills CLI reference](https://skills.sh/docs/cli).

## 제약

- 고정 HTTP 경계인 `POST /api/consult`의 시작 request 필드 `question`과 응답 필드
  `answer`를 바꾸지 않는다.
- runtime credential과 실제 고객 식별 정보는 prototype, 로그, 문서와 commit에
  남기지 않는다.
- 커밋 기본 브랜드는 `한빛전자`를 사용한다.
- 한글 본문 서체는 나눔고딕을 우선한다.
- 기본 unit/contract 검증은 네트워크를 사용하지 않는다.
- 현재 worktree의 기존 미커밋 변경은 건드리거나 되돌리지 않는다.

## 의존성

- Node.js와 기존 `app/web` 의존성이 설치되어 있어야 한다.
- 스킬 설치 시 `npx skills`가 `prototype`을 개별 선택해 설치할 수 있어야 한다.
- production 구현 전 별도 기획 세션에서 이 문서를 입력으로 spec과 ticket을
  발행해야 한다.

## 검증 경계

```bash
(cd app/web && npm test && npm run build)
for test in tests/scripts/test-*.sh; do "$test"; done
./scripts/check-repo.sh
```

prototype이 선택된 뒤 production 구현 ticket은 별도의 focused UI test를
정의한다. live APIM 검증은 이 prototype 범위 밖이다.

## 열린 질문

없음. 구현 중 발생하는 미세한 시각 선택은 세 variant를 브라우저에서 비교한
사용자 피드백으로 닫는다.

## 관련 결정

- 공유 경계: [`CONTEXT.md`](../../../CONTEXT.md)
- 작업 규칙: [`AGENTS.md`](../../../AGENTS.md)
- Spec과 ticket 절차:
  [`docs/labs/lab2-spec-tickets.md`](../../labs/lab2-spec-tickets.md)
- 별도 ADR은 필요하지 않다. prototype은 되돌릴 수 있는 일회성 설계 도구이며
  production 경계는 바꾸지 않는다.
