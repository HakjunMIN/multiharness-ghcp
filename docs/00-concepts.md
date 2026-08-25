# 개념

- **Host:** 대화, tools, sessions를 제공하는 GitHub Copilot CLI
- **Agent runtime:** GHCP native 또는 GHCP 안의 third-party Claude
- **Model:** Opus 5, GPT-5.6 Sol, Sonnet 5 같은 추론 모델
- **Skill:** agent가 재사용하는 역할·규율·절차
- **Durable state:** `CONTEXT.md`, ADR, Issues, commits처럼 세션 밖에 남는 상태

이 워크샵은 같은 host에서 agent runtime과 model을 역할별로 바꾸며,
Matt Pocock skills를 공통 개발 흐름으로 사용합니다.
