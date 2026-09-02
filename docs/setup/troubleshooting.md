# Troubleshooting

| 증상 | 조치 |
| --- | --- |
| project skill이 `/skills`에 없다 | `.agents/skills/`와 `skills-lock.json`을 확인하고 `npx skills experimental_install` 후 새 세션을 연다 |
| 권장 Claude agent가 없다 | `/to-spec`, `/to-tickets`를 실행할 수 있는 다른 planning runtime을 선택하고 spec에 실제 조합을 기록한다 |
| 권장 model이 없다 | 역할에 필요한 skill을 지원하는 다른 model을 선택하고 durable artifact에 실제 조합을 기록한다 |
| 설계 대화를 일찍 지웠다 | `CONTEXT.md`, ADR, local work items를 읽는 fresh planning 세션을 연다 |
| update가 로컬 skill과 충돌한다 | diff를 보존하고 upstream과 로컬 의도를 비교한다 |
| verifier가 구현 문맥을 안다 | New Chat으로 구현과 분리된 fresh verifier session을 열고 spec부터 다시 읽는다. 권장 조합은 local Codex + Copilot-backed GPT-5.6 Terra다 |
| APIM 401/403 | 참가자 key와 APIM product assignment를 확인한다 |
| APIM 404 | route와 knowledge base 이름을 확인한다 |
| APIM 429 | 해당 key의 reset을 기다리거나 운영자가 quota를 조정한다. 다른 key를 공유하지 않는다 |
| APIM 5xx | 운영자가 backend와 Azure AI Search resource health를 확인한다 |
| 응답에 citation이 없다 | Web Knowledge Source 접근과 smoke question을 확인한다 |
