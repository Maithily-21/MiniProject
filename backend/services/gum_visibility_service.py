import numpy as np

def analyze_gum_visibility(segmentation_mask: np.ndarray) -> str:
    teeth_pixels = np.count_nonzero(segmentation_mask)
    total_pixels = segmentation_mask.size
    
    gum_pixels = total_pixels - teeth_pixels
    
    gum_ratio = 0.0
    if total_pixels > 0:
        gum_ratio = gum_pixels / total_pixels
        
    if gum_ratio < 0.10:
        return "Minimal gum exposure is observed. This is typically within a healthy and aesthetically balanced range."
    elif 0.10 <= gum_ratio <= 0.25:
        return "Gum display appears balanced and within a normal aesthetic range."
    else:
        return "Higher gum exposure is observed. A cosmetic dental evaluation may help assess smile aesthetics."
