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
MIN_DIP_CHANGE = 15

mp_pose = mp.solutions.pose

def _angle(a, b, c):
    ba = np.array([a[0]-b[0], a[1]-b[1]])
    bc = np.array([c[0]-b[0], c[1]-b[1]])
    denom = (np.linalg.norm(ba)*np.linalg.norm(bc))+1e-9
    cosang = np.clip(np.dot(ba, bc)/denom, -1.0, 1.0)
    return float(np.degrees(np.arccos(cosang)))


def _lm_xy(lm, w, h):
    return (lm.x*w, lm.y*h)


def process_situp(input_video: str, output_dir: str):
    out_dir = Path(output_dir)
    out_dir.mkdir(parents=True, exist_ok=True)
    cap = cv2.VideoCapture(input_video)
    fps = cap.get(cv2.CAP_PROP_FPS) or 30
    width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
    height = int(cap.get(cv2.CROP_FRAME_HEIGHT)) if hasattr(cv2, 'CROP_FRAME_HEIGHT') else int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))

    csv_path = out_dir/"result.csv"
    csv_file = csv_path.open('w', newline='')
    csv_writer = csv.DictWriter(csv_file, fieldnames=CSV_HEADER)
    csv_writer.writeheader()
    csv_file.flush()

    fourcc = cv2.VideoWriter_fourcc(*'mp4v')
    out_vid = cv2.VideoWriter(str(out_dir/"annotated_output.mp4"), fourcc, fps, (width, height))

    pose = mp_pose.Pose(min_detection_confidence=0.5, model_complexity=1)

    angle_history = deque(maxlen=SMOOTH_N)
    state = 'up'
    last_extreme = None
    reps = []
    dip_start_time = None
    frame_idx = 0

    while True:
        ret, frame = cap.read()
        if not ret:
            break
        frame_idx += 1
        t = frame_idx / fps
        img_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        results = pose.process(img_rgb)
        elbow_angle = None
        if results.pose_landmarks:
            lm = results.pose_landmarks.landmark
            try:
                ls = _lm_xy(lm[mp_pose.PoseLandmark.LEFT_SHOULDER], width, height)
                le = _lm_xy(lm[mp_pose.PoseLandmark.LEFT_ELBOW], width, height)
                lw = _lm_xy(lm[mp_pose.PoseLandmark.LEFT_WRIST], width, height)
                rs = _lm_xy(lm[mp_pose.PoseLandmark.RIGHT_SHOULDER], width, height)
                re = _lm_xy(lm[mp_pose.PoseLandmark.RIGHT_ELBOW], width, height)
                rw = _lm_xy(lm[mp_pose.PoseLandmark.RIGHT_WRIST], width, height)
                elbow_angle = (_angle(ls, le, lw) + _angle(rs, re, rw)) / 2
            except Exception:
                pass
        if elbow_angle is not None:
            angle_history.append(elbow_angle)
            elbow_sm = sum(angle_history)/len(angle_history)
            if last_extreme is None:
                last_extreme = elbow_sm
            if state == 'up' and last_extreme - elbow_sm >= MIN_DIP_CHANGE:
                state = 'down'
                dip_start_time = t
                last_extreme = elbow_sm
            elif state == 'down' and elbow_sm - last_extreme >= MIN_DIP_CHANGE:
                state = 'up'
                row = {
                    'count': len(reps)+1,
                    'down_time': round(dip_start_time or 0,3),
                    'up_time': round(t,3),
                    'dip_duration_sec': 0,
                    'min_angle': 0,
                    'correct': True,
                    'activity': 'situp',
                    'timestamp': round(t,3),
                    'notes': ''
                }
                reps.append(row)
                csv_writer.writerow(row)
                csv_file.flush()
                dip_start_time = None
                last_extreme = elbow_sm
        cv2.putText(frame, f"Sit-ups: {len(reps)}", (10,30), cv2.FONT_HERSHEY_SIMPLEX, 1, (0,255,255),2)
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
            "activity": "situp",
            "total_reps": int(len(reps)),
            "correct_reps": int(len(reps)),
            "accuracy_pct": float(100.0 if reps else 0.0),
            "duration_sec": float(frame_idx/(fps or 30)),
        }
    }