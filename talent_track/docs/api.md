# API Spec

POST /api/v1/process
- Body: multipart video + JSON `{ user_id, activity, mode, meta }`
- Response: `{ annotated_video_url, csv_url, summary }`

Auth: Bearer JWT (dev seed). See Postman collection in `docs/postman/` (to be added).

Example curl
```
curl -X POST http://localhost:8000/api/v1/process \
  -F "file=@/path/to/video.mp4" \
  -F "user_id=demo" \
  -F "activity=pushup" \
  -F "mode=server"
```
