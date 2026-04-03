"""
scripts/evaluate.py
Tests the entire AI analysis pipeline on a sample image from the dataset.
Verifies that the segmentation, alignment, symmetry, cavity, and gum services work together.
"""

import os
import torch
import cv2
import numpy as np
from pathlib import Path
from dotenv import load_dotenv

# Add root to path
import sys
sys.path.append(os.getcwd())

# Import services
from services.segmentation_service import run_segmentation
from services.alignment_service import compute_alignment_score
from services.symmetry_service import compute_symmetry_score
from services.cavity_service import detect_cavity
from services.gum_service import detect_gum_disease

# Configuration
TEST_IMAGE = Path("data/oral-diseases/Caries_Gingivitus_ToothDiscoloration_Ulcer-yolo_annotated-Dataset/Caries_Gingivitus_ToothDiscoloration_Ulcer-yolo_annotated-Dataset/Data/images/val/(225).jpg")
OUTPUT_DIR = Path("outputs/test_eval")
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

def run_evaluation():
    print(f"🔍 Starting evaluation on: {TEST_IMAGE.name}")
    
    if not TEST_IMAGE.exists():
        print(f"❌ Error: Test image not found at {TEST_IMAGE}")
        return

    # 1. Segmentation
    print("🦷 Running Teeth Segmentation...")
    seg_results = run_segmentation(str(TEST_IMAGE))
    mask_array   = seg_results["mask_array"]
    overlay_path = seg_results["overlay_path"]
    print(f"✅ Segmentation mask generated: {mask_array.shape}")
    print(f"🖼️ Overlay saved to: {overlay_path}")

    # 2. Alignment
    print("📏 Detecting Teeth Alignment...")
    alignment_results = compute_alignment_score(mask_array)
    print(f"✅ Alignment Score: {alignment_results['alignment_score']}")

    # 3. Symmetry
    print("🪞 Computing Symmetry...")
    symmetry_results = compute_symmetry_score(mask_array)
    print(f"✅ Symmetry Score: {symmetry_results['symmetry_score']}")

    # 4. Cavity Detection
    print("🦷 Detecting Cavities...")
    cavity_results = detect_cavity(str(TEST_IMAGE), mask_array)
    print(f"✅ Cavity Status: {cavity_results['label']} (Conf: {cavity_results['confidence']:.2f})")

    # 5. Gum Disease Detection
    print("🩸 Classifying Gum Health...")
    gum_results = detect_gum_disease(str(TEST_IMAGE))
    print(f"✅ Gum Condition: {gum_results['label']} (Conf: {gum_results['confidence']:.2f})")

    print("\n🎉 Full Pipeline Evaluation Successful!")

if __name__ == "__main__":
    run_evaluation()
