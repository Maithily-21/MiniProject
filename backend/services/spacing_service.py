import cv2
import numpy as np

def analyze_spacing(segmentation_mask: np.ndarray) -> str:
    """
    Analyzes horizontal spacing between teeth contours to generate cosmetic spacing feedback.
    """
    if segmentation_mask.dtype != np.uint8:
        mask_8u = (segmentation_mask * 255).astype(np.uint8)
    else:
        mask_8u = segmentation_mask.copy()
        
    contours, _ = cv2.findContours(mask_8u, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    
    if not contours or len(contours) < 2:
        return "Tooth spacing appears balanced and within a normal range."

    bounding_boxes = [cv2.boundingRect(c) for c in contours]
    contours_sorted = sorted(zip(contours, bounding_boxes), key=lambda b: b[1][0])
    
    gaps = []
    for i in range(len(contours_sorted) - 1):
        _, box1 = contours_sorted[i]
        _, box2 = contours_sorted[i + 1]
        x1, _, w1, _ = box1
        x2, _, _, _ = box2
        gap = x2 - (x1 + w1)
        if gap > 0:
            gaps.append(gap)
            
    avg_gap = np.mean(gaps) if gaps else 0
    
    if avg_gap < 5:
        return "Limited spacing between teeth suggests crowding. Orthodontic evaluation may help improve alignment."
    elif avg_gap > 15:
        return "Noticeable gaps between teeth are detected. Cosmetic bonding or orthodontic consultation may improve aesthetics."
    else:
        return "Tooth spacing appears balanced and within a normal range."
