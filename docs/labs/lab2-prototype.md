# Lab 2 - 상담 UI prototype

## 이 랩에서 배우는 것

- 구현 전에 React 상담 화면의 상태와 시각 언어를 실제 시안으로 결정한다.
- 선택 시안을 구현 세션이 그대로 이식할 정적 참조로 남긴다.
- throwaway 탐색과 production 구현을 분리한다.

## Runtime card

```text
Host: VS Code
Recommended agent runtime: Copilot harness (New Chat → Session Target: Copilot)
Recommended model: GPT-5.6 Sol
Context: fresh session. Lab 1의 커밋된 discovery와 ADR만 읽는다.
```

## Prototype

New Chat에서 `AGENTS.md`, `CONTEXT.md`, `docs/work/<feature>/discovery.md`와
연결된 ADR을 읽고 다음을 실행합니다.

```text
/prototype

질문 입력, loading, answer와 citations, no-evidence, 오류 상태를 비교할 수 있는
시안을 만드세요. frontend-design을 적용하고 한글 본문은 나눔고딕을 우선하세요.
실제 APIM 호출, mutation, persistence는 넣지 마세요.
```

모든 시안 source는 `prototype/<feature>-<slug>` branch에 보존합니다. 사용자가
고른 시안은 main의 다음 경로에도 정적 참조로 커밋합니다.

```text
docs/work/<feature>/prototype.md
docs/work/<feature>/prototype/index.html
docs/work/<feature>/prototype/styles.css
docs/work/<feature>/prototype/tokens.md
docs/work/<feature>/prototype/<state>.png
```

`prototype.md`에는 `Status: decided`, `Question`, `Selected`, `Rationale`,
`Prototype ref`를 기록합니다. `tokens.md`에는 `app/web/src/styles.css`로 옮길
CSS 변수, 나눔고딕 본문 서체, 제목 서체, 간격과 색 토큰을 기록합니다. 질문,
loading, answer와 citations, no-evidence, 오류의 상태별 스크린샷과 landmark,
접근성 이름도 남깁니다. credential이나 실제 고객 정보는 포함하지 않습니다.

## 종료 조건

- `prototype.md`가 `Status: decided`이고 유효한 throwaway branch commit을 가리킨다.
- `docs/work/<feature>/prototype/`에 선택 시안의 HTML, CSS, `tokens.md`가 있다.
- 다섯 상태의 상태별 스크린샷과 landmark가 기록됐다.
- 정적 참조가 main에 커밋됐고 planning을 막는 UI 질문이 없다.

## 막힐 때

- 시안이 비슷하면 색보다 정보 구조와 상태 전환을 더 크게 다르게 만든다.
- 실제 API가 필요해 보이면 fixture data를 쓰고 네트워크를 연결하지 않는다.
- 선택 후 production 수준으로 다듬지 않는다. 구현은 Lab 7의 책임이다.
