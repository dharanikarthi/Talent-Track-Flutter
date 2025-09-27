# TalentTrack Processing Backend

FastAPI microservice that runs MediaPipe/OpenCV processing for activities.

Endpoints
- POST /api/v1/process: upload a video and specify activity to process.

Outputs per request
- annotated_output.mp4
- result.csv (schema: count, down_time, up_time, dip_duration_sec, min_angle, correct, activity, timestamp, notes)
- summary.json (activity, total_reps, correct_reps, accuracy_pct, duration_sec, csv_url, annotated_video_url)

Run locally
- python -m venv .venv && source .venv/bin/activate (Linux/macOS) or .venv\Scripts\activate (Windows)
- pip install -r requirements.txt
- uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

Docker
- docker build -t talenttrack-backend:latest .
- docker run -p 8000:8000 talenttrack-backend:latest