# Lab 6 - 독립 review와 UAT (60분)

## 이 랩에서 배우는 것

- 구현 문맥을 상속하지 않는 verifier를 운영한다.
- standards, spec, black-box UAT를 분리한다.
- 결함을 재현 테스트와 Issue로 넘기고 구현은 고치지 않는다.

## Runtime card

```text
Host: GitHub Copilot
Agent runtime: native coding agent
Model: Claude Sonnet 5 (/model Claude Sonnet 5)
Context: 구현 세션과 분리된 새 세션
```

```text
/new
/model Claude Sonnet 5
/code-review main
```

[UAT matrix](../uat/acceptance-matrix.md)를 사용해 API envelope, structured citations, region domain rule, telemetry opt-out, no-evidence behavior, 429를 검증한다. full 결과가 있을 때만 React 상담과 citation rendering을 추가한다.

verifier는 구현 코드를 수정하지 않는다. 결함이면 가장 작은 failing reproduction test를 추가할 수 있고, evidence와 severity를 담은 defect Issue를 만든다. 구현자는 별도 세션에서 수정한다.

## 종료 조건

- standards/spec findings와 UAT verdict가 분리된 report가 있다.
- 발견한 결함마다 재현 근거와 defect Issue가 있다.
- verifier가 production implementation을 수정하지 않았다.

## 막힐 때

- 구현 의도를 추측하지 말고 spec acceptance criteria와 black-box response를 기준으로 판정한다.
- live infrastructure 결함은 제품 결함과 분리해 강사에게 route/status를 전달한다.
