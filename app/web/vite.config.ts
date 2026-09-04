import react from "@vitejs/plugin-react";
import { defineConfig } from "vite";

export default defineConfig({
  plugins: [react()],
  server: {
    port: 5173,
    proxy: {
      "/healthz": "http://127.0.0.1:8000",
      "/api": {
        target: "http://127.0.0.1:8000",
      },
    },
  },
  test: {
    // vitest는 src/의 단위 테스트만 수집한다. e2e/의 Playwright 시나리오는
    // npm run test:browser가 별도 runner로 실행한다.
    include: ["src/**/*.{test,spec}.{ts,tsx}"],
    environment: "jsdom",
    setupFiles: "./src/test/setup.ts",
  },
});
