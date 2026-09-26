# Playwright suites

| Project | What | Command |
|---|---|---|
| `api-contract` | Backend contract (4) | `npx playwright test --project=api-contract` |
| `admin-chromium` | Admin E2E (6) | `npx playwright test --project=admin-chromium` |
| `main-smoke` | Flutter boot (1) | `npx playwright test --project=main-smoke` |
| `demo-app` / `demo-admin` | Recorded video tours | `npx playwright test --project=demo-app --project=demo-admin` |

## Re-record the README videos

Needs the full stack up (`docker compose up -d` in the repo root;
admin on :3102, app on :8082, backend on :3001):

```bash
npx playwright test --project=demo-admin --project=demo-app --reporter=line
VDIR=test-results; OUT=../../docs/videos
ffmpeg -y -i $VDIR/main.demo-demo-intro-to-checkout-demo-app/video.webm \
  -vf "fps=10,scale=480:-1:flags=lanczos,split[s0][s1];[s0]palettegen=max_colors=128[p];[s1][p]paletteuse" \
  $OUT/demo-app.gif
ffmpeg -y -i $VDIR/main.demo-demo-intro-to-checkout-demo-app/video.webm \
  -c:v libx264 -pix_fmt yuv420p -movflags +faststart $OUT/demo-app.mp4
ffmpeg -y -i $VDIR/admin.demo-demo-admin-tour-demo-admin/video.webm \
  -vf "fps=10,scale=720:-1:flags=lanczos,split[s0][s1];[s0]palettegen=max_colors=128[p];[s1][p]paletteuse" \
  $OUT/demo-admin.gif
ffmpeg -y -i $VDIR/admin.demo-demo-admin-tour-demo-admin/video.webm \
  -c:v libx264 -pix_fmt yuv420p -movflags +faststart $OUT/demo-admin.mp4
```

Keep GIFs <5MB so the README renders fast. Notes:

- `test-results/` is wiped at the start of each run — convert videos in the
  same command that produces them (see above).
- Flutter canvas taps are coordinate-calibrated at fixed viewports
  (500×800 app, 1280×900 admin); one tap per step with waits in between —
  back-to-back synthetic taps get swallowed.
- Skeleton placeholders must stay text-neutral (never real dish/order names)
  or strict-mode locators flake.
