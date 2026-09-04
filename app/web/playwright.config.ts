import { defineConfig, devices } from "@playwright/test";

// scripts/dev.sh가 vite를 띄우는 주소와 같아야 재사용이 성립한다.
const BASE_URL = "http://127.0.0.1:5173";

// 브라우저 인수 시나리오는 두 project로 분리한다.
// - deterministic: route interception으로 외부 네트워크 없이 UI 상태를 검증한다.
// - live: interception 없이 React -> FastAPI -> APIM 전체 흐름을 검증하며
//   운영자가 승인한 gate에서만 실행한다.
export default defineConfig({
  testDir: "./e2e",
  fullyParallel: true,
  forbidOnly: Boolean(process.env.CI),
  retries: 0,
  workers: 1,
  // credential이 artifact에 남지 않도록 list reporter만 사용한다.
  reporter: [["list"]],
  use: {
    baseURL: BASE_URL,
    // trace, screenshot, video는 provider payload를 그대로 담을 수 있으므로 끈다.
    trace: "off",
    screenshot: "off",
    video: "off",
  },
  projects: [
    {
      name: "deterministic",
      testDir: "./e2e/deterministic",
      use: { ...devices["Desktop Chrome"] },
    },
    {
      name: "live",
      testDir: "./e2e/live",
      use: { ...devices["Desktop Chrome"] },
    },
  ],
  // 이미 ./scripts/dev.sh가 떠 있으면 그대로 재사용한다.
  // live project는 API도 필요하므로 dev.sh를 먼저 실행한 상태를 전제로 한다.
  webServer: {
    command: "npm run dev -- --host 127.0.0.1 --port 5173",
    url: BASE_URL,
    reuseExistingServer: true,
    timeout: 60_000,
  },
});
