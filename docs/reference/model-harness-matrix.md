# 모델과 하네스 호환성

**하네스(harness)와 모델(model)은 자유롭게 조합할 수 없다.** 하네스마다 실행 환경과 모델 카탈로그가 다르므로, 모델 이름만 보고 실행 조합을 설계하면 안 된다.

| 하네스 | 사용 가능한 모델 |
|---|---|
| Copilot CLI / Copilot 클라우드 에이전트 | Claude Opus 5, GPT-5.6 Sol, GPT-5.6 Terra 등 Copilot 모델 카탈로그 전체 |
| Claude 파트너 클라우드 하네스 | Opus 4.5 / 4.6 / 4.7, Sonnet 4.5 / 4.6, Auto 만 |
| GHEC OpenAI Codex third-party coding agent | GPT-5.3-Codex, GPT-5.4, GPT-5.4 nano, Auto 만 |

직관적으로 원할 수 있는 **“Codex 하네스 + GPT-5.6 Terra” 조합은 파트너 클라우드 하네스에 존재하지 않는다.** 따라서 Lab 4는 다음 두 경로를 제공한다.

- **경로 A(옵션):** GHEC Codex cloud agent + Codex가 실제로 제공하는 모델
- **경로 B:** Copilot 하네스 + GPT-5.6 Terra + 새 세션(NEW session)

이 워크숍이 가르치는 원칙은 특정 조합 자체가 아니다.

> **검증은 구현과 최소 한 축(하네스 또는 모델) 이상 달라야 하며, 반드시 새 세션에서 한다.**

같은 세션 안에서 구현한 에이전트가 스스로 확인하는 것은 검증이 아니다. 새 세션은 구현 과정에서 형성된 가정과 채팅 문맥을 끊고, 커밋된 산출물과 재현 가능한 명령만으로 결과를 평가하게 한다.

## 하네스가 결정하는 것

하네스는 에이전트가 **어디에서 실행되는지**, **어떤 도구와 모델을 사용할 수 있는지**, **코드 변경을 어떤 방식으로 적용하는지**를 결정한다.

- Claude 하네스 = Claude Agent SDK
- GHEC Codex cloud agent = GitHub Issue나 prompt를 비동기로 수행하고 draft PR을 만드는 OpenAI Codex third-party coding agent
- Copilot 하네스 = Copilot SDK

VS Code에는 로컬 Codex 하네스도 있지만 이 워크샵의 경로 A에는 사용하지
않는다. 경로 A는 GHEC의 cloud agent 정책, 리포별 활성화, Actions minutes와
AI credits가 모두 준비된 팀만 선택한다.

최신 가용성은 [참고 자료](sources.md)의 공식 문서와 [GitHub의 서드파티 코딩 에이전트 모델 매트릭스](https://docs.github.com/en/copilot/concepts/agents/about-third-party-coding-agents#ai-models-for-third-party-agents)에서 확인한다.
