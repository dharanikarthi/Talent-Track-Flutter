import cv2
import numpy as np
import pandas as pd
import mediapipe as mp
from collections import deque
from pathlib import Path
import csv

CSV_HEADER = [
    "count","down_time","up_time","dip_duration_sec","min_angle","correct","activity","timestamp","notes"
]

SMOOTH_N = 5
THRESHOLD_PIX = 5
mp_pose = mp.solutions.pose


def process_shuttlerun(input_video: str, output_dir: str):
    out_dir = Path(output_dir)
    out_dir.mkdir(parents=True, exist_ok=True)
    cap = cv2.VideoCapture(input_video)
    fps = cap.get(cv2.CAP_PROP_FPS) or 30
    width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
    height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))

    csv_path = out_dir/"result.csv"
    csv_file = csv_path.open('w', newline='')
    csv_writer = csv.DictWriter(csv_file, fieldnames=CSV_HEADER)
    csv_writer.writeheader()
    csv_file.flush()

    fourcc = cv2.VideoWriter_fourcc(*'mp4v')
    out_vid = cv2.VideoWriter(str(out_dir/"annotated_output.mp4"), fourcc, fps, (width, height))

    pose = mp_pose.Pose(min_detection_confidence=0.5, model_complexity=1)

    x_history = deque(maxlen=SMOOTH_N)
    dir_history = deque(maxlen=3)
    direction = None
    run_count = 0
    reps = []
    last_x = None
    frame_idx = 0

    while True:
        ret, frame = cap.read()
        if not ret:
            break
        frame_idx += 1
        t = frame_idx / fps
        img_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        results = pose.process(img_rgb)
        if results.pose_landmarks:
            lm = results.pose_landmarks.landmark
            key_x = np.mean([
                lm[mp_pose.PoseLandmark.LEFT_ANKLE].x * width,
                lm[mp_pose.PoseLandmark.RIGHT_ANKLE].x * width,
                lm[mp_pose.PoseLandmark.LEFT_FOOT_INDEX].x * width,
                lm[mp_pose.PoseLandmark.RIGHT_FOOT_INDEX].x * width,
            ])
            x_history.append(key_x)
            smoothed_x = sum(x_history)/len(x_history)
            if last_x is not None:
                delta = smoothed_x - last_x
                if delta > THRESHOLD_PIX:
                    dir_history.append('forward')
                elif delta < -THRESHOLD_PIX:
                    dir_history.append('backward')
            last_x = smoothed_x
            if len(dir_history) == 3 and all(d == dir_history[0] for d in dir_history):
                confirmed = dir_history[0]
                if direction and direction != confirmed and confirmed == 'backward':
                    run_count += 1
                    row = {
                        'count': run_count,
                        'down_time': 0,
                        'up_time': round(t,2),
                        'dip_duration_sec': 0,
                        'min_angle': 0,
                        'correct': True,
                        'activity': 'shuttlerun',
                        'timestamp': round(t,2),
                        'notes': ''
                    }
                    reps.append(row)
                    csv_writer.writerow(row)
                    csv_file.flush()
                direction = confirmed
        cv2.putText(frame, f"Runs: {run_count}", (10,30), cv2.FONT_HERSHEY_SIMPLEX, 1, (0,255,255),2)
        out_vid.write(frame)

    cap.release()
    out_vid.release()
    pose.close()
    try:
        csv_file.close()
    except Exception:
        pass

    return {
        "annotated_video": str(out_dir/"annotated_output.mp4"),
        "csv_path": str(csv_path),
        "summary": {
            "activity": "shuttlerun",
            "total_reps": int(len(reps)),
            "correct_reps": int(len(reps)),
            "accuracy_pct": float(100.0 if reps else 0.0),
            "duration_sec": float(frame_idx/(fps or 30)),
        }
    }