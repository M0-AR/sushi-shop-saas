// Demo tour: full customer journey, recorded to video for the README.
// Trusted mouse input drives the Flutter canvas (calibrated at 500x800;
// one tap per step — back-to-back synthetic taps get swallowed).
import { test, expect } from '@playwright/test';

test('demo: intro to checkout', async ({ page }) => {
  await page.goto('/');
  await expect(page).toHaveTitle(/Sushi Man SaaS/, { timeout: 30000 });
  await page.waitForTimeout(1500);
  await page.mouse.click(250, 745); // Get Started
  await page.waitForTimeout(2000);
  await page.mouse.click(105, 445); // Salmon Sushi tile
  await page.waitForTimeout(2000);
  await page.mouse.click(250, 768); // +
  await page.waitForTimeout(700);
  await page.mouse.click(250, 768); // +
  await page.waitForTimeout(700);
  await page.mouse.click(390, 768); // Add to cart
  await page.waitForTimeout(1500);
  await page.mouse.click(340, 440); // OK (double-pop)
  await page.waitForTimeout(2000);
  await page.mouse.click(475, 28); // cart
  await page.waitForTimeout(2500);
  await page.screenshot({ path: 'test-results/demo-checkout.png' });
});
