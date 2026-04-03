"""
services/gum_service.py
Multi-class gum disease detection using GumDiseaseCNN.
Classifies gum health as: healthy / mild / severe.
"""

import numpy as np
import torch
import torch.nn.functional as F

from core.config import settings
from models.gum.cnn_model import build_gum_model, GUM_LABELS
from utils.image_processing import (
    load_image_rgb,
    preprocess_for_cnn,
)

# ─── Singleton Model ───────────────────────────────────────────────────────────
_gum_model = build_gum_model(device=settings.MODEL_DEVICE)


def detect_gum_disease(image_path: str) -> dict:
    """
    Run gum disease detection on the uploaded image.

    The full original image is used (gum tissue is visible around teeth),
    rather than a masked crop, to capture colour and texture cues.

    Pipeline:
        1. Load and preprocess the image
        2. Forward pass through GumDiseaseCNN
        3. Softmax → class probabilities
        4. Argmax → predicted class label

    Args:
        image_path: Path to the original uploaded image

    Returns:
        {
          "label":      str   — "healthy" | "mild" | "severe"
          "confidence": float — probability of the predicted class (0–1)
          "all_probs":  dict  — {class_name: probability} for all 3 classes
        }
    """
    img_rgb  = load_image_rgb(image_path)

    # Preprocess → tensor
    np_input = preprocess_for_cnn(img_rgb)              # (1, 3, 128, 128)
    tensor   = torch.from_numpy(np_input).to(settings.MODEL_DEVICE)

    # Inference
    with torch.no_grad():
        logits = _gum_model(tensor)                     # (1, 3)
        probs  = F.softmax(logits, dim=1).squeeze()     # (3,)

    probs_np    = probs.cpu().numpy()
    class_idx   = int(np.argmax(probs_np))
    label       = GUM_LABELS[class_idx]
    confidence  = float(probs_np[class_idx])

    all_probs = {GUM_LABELS[i]: round(float(probs_np[i]), 4) for i in range(3)}

    return {
        "label":      label,
        "confidence": round(confidence, 4),
        "all_probs":  all_probs,
    }
