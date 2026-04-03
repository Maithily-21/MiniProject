"""
services/symmetry_service.py
Computes left-right symmetry of the teeth mask.
Returns a score (0–100) where 100 = perfect mirror symmetry.
"""

import cv2
import numpy as np


def compute_symmetry_score(mask_array: np.ndarray) -> dict:
    """
    Measure horizontal (left–right) symmetry of the segmentation mask.

    Algorithm:
        1. Split mask at the vertical midline into left / right halves
        2. Flip the right half horizontally
        3. Resize both halves to the same width (handles odd-width images)
        4. Compute pixel-wise overlap (IoU) → symmetry score

    Args:
        mask_array: Binary uint8 mask (H, W), values 0 or 255

    Returns:
        {
          "symmetry_score": float (0–100),
          "left_area":      int  — number of white pixels on the left
          "right_area":     int  — number of white pixels on the right
        }
    """
    H, W = mask_array.shape

    # Split at midline
    mid         = W // 2
    left_half   = mask_array[:, :mid]
    right_half  = mask_array[:, mid:]

    # Flip right half to align with left
    right_flipped = cv2.flip(right_half, 1)   # horizontal flip

    # Ensure same width (important when W is odd)
    min_w = min(left_half.shape[1], right_flipped.shape[1])
    left_crop  = left_half[:, :min_w]
    right_crop = right_flipped[:, :min_w]

    # IoU-based similarity
    intersection = np.logical_and(left_crop > 0, right_crop > 0).sum()
    union        = np.logical_or(left_crop  > 0, right_crop > 0).sum()

    iou            = (intersection / union) if union > 0 else 0.0
    symmetry_score = round(float(iou) * 100, 2)

    return {
        "symmetry_score": symmetry_score,
        "left_area":      int((left_crop  > 0).sum()),
        "right_area":     int((right_crop > 0).sum()),
    }
