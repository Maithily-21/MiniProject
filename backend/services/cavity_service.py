"""
services/cavity_service.py
Binary cavity detection using CavityCNN.
Operates on the cropped teeth region extracted from the segmentation mask.
"""

import numpy as np
import torch
import torch.nn.functional as F

from core.config import settings
from models.cavity.cnn_model import build_cavity_model, CAVITY_LABELS
from utils.image_processing import (
    load_image_rgb,
    preprocess_for_cnn,
    crop_roi,
)

# ─── Singleton Model ───────────────────────────────────────────────────────────
_cavity_model = build_cavity_model(device=settings.MODEL_DEVICE)


def detect_cavity(image_path: str, mask_array: np.ndarray) -> dict:
    """
    Run cavity detection on the teeth region of interest.

    Pipeline:
        1. Crop the bounding-box ROI using the segmentation mask
        2. If mask is empty, run on the full image as fallback
        3. Preprocess the crop for the CNN
        4. Forward pass → sigmoid → probability of cavity
        5. Threshold at 0.5 to get label

    Args:
        image_path: Path to the original uploaded image
        mask_array: Binary uint8 mask (H, W) from segmentation service

    Returns:
        {
          "label":      str   — "cavity" or "no_cavity"
          "confidence": float — probability (0–1) for the predicted class
          "display":    str   — "Detected" or "Not Detected"
        }
    """
    img_rgb = load_image_rgb(image_path)

    # Try to crop the teeth ROI; fall back to full image
    roi = crop_roi(img_rgb, mask_array)
    if roi is None or roi.size == 0:
        roi = img_rgb

    # Preprocess → tensor
    np_input = preprocess_for_cnn(roi)              # (1, 3, 128, 128)
    tensor   = torch.from_numpy(np_input).to(settings.MODEL_DEVICE)

    # Inference
    with torch.no_grad():
        logit = _cavity_model(tensor)               # (1, 1)
        prob  = torch.sigmoid(logit).item()         # scalar ∈ [0, 1]

    # Classification
    # Lowered threshold to 0.4 to improve sensitivity for small caries
    class_idx   = 1 if prob >= 0.4 else 0
    label       = CAVITY_LABELS[class_idx]
    confidence  = prob if class_idx == 1 else (1.0 - prob)

    return {
        "label":      label,
        "confidence": round(float(confidence), 4),
        "display":    "Detected" if class_idx == 1 else "Not Detected",
    }
