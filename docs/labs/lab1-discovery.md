# Lab 1 — 발견과 아키텍처 (45분)

## 이 랩에서 배우는 것

- 구현 전에 스킬이 주도하는 질문으로 모호함을 먼저 제거한다.
- 공유 용어를 `CONTEXT.md`에, 되돌리기 어려운 결정만 ADR에 남긴다.
- 설계 판단에 가장 강한 조합(Claude agent + Opus 5)을 의도적으로 고른다.
- 채팅이 사라져도 남는 durable artifact와 사라지는 대화를 구분한다.

## Runtime card

```text
Host: GitHub Copilot CLI
Agent runtime: Claude (/agent Claude)
Model: Claude Opus 5 (/model Claude Opus 5)
Context: Lab 2가 끝날 때까지 같은 대화 유지
```

`ts`는 `seed/src/`, `agent`는 `agent-seed/src/hanbit_consult/`를 탐색합니다.

## 시작 전 상태

- Lab 0의 종료 조건을 모두 만족했다.
- 트랙(`ts` 또는 `agent`) 하나를 선택했다.
- 아직 어떤 구현 코드도 수정하지 않았다.

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

## 최소한 답해야 할 질문

- 지역은 어디서 결정되며 알 수 없을 때의 기본값은 무엇인가?
- 어떤 지역이 외부 추론·웹검색을 금지하고, 금지되면 무엇으로 대체하는가?
- 텔레메트리 옵트아웃은 어느 경계에서 적용되는가?
- 이 동작을 관찰할 수 있는 public test seam은 무엇인가?

## 종료 조건

- 공유 용어가 `CONTEXT.md`에 있다.
- 어려운 결정은 ADR에 있다.
- spec 작성을 막는 질문이 없다.
- 코드를 수정하지 않았다.

## 막힐 때

- 질문이 끝없이 늘어나면 위 네 질문으로 범위를 좁힌다.
- 세부 구현 논쟁이 생기면 결정을 ADR 후보로 적고 Lab 2로 넘긴다.
- 세션을 잃었다면 커밋된 `CONTEXT.md`와 ADR로 새 Claude/Opus 세션을 시작한다.
