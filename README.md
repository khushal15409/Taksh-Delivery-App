# delivery_boy

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Build & Download (CI)

GitHub Actions (`.github/workflows/build-android.yml`) builds a single release APK, `taksh-delivery-app.apk`.

- **Every push to `main`**: GitHub → Actions → latest run → Artifacts → `taksh-delivery-app` (zip containing one APK).
- **Release link**: `git tag v1.0.0 && git push origin v1.0.0` → the APK appears under GitHub → Releases (direct download, no zip).
- **Manual**: Actions → "Build Android APK" → Run workflow.

No `.env` file is needed. Release builds are signed with the debug key; add a real keystore before publishing to Play Store.
