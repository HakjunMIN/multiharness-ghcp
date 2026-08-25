from hanbit_consult import Question, TelemetrySink, build_answer


def test_records_one_event_per_consultation() -> None:
    sink = TelemetrySink()
    question = Question("HB-9000 보증 기간 알려주세요", "KR")
    sink.record(question, build_answer(question))
    assert len(sink.events) == 1


def test_records_whether_web_search_was_used() -> None:
    sink = TelemetrySink()
    question = Question("HB-9000 보증 기간 알려주세요", "KR")
    sink.record(question, build_answer(question))
    assert sink.events[0].used_web_search is True


def test_clear_empties_the_sink() -> None:
    sink = TelemetrySink()
    question = Question("HB-9000 보증 기간 알려주세요", "KR")
    sink.record(question, build_answer(question))
    sink.clear()
    assert sink.events == []


def test_known_gap_the_opt_out_flag_does_not_stop_recording() -> None:
    """알려진 부채: 옵트아웃한 사용자의 상담도 그대로 기록된다.

    옵트아웃을 존중하도록 고치면 이 기대값을 뒤집어야 한다.
    """
    sink = TelemetrySink()
    question = Question("HB-9000 보증 기간 알려주세요", "KR", telemetry_opt_out=True)
    sink.record(question, build_answer(question))
    assert len(sink.events) == 1


def test_known_gap_the_raw_question_text_is_stored() -> None:
    """알려진 부채: 질문 원문이 그대로 저장된다.

    개인정보가 섞여 들어올 수 있는 경로다. 익명화하거나 저장하지 않도록
    고치면 이 기대값을 뒤집어야 한다.
    """
    sink = TelemetrySink()
    question = Question("제 전화번호는 010에서 시작합니다. HB-9000 보증 알려주세요", "KR")
    sink.record(question, build_answer(question))
    assert sink.events[0].question_text == question.text
