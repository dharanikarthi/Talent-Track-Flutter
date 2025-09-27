# Architecture

- UI: Light theme, modular structure: `lib/ui`, `lib/models`, `lib/services`, `lib/screens`, `lib/widgets`, `lib/state`.
- State: Riverpod (predictable/testable).
- Media: `camera`, `image_picker`, `video_player/chewie`.
- On-device pose: MediaPipe/TFLite via platform channels initially Android.
- Server fallback: FastAPI container providing `/api/v1/process`.
- Storage: Hive/SQLite local; optional cloud for heavy artifacts.