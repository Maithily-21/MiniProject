"""
services/staining_service.py - Color-space analysis for dental staining.
Detects yellowish/brownish discoloration on the teeth surface.
"""

import cv2
import numpy as np
from typing import Tuple

def analyze_staining(img_rgb: np.ndarray, binary_mask: np.ndarray) -> Tuple[float, str]:
    """
    Analyzes surface staining on teeth using HSV color thresholding.
    
    Args:
        img_rgb:     Original image (H, W, 3) in RGB
        binary_mask: Teeth mask (H, W) where 255 = teeth
        
    Returns:
        (stain_score, stain_result)
    """
    # 1. Isolate the teeth region
    hsv = cv2.cvtColor(img_rgb, cv2.COLOR_RGB2HSV)
    
    # 2. Define range for "Staining" (Yellowish/Brownish)
    # Hue: [10, 35] covers orange/yellow/brown tones
    # Saturation: [50, 255] avoids white/grey teeth
    # Value: [50, 255] avoids very dark shadows
    lower_stain = np.array([5, 40, 40])
    upper_stain = np.array([35, 255, 255])
    
    stain_mask = cv2.inRange(hsv, lower_stain, upper_stain)
    
    # 3. Only look at staining WITHIN segmented teeth
    valid_stain = cv2.bitwise_and(stain_mask, binary_mask)
    
    # 4. Calculate Score
    teeth_pixels = np.count_nonzero(binary_mask)
    if teeth_pixels == 0:
        return 0.0, "Clean"
        
    stain_pixels = np.count_nonzero(valid_stain)
    stain_ratio  = stain_pixels / teeth_pixels
    
    # Scale to 0-100%
    score = round(stain_ratio * 100, 2)
    
    # 5. Categorize
    if score < 5:
        result = "Clean / Minimal Staining"
    elif score < 15:
        result = "Mild Surface Staining"
    elif score < 30:
        result = "Moderate Staining"
    else:
        result = "Significant Staining / Plaque"
        
    return score, result
