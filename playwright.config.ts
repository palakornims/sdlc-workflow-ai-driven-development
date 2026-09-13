import { defineConfig, devices } from '@playwright/test';

/**
 * Playwright configuration for Phase 6 (Test).
 * BASE_URL points at the running host under test (set by CI or the Design phase's runbook).
 *
 * Port 4280 is the default on purpose. Do NOT use 5000: on macOS the AirPlay Receiver
 * (ControlCenter) listens there permanently, so 5000 fails with "address already in use".
 * The same value must be set in .mcp.json's env for the playwright-test MCP server, because
 * that server is a separate child process and does not inherit this file's settings.
 * Test plans live in specs/, generated tests in tests/e2e/, tagged with REQ-/TASK-/TEST- IDs.
 */
export default defineConfig({
  testDir: './tests/e2e',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: [
    ['list'],
    ['html', { open: 'never', outputFolder: 'playwright-report' }],
    ['junit', { outputFile: 'test-results/junit.xml' }],
  ],
  use: {
    baseURL: process.env.BASE_URL ?? process.env.LOCAL_BASE_URL ?? 'http://localhost:4280',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
    ignoreHTTPSErrors: true,
  },
  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
  ],
});
