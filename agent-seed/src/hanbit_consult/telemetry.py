"""상담 텔레메트리.

수집한 이벤트는 프로세스 안의 리스트에 쌓인다. 외부로 나가지 않는다.
지금 구현에는 알려진 설계 부채가 있다. agent-seed/README.md 를 보라.
"""

from __future__ import annotations

from dataclasses import dataclass, field

from .types import Answer, Question


@dataclass(frozen=True)
class TelemetryEvent:
    """상담 한 건에 대한 기록."""

    question_text: str
    region: str
    used_web_search: bool
    citation_count: int


@dataclass
class TelemetrySink:
    """수집된 이벤트를 담는 곳."""

    events: list[TelemetryEvent] = field(default_factory=list)

    def record(self, question: Question, answer: Answer) -> None:
        """상담 한 건을 기록한다."""
        self.events.append(
            TelemetryEvent(
                question_text=question.text,
                region=question.region,
                used_web_search=answer.used_web_search,
                citation_count=len(answer.citations),
            )
        )

    def clear(self) -> None:
        self.events.clear()
