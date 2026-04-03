"""
utils/image_processing.py
Shared image preprocessing and postprocessing utilities.
Used by every service in the AI pipeline.
"""

import cv2
import numpy as np
from pathlib import Path
from typing import Tuple, Optional


# ─── Constants ────────────────────────────────────────────────────────────────

SEG_SIZE    = (256, 256)   # U-Net input resolution
CNN_SIZE    = (128, 128)   # Cavity / Gum CNN input resolution
MASK_THRESH = 0.5          # Binary threshold for segmentation mask


# ─── Loading & Saving ─────────────────────────────────────────────────────────

def load_image_bgr(path: str) -> np.ndarray:
    """Load an image from disk in BGR format (OpenCV default)."""
    img = cv2.imread(path)
    if img is None:
        raise FileNotFoundError(f"Cannot load image: {path}")
    return img


def load_image_rgb(path: str) -> np.ndarray:
    """Load an image from disk and convert to RGB."""
    return cv2.cvtColor(load_image_bgr(path), cv2.COLOR_BGR2RGB)


def save_image(array: np.ndarray, path: str) -> None:
    """Save a NumPy array (uint8 BGR or grayscale) to disk."""
    Path(path).parent.mkdir(parents=True, exist_ok=True)
    cv2.imwrite(path, array)


# ─── Preprocessing ────────────────────────────────────────────────────────────

def preprocess_for_segmentation(img_rgb: np.ndarray) -> np.ndarray:
    """
    Prepare an RGB image for U-Net inference.

    Steps:
        1. Resize to SEG_SIZE (256, 256)
        2. Normalise to [0, 1]
        3. Transpose to (1, 3, H, W) for PyTorch

    Returns:
        float32 NumPy array (1, 3, 256, 256)
    """
    resized = cv2.resize(img_rgb, SEG_SIZE).astype(np.float32) / 255.0
    # Transpose from (H, W, 3) to (1, 3, H, W)
    return resized.transpose(2, 0, 1)[np.newaxis]


def preprocess_for_cnn(img_rgb: np.ndarray) -> np.ndarray:
    """
    Prepare an RGB image for Cavity / Gum CNN inference.

    Steps:
        1. Resize to CNN_SIZE
        2. Normalise to [0, 1] with ImageNet mean/std
        3. Transpose to (1, 3, H, W)

    Returns:
        float32 NumPy array  (1, 3, 128, 128)
    """
    mean = np.array([0.485, 0.456, 0.406], dtype=np.float32)
    std  = np.array([0.229, 0.224, 0.225], dtype=np.float32)

    resized = cv2.resize(img_rgb, CNN_SIZE).astype(np.float32) / 255.0
    normed  = (resized - mean) / std            # (128, 128, 3)
    return normed.transpose(2, 0, 1)[np.newaxis] # (1, 3, 128, 128)


# ─── Postprocessing ───────────────────────────────────────────────────────────

def mask_to_binary(mask_float: np.ndarray, threshold: float = MASK_THRESH) -> np.ndarray:
    """
    Convert float probability mask (H, W) to uint8 binary image (0 or 255).
    """
    binary = (mask_float > threshold).astype(np.uint8) * 255
    return binary


def overlay_mask(img_bgr: np.ndarray, binary_mask: np.ndarray,
                 color: Tuple[int, int, int] = (0, 255, 0),
                 alpha: float = 0.4) -> np.ndarray:
    """
    Blend a segmentation mask over the original image for visualisation.

    Args:
        img_bgr:     Original image (H, W, 3) in BGR
        binary_mask: Binary mask  (H, W) with values 0 or 255
        color:       BGR overlay colour
        alpha:       Transparency of overlay (0 = transparent, 1 = opaque)
    """
    overlay   = img_bgr.copy()
    mask_bool = binary_mask > 0
    overlay[mask_bool] = (
        np.array(color, dtype=np.float32) * alpha
        + img_bgr[mask_bool].astype(np.float32) * (1 - alpha)
    ).astype(np.uint8)
    return overlay


# ─── Contour Utilities ────────────────────────────────────────────────────────

def extract_contours(binary_mask: np.ndarray):
    """
    Find external contours in a binary mask.

    Returns:
        List of contour arrays (OpenCV contour format)
    """
    contours, _ = cv2.findContours(
        binary_mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE
    )
    # Filter tiny noise contours
    return [c for c in contours if cv2.contourArea(c) > 50]


def compute_centroids(contours) -> list:
    """
    Compute the (x, y) centroid of each contour.

    Returns:
        List of (cx, cy) tuples
    """
    centroids = []
    for cnt in contours:
        M = cv2.moments(cnt)
        if M["m00"] != 0:
            cx = int(M["m10"] / M["m00"])
            cy = int(M["m01"] / M["m00"])
            centroids.append((cx, cy))
    return centroids


# ─── Cropping ─────────────────────────────────────────────────────────────────

def crop_roi(img_rgb: np.ndarray,
             binary_mask: np.ndarray,
             padding: int = 10) -> Optional[np.ndarray]:
    """
    Crop the bounding-box region of the mask from the original image.
    Used to provide the CNN models with a focused region of interest.

    Returns:
        Cropped RGB patch, or None if mask is empty
    """
    # Check if mask is too small (e.g., less than 1% of the image)
    # This addresses "speckled" masks from poor segmentation
    mask_area = np.count_nonzero(binary_mask)
    total_area = binary_mask.shape[0] * binary_mask.shape[1]
    
    if mask_area < (total_area * 0.01):
        # Fallback: Return central 80% of the image
        h, w = img_rgb.shape[:2]
        y1, y2 = int(0.1 * h), int(0.9 * h)
        x1, x2 = int(0.1 * w), int(0.9 * w)
        return img_rgb[y1:y2, x1:x2]

    coords = cv2.findNonZero(binary_mask)
    if coords is None:
        return None

    x, y, w, h = cv2.boundingRect(coords)
    H, W = img_rgb.shape[:2]

    # Apply padding with boundary clipping
    x1 = max(0, x - padding)
    y1 = max(0, y - padding)
    x2 = min(W, x + w + padding)
    y2 = min(H, y + h + padding)

    return img_rgb[y1:y2, x1:x2]
