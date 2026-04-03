"""
services/segmentation_service.py
Runs the U-Net model on an uploaded image to produce a binary teeth mask.
Saves both the raw mask and a visual overlay to the outputs directory.
"""

import os
import uuid
import numpy as np
import torch
import cv2

from core.config import settings
from models.segmentation.unet import build_unet
from utils.image_processing import (
    load_image_rgb,
    preprocess_for_segmentation,
    mask_to_binary,
    overlay_mask,
    save_image,
)

# ─── Singleton Model ───────────────────────────────────────────────────────────
# Loaded once at module import so startup cost is paid only once per process.
print("DEBUG: 🚀 Loading U-Net segmentation model...")
_unet = build_unet(device=settings.MODEL_DEVICE)
print("DEBUG: ✅ U-Net segmentation model loaded.")


def run_segmentation(image_path: str) -> dict:
    """
    Perform teeth segmentation on the given image.

    Pipeline:
        1. Load & preprocess image → grayscale (1,1,256,256)
        2. Forward pass through U-Net
        3. Threshold output to binary mask
        4. Resize mask back to original image dimensions
        5. Save mask PNG and overlay visualisation

    Args:
        image_path: Absolute or repo-relative path to the input image

    Returns:
        {
          "mask_path":    str  — path to saved binary mask
          "overlay_path": str  — path to saved overlay visualisation
          "mask_array":   np.ndarray (H, W) uint8  — for downstream services
        }
    """
    # 1. Load image
    img_rgb = load_image_rgb(image_path)
    orig_h, orig_w = img_rgb.shape[:2]

    # 2. Preprocess → torch tensor
    tensor_np = preprocess_for_segmentation(img_rgb)    # (1,1,256,256) float32
    tensor    = torch.from_numpy(tensor_np).to(settings.MODEL_DEVICE)

    # 3. U-Net inference (no gradient needed)
    with torch.no_grad():
        pred = _unet(tensor)                            # (1,1,256,256)

    # 4. Convert prediction to numpy binary mask
    pred_np   = pred.squeeze().cpu().numpy()            # (256,256) float32
    mask_256  = mask_to_binary(pred_np)                 # (256,256) uint8 0/255

    # 5. Resize mask to original image size
    mask_full = cv2.resize(mask_256, (orig_w, orig_h),
                           interpolation=cv2.INTER_NEAREST)

    # 6. Build output file paths
    uid          = uuid.uuid4().hex[:8]
    mask_name    = f"mask_{uid}.png"
    overlay_name = f"overlay_{uid}.png"
    mask_path    = os.path.join(settings.OUTPUT_DIR, mask_name)
    overlay_path = os.path.join(settings.OUTPUT_DIR, overlay_name)

    # 7. Save mask and overlay
    save_image(mask_full, mask_path)

    img_bgr     = cv2.cvtColor(img_rgb, cv2.COLOR_RGB2BGR)
    overlay_img = overlay_mask(img_bgr, mask_full)
    save_image(overlay_img, overlay_path)

    return {
        "mask_path":    mask_path,
        "overlay_path": overlay_path,
        "mask_array":   mask_full,
        "img_rgb":      img_rgb,
        "mask_uint8":   mask_full,
    }
