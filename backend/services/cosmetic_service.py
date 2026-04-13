import cv2
import numpy as np
from typing import Tuple

def compute_spacing_and_gum(img_rgb: np.ndarray, mask_array: np.ndarray) -> Tuple[str, str, float]:
    """
    Computes spacing_tip and gum_visibility based on the segmentation mask.
    """
    # --- Spacing Calculation ---
    spacing_tip = "Normal spacing"
    contours, _ = cv2.findContours(mask_array, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    
    if len(contours) >= 2:
        bboxes = [cv2.boundingRect(c) for c in contours]
        bboxes.sort(key=lambda b: b[0]) # sort by x-coordinate
        
        distances = []
        for i in range(len(bboxes) - 1):
            x1, _, w1, _ = bboxes[i]
            x2, _, _, _ = bboxes[i+1]
            dist = x2 - (x1 + w1)
            # Only consider positive distances (gaps) and small overlaps
            distances.append(dist)
            
        avg_dist = float(np.mean(distances)) if distances else 0.0
        
        if avg_dist < -2: # significant overlap/crowding
            spacing_tip = "Crowded teeth"
        elif avg_dist < 2:
            spacing_tip = "Crowded teeth"
        elif avg_dist > 10:
            spacing_tip = "Large gaps between teeth"
        else:
            spacing_tip = "Normal spacing"

    # --- Gum Visibility Calculation ---
    gum_visibility = "Normal gum visibility"
    gum_ratio = 0.0
    
    # Restrict gum search to the bounding box of the teeth (with padding)
    hsv = cv2.cvtColor(img_rgb, cv2.COLOR_RGB2HSV)
    
    # Pink/Red range for gums/soft tissue
    lower_pink1 = np.array([0, 40, 40])
    upper_pink1 = np.array([12, 255, 255])
    lower_pink2 = np.array([165, 40, 40])
    upper_pink2 = np.array([180, 255, 255])
    
    mask_pink1 = cv2.inRange(hsv, lower_pink1, upper_pink1)
    mask_pink2 = cv2.inRange(hsv, lower_pink2, upper_pink2)
    gum_mask_full = cv2.bitwise_or(mask_pink1, mask_pink2)
    
    # Identify gum pixels specifically (pink but NOT teeth mask)
    gum_mask = cv2.bitwise_and(gum_mask_full, cv2.bitwise_not(mask_array))
    
    if len(contours) > 0:
        # Bounding box of all teeth
        x, y, w, h = cv2.boundingRect(mask_array)
        # Pad bounding box to focus on immediate surrounding gums (avoid lips/far background)
        H, W = img_rgb.shape[:2]
        pad_top = int(h * 0.4)
        pad_bottom = int(h * 0.2)
        pad_side = int(w * 0.1)
        
        y_min = max(0, y - pad_top)
        y_max = min(H, y + h + pad_bottom)
        x_min = max(0, x - pad_side)
        x_max = min(W, x + w + pad_side)
        
        roi_gum_mask = gum_mask[y_min:y_max, x_min:x_max]
        roi_teeth_mask = mask_array[y_min:y_max, x_min:x_max]
        
        gum_pixels = np.count_nonzero(roi_gum_mask)
        teeth_pixels = np.count_nonzero(roi_teeth_mask)
        
        if (gum_pixels + teeth_pixels) > 0:
            gum_ratio = gum_pixels / (gum_pixels + teeth_pixels)
            
        if gum_ratio < 0.10:
            gum_visibility = "Low gum visibility"
        elif gum_ratio <= 0.25:
            gum_visibility = "Normal gum visibility"
        else:
            gum_visibility = "High gum exposure"

    return spacing_tip, gum_visibility, gum_ratio
