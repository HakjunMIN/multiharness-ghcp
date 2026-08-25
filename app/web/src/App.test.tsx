import { render, screen } from "@testing-library/react";
import { expect, test, vi } from "vitest";
import App from "./App";

vi.mock("./api", () => ({
  fetchHealth: vi.fn().mockResolvedValue({ status: "ok", brand: "한빛전자" }),
}));

test("shows the configured brand when the backend is ready", async () => {
  render(<App />);
  expect(screen.getByText("연결 확인 중")).toBeInTheDocument();
  expect(
    await screen.findByRole("heading", { name: "한빛전자 상담" }),
  ).toBeInTheDocument();
  expect(screen.getByText("백엔드 준비됨")).toBeInTheDocument();
});
