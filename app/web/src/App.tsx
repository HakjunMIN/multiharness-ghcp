import { useEffect, useState } from "react";
import { fetchHealth, type Health } from "./api";
import "./styles.css";

type State =
  | { status: "loading" }
  | { status: "ready"; health: Health }
  | { status: "unavailable" };

export default function App() {
  const [state, setState] = useState<State>({ status: "loading" });

  useEffect(() => {
    let active = true;
    fetchHealth().then(
      (health) => active && setState({ status: "ready", health }),
      () => active && setState({ status: "unavailable" }),
    );
    return () => {
      active = false;
    };
  }, []);

  if (state.status === "loading") {
    return <main className="status-shell">연결 확인 중</main>;
  }

  if (state.status === "unavailable") {
    return <main className="status-shell error">백엔드에 연결할 수 없습니다</main>;
  }

  return (
    <main className="workspace-shell">
      <header>
        <p className="status">백엔드 준비됨</p>
        <h1>{state.health.brand} 상담</h1>
      </header>
      <section aria-label="상담 작업 영역" />
    </main>
  );
}
