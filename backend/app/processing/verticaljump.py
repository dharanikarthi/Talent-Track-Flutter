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

mp_pose = mp.solutions.pose

PIXEL_TO_M = 0.0026  # rough default, adjustable
SMOOTH_N = 3

def _lm_xy(lm, w, h):
    return (lm.x*w, lm.y*h)


def process_verticaljump(input_video: str, output_dir: str):
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

    baseline_y = None
    in_air = False
    peak_y = None
    jump_count = 0
    hip_history = deque(maxlen=SMOOTH_N)
    reps = []
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
            left_hip = _lm_xy(lm[mp_pose.PoseLandmark.LEFT_HIP], width, height)
            right_hip = _lm_xy(lm[mp_pose.PoseLandmark.RIGHT_HIP], width, height)
            mid_hip_y = (left_hip[1] + right_hip[1]) / 2
            hip_history.append(mid_hip_y)
            hip = sum(hip_history)/len(hip_history)
            if baseline_y is None:
                baseline_y = hip
            if not in_air and hip < baseline_y - 20:
                in_air = True
                peak_y = hip
            elif in_air:
                if hip < peak_y:
                    peak_y = hip
                elif hip >= baseline_y - 5:
                    in_air = False
                    jump_count += 1
                    jump_height_px = baseline_y - peak_y
                    jump_height_m = jump_height_px * PIXEL_TO_M
                    row = {
                        'count': jump_count,
                        'down_time': 0,
                        'up_time': round(t,2),
                        'dip_duration_sec': 0,
                        'min_angle': 0,
                        'correct': True,
                        'activity': 'verticaljump',
                        'timestamp': round(t,2),
                        'notes': f'jump_height_m={jump_height_m:.3f}'
                    }
                    reps.append(row)
                    csv_writer.writerow(row)
                    csv_file.flush()
        cv2.putText(frame, f"Jumps: {jump_count}", (10,30), cv2.FONT_HERSHEY_SIMPLEX, 1, (0,255,255),2)
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
            "activity": "verticaljump",
            "total_reps": int(len(reps)),
            "correct_reps": int(len(reps)),
            "accuracy_pct": float(100.0 if reps else 0.0),
            "duration_sec": float(frame_idx/(fps or 30)),
        }
    }