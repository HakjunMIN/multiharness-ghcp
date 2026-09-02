# Architecture Decision Records

이 디렉터리는 비어 있는 상태로 시작합니다. 제품 상담 에이전트를 만들면서
되돌리기 어려운 결정을 내릴 때마다 참가자가 직접 ADR을 추가합니다.

- 파일 이름은 `NNNN-<slug>.md`이며 `0001`부터 매깁니다.
- 형식은 `.agents/skills/domain-modeling/ADR-FORMAT.md`를 따릅니다.
- ADR로 남길 것은 되돌리기 어려운 결정입니다. APIM credential 경계, 근거가
  없을 때의 행동, retrieval adapter seam이 여기에 해당합니다.
- 용어와 공유 언어는 ADR이 아니라 [CONTEXT.md](../../CONTEXT.md)에 씁니다.
- 첫 ADR은 [Lab 1](../labs/lab1-discovery.md)에서 만듭니다.

진행 방식의 필수 interface인 역할 분리, fresh session, durable artifact는
과정의 주어진 전제입니다. 역할별 harness와 model은 권장 기본값이며 실제 선택은
각 artifact에 기록합니다. 이 운영 규칙은 ADR이 아니라
[AGENTS.md](../../AGENTS.md)와 [개념](../00-concepts.md)에 있습니다.
