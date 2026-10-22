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

APKs are built automatically by GitHub Actions (`.github/workflows/build-android.yml`).

- **Every push to `main`**: GitHub → Actions → latest run → Artifacts → `taksh-delivery-apk`.
- **Release download link**: `git tag v1.0.0 && git push origin v1.0.0` → APKs appear under GitHub → Releases.
- **Manual**: Actions → "Build Android APK" → Run workflow.

Note: release builds are currently signed with the debug key. Add a real keystore before publishing to Play Store.
