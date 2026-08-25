# 진행자 노트

참가자가 명령을 외우는지보다 역할에 맞는 skill, agent runtime, model을 선택하고 evidence를 남기는지 관찰합니다.

- 설계: Claude agent + Claude Opus 5, `grill-with-docs`부터 `to-tickets`까지 같은 문맥
- 구현: native + GPT-5.6 Sol, ticket마다 새 세션
- 검증: native + Claude Sonnet 5, 구현 문맥 없이 spec/UAT부터 읽기

질문에는 바로 답을 주기보다 현재 durable artifact와 검증 가능한 경계가 무엇인지 묻습니다. 실제 APIM 값은 강사 handout으로만 전달하고 화면 공유나 채팅에 노출하지 않습니다.

## 시간 운영

2일 모두 330분이며 [시간표](timebox.md)를 따릅니다. 지연 시 Lab 7, Lab 8 축소, Lab 5 full 확장 순서로 줄입니다. Lab 3, Lab 4, Lab 6의 세션 경계는 보존합니다.
