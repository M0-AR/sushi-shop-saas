// Demo tour: admin overview -> menu -> orders -> tenants -> audit.
import { test, expect } from '@playwright/test';

test('demo: admin tour', async ({ page }) => {
  await page.goto('/');
  await page.waitForLoadState('networkidle');
  await expect(page.getByText('Tokyo Main • live operational health')).toBeVisible({ timeout: 30000 });
  await page.waitForTimeout(2500); // let KPIs load
  await page.getByRole('link', { name: /Menu Items/ }).click();
  await expect(page.getByRole('cell', { name: 'Salmon Sushi' })).toBeVisible({ timeout: 15000 });
  await page.waitForTimeout(1000);
  await page.getByRole('link', { name: /^Orders$/ }).click();
  await expect(page.getByRole('cell', { name: 'delivered' }).first()).toBeVisible({ timeout: 15000 });
  await page.waitForTimeout(1000);
  await page.getByRole('link', { name: /Tenants/ }).click();
  await expect(page.getByRole('cell', { name: 'dubai-marina' })).toBeVisible({ timeout: 15000 });
  await page.waitForTimeout(1000);
  await page.getByRole('link', { name: /Audit Log/ }).click();
  await expect(page.getByRole('cell', { name: 'order.create' }).first()).toBeVisible({ timeout: 15000 });
  await page.waitForTimeout(1000);
});
