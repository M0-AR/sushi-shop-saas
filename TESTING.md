# 🧪 Testing System — full matrix (verified 2026 pyramid: 50% unit / 40% integration / 10% E2E)

> Goal: after build + run, we know with evidence that zero bugs ship and every
> feature works on web + mobile viewports. Flaky tests are defects, not noise.

## Lanes (CI: `.github/workflows/ci.yml`)

| Lane | What | Command | Where |
|---|---|---|---|
| Fast (PR) | `flutter analyze` + `flutter test` | `flutter test` | `frontend_app/` |
| Fast (PR) | backend build | `npm run build` | `backend/` |
| Confidence (merge) | backend API tests vs live stack | `npm test` | `backend/` |
| Confidence (merge) | Playwright API + admin + smoke | `npx playwright test` | `tests/playwright/` |

## Matrix (last full run)

| Layer | Suite | Result |
|---|---|---|
| Static | `flutter analyze` | No issues found |
| Widget (mobile 390 + desktop 1280) | `flutter test` (7 tests: nav, qty, search, cart, redeem, responsive ×2) | 7/7 pass |
| Integration (real Postgres/RLS) | `backend/test/api.test.js` (`node --test`, 11 asserts: health, menu shape, RLS isolation, validation, orders, tenants, audit, payments wiring, headers) | 11/11 pass |
| Contract/E2E | Playwright `api-contract` (4) | 4/4 pass |
| E2E admin | Playwright `admin-chromium` (6: KPIs, menu, orders, tenants, audit, nav) | 6/6 pass |
| Smoke main | Playwright `main-smoke` (Flutter boots) | 1/1 pass |
| Manual E2E | Playwright MCP canvas flows + 22 screenshots | verified |

## Rules enforced

- Role/text locators + web-first assertions in Playwright; no CSS/XPath coupling.
- Isolated tests: unique promos per run, no shared mutable fixtures.
- Trace/screenshot/video only on failure (perf); HTML report never auto-opens in CI.
- Coverage is a weak signal — mutation-style thinking: every fix gets a regression test
  (examples: duplicate Hero tag, IPv6 localhost healthchecks, baked `backend:3001` URL,
  promo-field scoping, tile overflow — all caught by tests, all fixed).
- Mobile + web: Flutter widget tests run at 390×844 and 1280×800 viewports;
  Playwright `main-smoke` uses Pixel 7; admin verified at 1440×900 and 500px widths.
