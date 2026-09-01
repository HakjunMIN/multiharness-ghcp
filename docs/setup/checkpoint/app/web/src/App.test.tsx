import { fireEvent, render, screen, waitFor } from "@testing-library/react";
import { afterEach, expect, it, vi } from "vitest";
import App from "./App";

afterEach(() => {
  vi.restoreAllMocks();
});

it("renders the answer and structured citations for a question", async () => {
  vi.spyOn(globalThis, "fetch").mockResolvedValue(
    new Response(
      JSON.stringify({
        answer: "공개 웹 근거를 찾았습니다.",
        citations: [
          {
            title: "제품 개요",
            url: "https://example.invalid/products/overview",
          },
        ],
      }),
      { status: 200, headers: { "Content-Type": "application/json" } },
    ),
  );

  render(<App />);
  fireEvent.change(screen.getByLabelText("무엇을 알고 싶으신가요?"), {
    target: { value: "제품 정보를 알려 주세요." },
  });
  fireEvent.click(screen.getByRole("button", { name: "제품 정보 찾기" }));

  expect(screen.getByText("공개된 제품 정보를 확인하고 있습니다.")).toBeInTheDocument();
  await waitFor(() => {
    expect(screen.getByText("공개 웹 근거를 찾았습니다.")).toBeInTheDocument();
  });
  expect(screen.getByRole("link", { name: "제품 개요" })).toHaveAttribute(
    "href",
    "https://example.invalid/products/overview",
  );
});
