import cv2
import numpy as np
import pandas as pd
import mediapipe as mp
from collections import deque
from pathlib import Path

# Standardized CSV fields
CSV_HEADER = [
    "count","down_time","up_time","dip_duration_sec","min_angle","correct","activity","timestamp","notes"
]

# Thresholds (can be tuned)
DOWN_ANGLE = 75
UP_ANGLE = 110
MIN_DIP_DURATION = 0.2
SMOOTH_N = 3

mp_pose = mp.solutions.pose

def _angle(a, b, c):
    ba = np.array([a[0]-b[0], a[1]-b[1]])
    bc = np.array([c[0]-b[0], c[1]-b[1]])
    denom = (np.linalg.norm(ba)*np.linalg.norm(bc))+1e-9
    cosang = np.clip(np.dot(ba, bc)/denom, -1.0, 1.0)
    return float(np.degrees(np.arccos(cosang)))


def _lm_xy(lm, w, h):
    return (lm.x*w, lm.y*h)


def process_pushup(input_video: str, output_dir: str):
    out_dir = Path(output_dir)
    out_dir.mkdir(parents=True, exist_ok=True)
    cap = cv2.VideoCapture(input_video)
    fps = cap.get(cv2.CAP_PROP_FPS) or 30
    width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
    height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))

    fourcc = cv2.VideoWriter_fourcc(*'mp4v')
    out_vid = cv2.VideoWriter(str(out_dir/"annotated_output.mp4"), fourcc, fps, (width, height))

    pose = mp_pose.Pose(min_detection_confidence=0.5, model_complexity=1)

    angle_history = deque(maxlen=SMOOTH_N)
    state = 'up'
    in_dip = False
    dip_start_time = None
    current_dip_min_angle = 180
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
                ang_l = _angle(ls, le, lw)
                ang_r = _angle(rs, re, rw)
                elbow_angle = (ang_l + ang_r)/2
            except Exception:
                elbow_angle = None

        # Rep counting
        if elbow_angle is not None:
            angle_history.append(elbow_angle)
            elbow_sm = sum(angle_history)/len(angle_history)
            # Start dip
            if state == 'up' and elbow_sm <= DOWN_ANGLE:
                state = 'down'
                in_dip = True
                dip_start_time = t
                current_dip_min_angle = elbow_sm
            # End dip
            elif state == 'down' and elbow_sm >= UP_ANGLE:
                state = 'up'
                if in_dip:
                    dip_duration = t - dip_start_time
                    is_correct = current_dip_min_angle <= DOWN_ANGLE and dip_duration >= MIN_DIP_DURATION
                    reps.append({
                        'count': len(reps)+1,
                        'down_time': round(dip_start_time or 0,3),
                        'up_time': round(t,3),
                        'dip_duration_sec': round(dip_duration,3),
                        'min_angle': round(current_dip_min_angle,2),
                        'correct': is_correct,
                        'activity': 'pushup',
                        'timestamp': round(t,3),
                        'notes': ''
                    })
                    in_dip = False
                    dip_start_time = None
                    current_dip_min_angle = 180
            # Track min in dip
            if in_dip and elbow_sm < current_dip_min_angle:
                current_dip_min_angle = elbow_sm

        # Annotate frame (simple HUD)
        cv2.putText(frame, f"Push-ups: {len(reps)}", (10,30), cv2.FONT_HERSHEY_SIMPLEX, 1, (0,255,255),2)
        if elbow_angle is not None:
            cv2.putText(frame, f"Elbow: {int(elbow_angle)}", (10,60), cv2.FONT_HERSHEY_SIMPLEX, 0.8, (0,255,0),2)
        cv2.putText(frame, f"Time: {t:.1f}s", (10,90), cv2.FONT_HERSHEY_SIMPLEX, 0.8, (255,255,0),2)
        out_vid.write(frame)

    # Cleanup
    cap.release()
    out_vid.release()
    pose.close()

    # Write CSV
    csv_path = out_dir/"result.csv"
    if reps:
        df = pd.DataFrame(reps)
        # Ensure columns order
        for col in CSV_HEADER:
            if col not in df.columns:
                df[col] = ''
        df = df[CSV_HEADER]
        df.to_csv(csv_path, index=False)
    else:
        pd.DataFrame(columns=CSV_HEADER).to_csv(csv_path, index=False)

    total = len(reps)
    correct = sum(1 for r in reps if r.get('correct'))
    acc = (correct/total*100.0) if total else 0.0
    duration = frame_idx/(fps or 30)

    return {
        "annotated_video": str(out_dir/"annotated_output.mp4"),
        "csv_path": str(csv_path),
        "summary": {
            "activity": "pushup",
            "total_reps": int(total),
            "correct_reps": int(correct),
            "accuracy_pct": float(acc),
            "duration_sec": float(round(duration,2)),
        }
    }