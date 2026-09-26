// Admin E2E (role/text locators + web-first assertions — verified 2026).
// Each test is isolated: own navigation, no shared state.
import { test, expect } from '@playwright/test';

test('overview shows live KPIs', async ({ page }) => {
  await page.goto('/');
  await expect(page.getByText('Tokyo Main • live operational health')).toBeVisible();
  await expect(page.getByText('Menu items', { exact: true })).toBeVisible();
  await expect(page.getByText('16', { exact: true }).first()).toBeVisible({ timeout: 15000 });
  await expect(page.getByText('Outlets', { exact: true })).toBeVisible();
});

test('menu table lists anchor dishes', async ({ page }) => {
  await page.goto('/admin/menu');
  await expect(page.getByRole('heading', { name: /dishes/ })).toBeVisible();
  await expect(page.getByRole('cell', { name: 'Salmon Sushi' })).toBeVisible({ timeout: 15000 });
  await expect(page.getByRole('cell', { name: '$21.00' }).first()).toBeVisible();
});

test('orders board shows journey statuses', async ({ page }) => {
  await page.goto('/admin/orders');
  await expect(page.getByRole('heading', { name: /orders/ })).toBeVisible();
  await expect(page.getByRole('cell', { name: 'delivered' }).first()).toBeVisible({ timeout: 15000 });
});

test('tenants list all outlets', async ({ page }) => {
  await page.goto('/admin/tenants');
  await expect(page.getByRole('cell', { name: 'tokyo-main' })).toBeVisible({ timeout: 15000 });
  await expect(page.getByRole('cell', { name: 'dubai-marina' })).toBeVisible();
});

test('audit log records order events', async ({ page }) => {
  await page.goto('/admin/audit');
  await expect(page.getByRole('cell', { name: 'order.create' }).first()).toBeVisible({ timeout: 15000 });
});

test('sidebar navigation round-trips', async ({ page }) => {
  await page.goto('/');
  await page.getByRole('link', { name: /Menu Items/ }).click();
  await expect(page).toHaveURL(/\/admin\/menu/);
  await page.getByRole('link', { name: /Back to overview/ }).click();
  await expect(page).toHaveURL(/\/$/);
});
