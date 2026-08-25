from hanbit_consult import OfflineIndex, SearchResult, web_search


def test_finds_a_document_by_keyword() -> None:
    results = OfflineIndex().search("HB-9000 보증")
    assert results
    assert any("보증" in r.title for r in results)


def test_returns_nothing_for_an_unknown_product() -> None:
    assert OfflineIndex().search("존재하지않는제품명에대하여") == []


def test_ranks_the_more_relevant_document_first() -> None:
    docs = [
        SearchResult("배터리 안내", "https://example.invalid/b", "배터리 배터리 배터리"),
        SearchResult("사양", "https://example.invalid/a", "배터리 용량"),
    ]
    results = OfflineIndex(docs).search("배터리")
    assert results[0].url == "https://example.invalid/b"


def test_limits_the_number_of_results() -> None:
    assert len(OfflineIndex().search("한빛전자", limit=2)) == 2


def test_the_tool_returns_a_string_with_source_urls() -> None:
    output = web_search("HB-9000 보증")
    assert "https://" in output


def test_the_tool_reports_an_empty_result_without_raising() -> None:
    assert web_search("존재하지않는제품명에대하여") == "검색 결과 없음"
