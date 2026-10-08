# Doodle Clubhouse (iOS app)

- `www/index.html` – the whole app (drawing, animation, sounds, purchases).
- `capacitor.config.json` – app name and bundle ID.
- `codemagic.yaml` – cloud build: creates the iOS project, icons, signs, builds and uploads to TestFlight.
- `resources/` – app icon (1024px) and splash screens; `@capacitor/assets` makes every size from these.
- `store/` – App Store text (`STORE-LISTING.md`) and screenshots.
- `docs/index.html` – privacy policy & support page.

The in-app purchase uses `cordova-plugin-purchase` with product ID `brush_pack` (non-consumable).
Saving/sharing uses `@capacitor/filesystem` + `@capacitor/share` behind a grown-up check.

**Start here:** `LAUNCH-STEPS.md`
