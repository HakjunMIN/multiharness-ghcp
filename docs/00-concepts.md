# 개념

- **Host:** 대화, tools, sessions를 제공하는 GitHub Copilot CLI
- **Agent runtime:** GHCP native 또는 GHCP 안의 third-party Claude
- **Model:** Opus 5, GPT-5.6 Sol, Sonnet 5 같은 추론 모델
- **Skill:** agent가 재사용하는 역할·규율·절차
- **Durable state:** `CONTEXT.md`, ADR, Issues, commits처럼 세션 밖에 남는 상태
- **Runway:** health, 설정, test/build만 제공하고 domain behavior는 비워 둔 시작점
- **Core / full:** backend vertical slice와 이를 포함하는 React 확장 범위
- **Foundry IQ:** trusted web domains에서 cited evidence를 가져오는 retrieval 경계
- **APIM:** 참가자 key를 origin credential과 분리하고 quota를 적용하는 gateway

이 워크샵은 같은 host에서 agent runtime과 model을 역할별로 바꾸며,
Matt Pocock skills를 공통 개발 흐름으로 사용합니다. 기본 test는 deterministic하며
실제 APIM smoke는 `live` marker로 분리합니다.
