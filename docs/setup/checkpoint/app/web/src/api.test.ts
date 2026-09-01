import { afterEach, describe, expect, it, vi } from "vitest";
import { consult } from "./api";

describe("consult", () => {
  afterEach(() => {
    vi.restoreAllMocks();
  });

  it("posts the question and returns the answer with citations", async () => {
    const result = {
      answer: "공개 웹 근거를 찾았습니다.",
      citations: [{ title: "제품 개요", url: "https://example.invalid/products" }],
    };
    const fetchMock = vi.spyOn(globalThis, "fetch").mockResolvedValue(
      new Response(JSON.stringify(result), {
        status: 200,
        headers: { "Content-Type": "application/json" },
      }),
    );

    await expect(consult("제품 정보를 알려 주세요.")).resolves.toEqual(result);
    expect(fetchMock).toHaveBeenCalledWith("/api/consult", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ question: "제품 정보를 알려 주세요." }),
    });
  });
});
