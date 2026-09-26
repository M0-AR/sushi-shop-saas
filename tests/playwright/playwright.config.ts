import { defineConfig, devices } from '@playwright/test';

// Verified 2026: role/text locators, web-first assertions, trace on retry,
// per-browser projects, isolated tests, artifacts only on failure.
export default defineConfig({
  testDir: './tests',
  timeout: 60_000,
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 2 : undefined,
  reporter: [['list'], ['html', { open: 'never' }]],
  use: {
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    video: 'on-first-retry',
  },
  projects: [
    {
      name: 'api-contract',
      testMatch: /api\.contract\.spec\.ts/,
      use: { baseURL: process.env.API_URL || 'http://localhost:3001' },
    },
    {
      name: 'admin-chromium',
      testMatch: /admin\.spec\.ts/,
      use: { ...devices['Desktop Chrome'], baseURL: process.env.ADMIN_URL || 'http://localhost:3102' },
    },
    {
      name: 'main-smoke',
      testMatch: [/main\.spec\.ts/, /main\.calib\.spec\.ts/],
      use: { ...devices['Pixel 7'], baseURL: process.env.APP_URL || 'http://localhost:8082' },
    },
    {
      name: 'demo-app',
      testMatch: /main\.demo\.spec\.ts/,
      use: {
        viewport: { width: 500, height: 800 },
        baseURL: process.env.APP_URL || 'http://localhost:8082',
        video: 'on',
      },
    },
    {
      name: 'demo-admin',
      testMatch: /admin\.demo\.spec\.ts/,
      use: {
        ...devices['Desktop Chrome'],
        baseURL: process.env.ADMIN_URL || 'http://localhost:3102',
        video: 'on',
      },
    },
  ],
});
