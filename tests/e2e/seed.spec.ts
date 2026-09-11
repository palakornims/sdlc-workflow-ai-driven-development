import { test, expect } from '@playwright/test';

/**
 * Seed test used by the Playwright planner/generator agents to bootstrap a page context.
 * Keep it minimal: navigate to the app root and prove it is up. Add shared login or data
 * setup here only if every test plan needs it; otherwise put setup in fixtures.
 */
test.describe('Seed', () => {
  test('application is reachable', async ({ page }) => {
    await page.goto('/');
    await expect(page).toHaveTitle(/.+/);
  });
});
