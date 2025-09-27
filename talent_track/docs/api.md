# API Spec

POST /api/v1/process
- Body: multipart video + JSON `{ user_id, activity, mode, meta }`
- Response: `{ annotated_video_url, csv_url, summary }`

Auth: Bearer JWT (dev seed). See Postman collection in `docs/postman/` (to be added).