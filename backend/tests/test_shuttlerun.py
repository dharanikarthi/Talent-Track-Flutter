import numpy as np
import cv2
from pathlib import Path

from app.processing.shuttlerun import process_shuttlerun

def _make_dummy_video(path: str, seconds: float = 1.0, fps: int = 15, size=(320,240)):
    fourcc = cv2.VideoWriter_fourcc(*'mp4v')
    out = cv2.VideoWriter(path, fourcc, fps, size)
    frames = int(seconds*fps)
    for _ in range(frames):
        frame = np.zeros((size[1], size[0], 3), dtype=np.uint8)
        out.write(frame)
    out.release()


def test_process_shuttlerun_outputs(tmp_path: Path):
    vid = tmp_path/"dummy.mp4"
    _make_dummy_video(str(vid))
    res = process_shuttlerun(str(vid), str(tmp_path))
    assert (tmp_path/"annotated_output.mp4").exists()
    assert (tmp_path/"result.csv").exists()
    assert isinstance(res["summary"], dict)