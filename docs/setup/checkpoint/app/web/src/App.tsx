import { FormEvent, useState } from "react";
import { consult, type ConsultResponse } from "./api";
import "./styles.css";

type ConsultationState =
  | { status: "idle" }
  | { status: "loading" }
  | { status: "answered"; result: ConsultResponse }
  | { status: "error"; message: string };

export default function App() {
  const [question, setQuestion] = useState("");
  const [state, setState] = useState<ConsultationState>({ status: "idle" });

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    const trimmedQuestion = question.trim();
    if (!trimmedQuestion) return;

    setState({ status: "loading" });
    try {
      const result = await consult(trimmedQuestion);
      setState({ status: "answered", result });
    } catch (error) {
      const message =
        error instanceof Error ? error.message : "알 수 없는 오류가 발생했습니다.";
      setState({ status: "error", message });
    }
  }

  return (
    <main className="consultation-shell">
      <header className="masthead">
        <p className="eyebrow">한빛전자 제품 안내</p>
        <h1>궁금한 제품을<br />근거와 함께 살펴보세요</h1>
        <p className="intro">
          공개된 제품 정보를 찾아 답하고, 확인에 사용한 출처를 함께 보여 드립니다.
        </p>
      </header>

      <form className="question-form" onSubmit={handleSubmit}>
        <label htmlFor="question">무엇을 알고 싶으신가요?</label>
        <div className="question-row">
          <input
            id="question"
            value={question}
            onChange={(event) => setQuestion(event.target.value)}
            placeholder="예: 이 제품의 주요 특징을 알려 주세요"
          />
          <button disabled={state.status === "loading"} type="submit">
            {state.status === "loading" ? "찾는 중" : "제품 정보 찾기"}
          </button>
        </div>
      </form>

      <section aria-live="polite" className="result-region">
        {state.status === "idle" && (
          <p className="empty-state">질문을 입력하면 제품 정보와 출처가 여기에 표시됩니다.</p>
        )}
        {state.status === "loading" && (
          <p className="loading-state">공개된 제품 정보를 확인하고 있습니다.</p>
        )}
        {state.status === "error" && (
          <div className="error-state">
            <p>제품 정보를 불러오지 못했습니다. 잠시 후 다시 시도하세요.</p>
            <code>{state.message}</code>
          </div>
        )}
        {state.status === "answered" && (
          <article className="answer-card">
            <div className="answer-copy">
              <p className="section-label">답변</p>
              <p>{state.result.answer}</p>
            </div>
            <aside className="evidence-rail" aria-label="출처">
              <p className="section-label">확인한 출처</p>
              <ul>
                {state.result.citations.map((citation) => (
                  <li key={citation.url}>
                    <a href={citation.url} rel="noreferrer" target="_blank">
                      {citation.title}
                    </a>
                  </li>
                ))}
              </ul>
            </aside>
          </article>
        )}
      </section>
    </main>
  );
}
