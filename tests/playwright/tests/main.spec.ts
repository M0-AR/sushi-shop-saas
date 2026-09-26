// Main App smoke (Flutter Web renders to canvas — DOM locators don't apply,
// so this project asserts serving + boot title, like a deploy smoke check).
// Full interaction flows live in Flutter widget tests + MCP-verified screenshots.
import { test, expect } from '@playwright/test';

test('flutter web serves and boots', async ({ page }) => {
  await page.goto('/');
  await expect(page).toHaveTitle(/Sushi Man SaaS|sushi_shop_saas/, { timeout: 30000 });
  await page.screenshot({ path: 'test-results/smoke-intro.png' });
});
