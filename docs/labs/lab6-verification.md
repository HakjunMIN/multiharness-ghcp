# Lab 6 - 독립 검증

## 이 랩에서 배우는 것

- 구현 문맥을 상속하지 않는 verifier를 운영한다.
- standards, spec, black-box UAT를 분리한다.
- 결함을 재현 테스트와 local defect 문서로 넘기고 구현은 고치지 않는다.

## Runtime card

```text
Host: VS Code
Agent runtime: Codex harness (New Chat → Session Target: Codex)
Model: GPT-5.6 Terra, Copilot-backed provider (language model picker)
Context: 구현 세션과 분리된 새 세션
```

구현 세션을 handoff하지 않습니다. New Chat으로 fresh session을 열고 Session
Target을 local Codex로, provider를 Copilot-backed로, model을 GPT-5.6 Terra로
선택한 뒤 채팅에 다음을 입력합니다. Cloud Codex를 선택하지 않습니다.

```text
/code-review main
```

[UAT matrix](../uat/acceptance-matrix.md)를 사용해 API envelope, structured
citations, no-evidence behavior, 429를 검증한다. full 결과가 있을 때만 React
상담과 citation rendering을 추가한다.

verifier는 구현 코드를 수정하지 않습니다. 결함이면 가장 작은 failing
reproduction test를 추가할 수 있고, evidence와 severity를 담은 local defect
문서를 `docs/work/<feature>/defects/`에 만듭니다. 구현자는 별도 세션에서
수정합니다.

## 종료 조건

- standards/spec findings와 UAT verdict가 분리된 report가 있다.
- 발견한 결함마다 재현 근거와 local defect 문서가 있다.
- verifier가 production implementation을 수정하지 않았다.

## 막힐 때

- 구현 의도를 추측하지 말고 spec acceptance criteria와 black-box response를 기준으로 판정한다.
- live infrastructure 결함은 제품 결함과 분리해 운영자에게 route/status를 전달한다.
