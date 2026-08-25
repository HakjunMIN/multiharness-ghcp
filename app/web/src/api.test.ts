import { afterEach, expect, test, vi } from "vitest";
import { fetchHealth } from "./api";

afterEach(() => {
  vi.unstubAllGlobals();
});

test("requests the backend health contract without changing API routes", async () => {
  const fetchMock = vi.fn().mockResolvedValue({
    ok: true,
    json: vi.fn().mockResolvedValue({ status: "ok", brand: "한빛전자" }),
  });
  vi.stubGlobal("fetch", fetchMock);

  await fetchHealth();

  expect(fetchMock).toHaveBeenCalledWith("/healthz");
});