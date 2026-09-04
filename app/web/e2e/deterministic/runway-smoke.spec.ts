import { expect, test } from "@playwright/test";

// Lab 0에서 Playwright runway가 동작하는지 확인하는 최소 시나리오입니다.
// Lab 6에서 이 파일을 실제 인수 시나리오(loading, answer, URL citations,
// no-evidence, actionable 오류)로 교체하세요.
test("runway smoke: 백엔드 준비 상태를 route interception으로 렌더링한다", async ({
  page,
}) => {
  await page.route("**/healthz", async (route) => {
    await route.fulfill({
      status: 200,
      contentType: "application/json",
      body: JSON.stringify({ status: "ok", brand: "한빛전자" }),
    });
  });

  await page.goto("/");

  await expect(page.getByRole("heading", { level: 1 })).toContainText("한빛전자");
  await expect(page.getByText("백엔드 준비됨")).toBeVisible();
});
