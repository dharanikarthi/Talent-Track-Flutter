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

TOP_ANGLE = 70
BOTTOM_ANGLE = 160
SMOOTH_N = 3
MIN_DIP = 0.1

mp_pose = mp.solutions.pose

def _angle(a, b, c):
    ba = np.array([a[0]-b[0], a[1]-b[1]])
    bc = np.array([c[0]-b[0], c[1]-b[1]])
    denom = (np.linalg.norm(ba)*np.linalg.norm(bc))+1e-9
    cosang = np.clip(np.dot(ba, bc)/denom, -1.0, 1.0)
    return float(np.degrees(np.arccos(cosang)))


def _lm_xy(lm, w, h):
    return (lm.x*w, lm.y*h)


def process_pullup(input_video: str, output_dir: str):
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

    angle_history = deque(maxlen=SMOOTH_N)
    state = "waiting"
    in_dip = False
    dip_start_time = None
    reps = []
    initial_head_y = None
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
        head_y = None
        if results.pose_landmarks:
            lm = results.pose_landmarks.landmark
            try:
                nose = _lm_xy(lm[mp_pose.PoseLandmark.NOSE], width, height)
                head_y = nose[1]
                if initial_head_y is None:
                    initial_head_y = head_y
                ls = _lm_xy(lm[mp_pose.PoseLandmark.LEFT_SHOULDER], width, height)
                le = _lm_xy(lm[mp_pose.PoseLandmark.LEFT_ELBOW], width, height)
                lw = _lm_xy(lm[mp_pose.PoseLandmark.LEFT_WRIST], width, height)
                rs = _lm_xy(lm[mp_pose.PoseLandmark.RIGHT_SHOULDER], width, height)
                re = _lm_xy(lm[mp_pose.PoseLandmark.RIGHT_ELBOW], width, height)
                rw = _lm_xy(lm[mp_pose.PoseLandmark.RIGHT_WRIST], width, height)
                ang_l = _angle(ls, le, lw)
                ang_r = _angle(rs, re, rw)
                elbow_angle = (ang_l + ang_r)/2
            except Exception:
                elbow_angle = None
                head_y = None

        if elbow_angle is not None and head_y is not None and initial_head_y is not None:
            angle_history.append(elbow_angle)
            smoothed_angle = sum(angle_history)/len(angle_history)
            if state == "waiting" and head_y < initial_head_y:
                state = "up"
                in_dip = True
                dip_start_time = t
            elif state == "up":
                if smoothed_angle > BOTTOM_ANGLE and head_y >= initial_head_y and in_dip:
                    dip_duration = t - (dip_start_time or t)
                    if dip_duration >= MIN_DIP:
                        row = {
                            "count": len(reps)+1,
                            "up_time": round(dip_start_time or 0,2),
                            "down_time": round(t,2),
                            "dip_duration_sec": round(dip_duration,2),
                            "min_angle": round(smoothed_angle,2),
                            "correct": True,
                            "activity": "pullup",
                            "timestamp": round(t,2),
                            "notes": ""
                        }
                        reps.append(row)
                        csv_writer.writerow(row)
                        csv_file.flush()
                    in_dip = False
                    dip_start_time = None
                    state = "waiting"

        cv2.putText(frame, f"Pull-Ups: {len(reps)}", (10,30), cv2.FONT_HERSHEY_SIMPLEX, 1, (0,255,255),2)
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
            "activity": "pullup",
            "total_reps": int(len(reps)),
            "correct_reps": int(len(reps)),
            "accuracy_pct": float(100.0 if reps else 0.0),
            "duration_sec": float(frame_idx/(fps or 30)),
        }
    }