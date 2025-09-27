# Runbook

- Local build: `flutter pub get && flutter run`
- Tests: `flutter test`
- CI: push to `develop` triggers analyze/test; push to `main` or `v*` tag builds APK and uploads to Releases.
- Backend: `backend/` Dockerfile builds container with OpenCV + MediaPipe.

Postman collection
- Import `docs/postman/TalentTrack.postman_collection.json` into Postman
- Set an environment variable `baseUrl` to your backend base (e.g., http://localhost:8000)
- Use the "Process Video" request and attach a sample file under samples/
