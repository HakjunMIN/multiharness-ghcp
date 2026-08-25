# Lab 1 — 발견과 아키텍처 (75분)

## Runtime card

```text
Host: GitHub Copilot CLI
Agent runtime: Claude (/agent Claude)
Model: Claude Opus 5 (/model Claude Opus 5)
Context: Lab 2가 끝날 때까지 같은 대화 유지
```

`ts`는 `seed/src/`, `agent`는 `agent-seed/src/hanbit_consult/`를 탐색합니다.

## 시작

```text
/agent Claude
/model Claude Opus 5
/grill-with-docs

지역별 프라이버시 규제에 따라 외부 추론 또는 웹검색 라우팅을 강제하고
텔레메트리 옵트아웃을 지원해야 합니다. 선택한 sample track을 탐색하고,
구현하지 말고 공유 용어와 되돌리기 어려운 설계 결정을 먼저 명확히 해
주세요.
```

`grill-with-docs`가 사용하는 `domain-modeling`으로 `CONTEXT.md`를
정교하게 만들고, 되돌리기 어려운 결정만 `docs/adr/`에 기록합니다.

public interface나 test seam 자체가 불명확하면 `codebase-design`을
호출합니다. 여러 설계 세션이 필요한 거대한 작업일 때만 `wayfinder`를
사용합니다. 이 샘플 과제는 보통 바로 Lab 2로 이어집니다.

## 종료 조건

- 공유 용어가 `CONTEXT.md`에 있다.
- 어려운 결정은 ADR에 있다.
- spec 작성을 막는 질문이 없다.
- 코드를 수정하지 않았다.
