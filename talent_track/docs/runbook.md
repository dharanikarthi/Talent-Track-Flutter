# Runbook

- Local build: `flutter pub get && flutter run`
- Tests: `flutter test`
- CI: push to `develop` triggers analyze/test; push to `main` or `v*` tag builds APK and uploads to Releases.
- Backend: `backend/` Dockerfile builds container with OpenCV + MediaPipe.