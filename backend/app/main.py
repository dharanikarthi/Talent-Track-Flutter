import os
import shutil
import uuid
from pathlib import Path
from typing import Optional
import threading
import asyncio
import time
import csv

from fastapi import FastAPI, File, UploadFile, Form, HTTPException
from fastapi.responses import JSONResponse, StreamingResponse
from fastapi.staticfiles import StaticFiles

from .processing.pushup import process_pushup
from .processing.pullup import process_pullup
from .processing.verticaljump import process_verticaljump
from .processing.shuttlerun import process_shuttlerun
from .processing.situp import process_situp

app = FastAPI(title="TalentTrack Processing API", version="0.1.0")

BASE_DIR = Path(__file__).resolve().parent.parent
WORK_DIR = BASE_DIR / "workdir"
WORK_DIR.mkdir(parents=True, exist_ok=True)
# Serve workdir files at /work
app.mount("/work", StaticFiles(directory=str(WORK_DIR)), name="work")

JOBS = {}

@app.post("/api/v1/process/realtime")
async def process_realtime(
    file: UploadFile = File(...),
    user_id: str = Form("dev"),
    activity: str = Form(...),
    mode: str = Form("server"),
    meta: Optional[str] = Form(None),
):
    job_id = str(uuid.uuid4())
    job_dir = WORK_DIR / job_id
    job_dir.mkdir(parents=True, exist_ok=True)
    input_path = job_dir / file.filename
    with input_path.open("wb") as f:
        shutil.copyfileobj(file.file, f)

    activity_lc = activity.strip().lower()

    def worker():
        if activity_lc in {"pushup", "push-ups", "push ups"}:
            process_pushup(str(input_path), str(job_dir))
        elif activity_lc in {"pullup", "pull-ups", "pull ups"}:
            process_pullup(str(input_path), str(job_dir))
        elif activity_lc in {"verticaljump", "vertical jump"}:
            process_verticaljump(str(input_path), str(job_dir))
        elif activity_lc in {"shuttlerun", "shuttle run"}:
            process_shuttlerun(str(input_path), str(job_dir))
        elif activity_lc in {"situp", "sit-ups", "sit ups"}:
            process_situp(str(input_path), str(job_dir))
        else:
            out_video = job_dir / "annotated_output.mp4"
            shutil.copyfile(input_path, out_video)
            (job_dir/"result.csv").write_text(
                "count,down_time,up_time,dip_duration_sec,min_angle,correct,activity,timestamp,notes\n"
            )
        JOBS[job_id] = {"done": True}

    JOBS[job_id] = {"done": False, "activity": activity_lc}
    threading.Thread(target=worker, daemon=True).start()

    ann_rel = f"/work/{job_id}/annotated_output.mp4"
    csv_rel = f"/work/{job_id}/result.csv"
    payload = {
        "job_id": job_id,
        "annotated_video_url": ann_rel,
        "csv_url": csv_rel,
        "stream_url": f"/api/v1/jobs/{job_id}/stream",
        "activity": activity_lc,
    }
    return JSONResponse(payload)

@app.get("/api/v1/jobs/{job_id}/stream")
async def stream_csv(job_id: str):
    job_dir = WORK_DIR / job_id
    csv_path = job_dir / "result.csv"
    if not job_dir.exists():
        raise HTTPException(status_code=404, detail="Job not found")

    async def event_gen():
        sent = 0
        header_sent = False
        while True:
            if csv_path.exists():
                try:
                    with csv_path.open("r", newline='') as f:
                        lines = f.readlines()
                except Exception:
                    lines = []
                if lines:
                    if not header_sent:
                        # send header once as an event
                        yield f"event: header\ndata: {lines[0].strip()}\n\n"
                        header_sent = True
                        sent = 1
                    while sent < len(lines):
                        yield f"data: {lines[sent].strip()}\n\n"
                        sent += 1
            await asyncio.sleep(0.5)

    return StreamingResponse(event_gen(), media_type="text/event-stream")
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
    elif activity_lc in {"pullup", "pull-ups", "pull ups"}:
        result = process_pullup(str(input_path), str(job_dir))
    elif activity_lc in {"verticaljump", "vertical jump"}:
        result = process_verticaljump(str(input_path), str(job_dir))
    elif activity_lc in {"shuttlerun", "shuttle run"}:
        result = process_shuttlerun(str(input_path), str(job_dir))
    elif activity_lc in {"situp", "sit-ups", "sit ups"}:
        result = process_situp(str(input_path), str(job_dir))
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
