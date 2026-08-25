# 진행자 노트

강사는 참가자가 명령을 외우는지보다 역할에 맞는 skill, agent runtime,
model을 선택하는지 관찰합니다.

- 설계: Claude agent + Opus 5, `grill-with-docs`부터 `to-tickets`까지 유지
- 구현: native + GPT-5.6 Sol, ticket마다 새 세션
- 검증: native + Sonnet 5, spec 선독과 독립 UAT

막히면 답을 주기보다 현재 durable artifact가 무엇인지 묻습니다.
