import os
import shutil
import uuid
from pathlib import Path
from typing import Optional

from fastapi import FastAPI, File, UploadFile, Form
from fastapi.responses import JSONResponse
from fastapi.staticfiles import StaticFiles

from .processing.pushup import process_pushup

app = FastAPI(title="TalentTrack Processing API", version="0.1.0")

BASE_DIR = Path(__file__).resolve().parent.parent
WORK_DIR = BASE_DIR / "workdir"
WORK_DIR.mkdir(parents=True, exist_ok=True)
# Serve workdir files at /work
app.mount("/work", StaticFiles(directory=str(WORK_DIR)), name="work")

@app.post("/api/v1/process")
async def process(
    file: UploadFile = File(...),
    user_id: str = Form("dev"),
    activity: str = Form(...),
    mode: str = Form("server"),
    meta: Optional[str] = Form(None),
):
    job_id = str(uuid.uuid4())
    job_dir = WORK_DIR / job_id
    job_dir.mkdir(parents=True, exist_ok=True)

    # Save upload
    input_path = job_dir / file.filename
    with input_path.open("wb") as f:
        shutil.copyfileobj(file.file, f)

    # Dispatch per activity (start with pushup; others can be added similarly)
    activity_lc = activity.strip().lower()
    if activity_lc in {"pushup", "push-ups", "push ups"}:
        result = process_pushup(str(input_path), str(job_dir))
    else:
        # Placeholder: copy input to annotated_output.mp4 and write empty CSV
        out_video = job_dir / "annotated_output.mp4"
        shutil.copyfile(input_path, out_video)
        csv_path = job_dir / "result.csv"
        csv_path.write_text(
            "count,down_time,up_time,dip_duration_sec,min_angle,correct,activity,timestamp,notes\n"
        )
        result = {
            "annotated_video": str(out_video),
            "csv_path": str(csv_path),
            "summary": {
                "activity": activity_lc,
                "total_reps": 0,
                "correct_reps": 0,
                "accuracy_pct": 0.0,
                "duration_sec": 0.0,
            },
        }

    # Return URLs relative to /work so client can prefix with API base URL
    annotated_video_path = Path(result["annotated_video"]).resolve()
    csv_path = Path(result["csv_path"]).resolve()
    ann_rel = annotated_video_path.relative_to(WORK_DIR)
    csv_rel = csv_path.relative_to(WORK_DIR)
    s = result["summary"]
    payload = {
        "annotated_video_url": f"/work/{ann_rel.as_posix()}",
        "csv_url": f"/work/{csv_rel.as_posix()}",
        "summary": s,
    }
    return JSONResponse(payload)
