"""
services/alignment_service.py
Detects the alignment of teeth by fitting a line through tooth centroids.
Returns a score (0–100) where 100 = perfectly aligned.
"""

import math
import numpy as np

from utils.image_processing import extract_contours, compute_centroids


def compute_alignment_score(mask_array: np.ndarray) -> dict:
    """
    Estimate teeth alignment from the segmentation mask.

    Algorithm:
        1. Extract contours from binary mask (each blob ≈ one tooth)
        2. Compute centroid (cx, cy) of each tooth
        3. Fit a best-fit line (y = mx + b) through centroids via least squares
        4. Compute perpendicular deviation of each centroid from the line
        5. Score = 100 – clamp(mean_deviation / MAX_DEV * 100, 0, 100)

    Args:
        mask_array: Binary uint8 mask (H, W), values 0 or 255

    Returns:
        {
          "alignment_score": float (0–100),
          "num_teeth":       int,
          "centroids":       list of (x, y) tuples
        }
    """
    MAX_DEV = 30.0  # pixels — deviation at this level yields score 0

    contours  = extract_contours(mask_array)
    centroids = compute_centroids(contours)

    # Not enough teeth to measure alignment → return neutral score
    if len(centroids) < 2:
        return {"alignment_score": 50.0, "num_teeth": len(centroids),
                "centroids": centroids}

    pts = np.array(centroids, dtype=np.float32)
    xs, ys = pts[:, 0], pts[:, 1]

    # Ordinary Least Squares: fit y = mx + b
    A = np.vstack([xs, np.ones(len(xs))]).T
    m, b = np.linalg.lstsq(A, ys, rcond=None)[0]

    # Perpendicular distance from each centroid to line  (mx − y + b = 0)
    # d = |mx_i − y_i + b| / sqrt(m² + 1)
    denom       = math.sqrt(m ** 2 + 1)
    deviations  = np.abs(m * xs - ys + b) / denom
    mean_dev    = float(np.mean(deviations))

    raw_score      = max(0.0, 1.0 - mean_dev / MAX_DEV)
    alignment_score = round(raw_score * 100, 2)

    return {
        "alignment_score": alignment_score,
        "num_teeth":       len(centroids),
        "centroids":       centroids,
    }
