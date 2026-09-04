import { expect, test } from "@playwright/test";

// live suite는 route interception 없이 React -> FastAPI -> APIM -> Foundry IQ
// 전체 흐름을 검증합니다. 운영자가 승인한 gate에서만 실행하며 그 밖에서는
// 건너뜁니다. 실행하려면 ./scripts/dev.sh로 API와 web을 모두 띄운 뒤
// WORKSHOP_LIVE_GATE=1 npm run test:browser:live 로 실행하세요.
//
// Lab 6에서 이 파일을 실제 live 인수 시나리오로 교체하세요.
test.skip(
  !process.env.WORKSHOP_LIVE_GATE,
  "WORKSHOP_LIVE_GATE가 없어 live browser suite를 건너뜁니다",
);

test("runway live smoke: 실제 백엔드에서 brand를 렌더링한다", async ({ page }) => {
  await page.goto("/");

  await expect(page.getByText("백엔드 준비됨")).toBeVisible();
  await expect(page.getByRole("heading", { level: 1 })).not.toBeEmpty();
});
