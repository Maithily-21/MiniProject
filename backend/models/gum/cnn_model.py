"""
models/gum/cnn_model.py
Multi-class CNN classifier for gum disease severity detection.

Classes:
    0 → healthy
    1 → mild
    2 → severe

Input : (B, 3, 128, 128)  — RGB cropped gum region
Output: (B, 3)            — logits (apply softmax → class probabilities)
"""

import torch
import torch.nn as nn


class GumDiseaseCNN(nn.Module):
    """
    CNN for 3-class gum disease classification.

    Architecture:
        Block 1: Conv(3→32)    → BN → ReLU → MaxPool
        Block 2: Conv(32→64)   → BN → ReLU → MaxPool
        Block 3: Conv(64→128)  → BN → ReLU → AdaptiveAvgPool(4×4)
        Head:    Flatten → FC(128*4*4→256) → ReLU → Dropout → FC(256→3)
    """

    def __init__(self, num_classes: int = 3):
        super().__init__()

        self.features = nn.Sequential(
            # Block 1
            nn.Conv2d(3, 32, kernel_size=3, padding=1),
            nn.BatchNorm2d(32),
            nn.ReLU(inplace=True),
            nn.MaxPool2d(2),          # 128→64

            # Block 2
            nn.Conv2d(32, 64, kernel_size=3, padding=1),
            nn.BatchNorm2d(64),
            nn.ReLU(inplace=True),
            nn.MaxPool2d(2),          # 64→32

            # Block 3 — AdaptiveAvgPool makes it input-size agnostic
            nn.Conv2d(64, 128, kernel_size=3, padding=1),
            nn.BatchNorm2d(128),
            nn.ReLU(inplace=True),
            nn.AdaptiveAvgPool2d((4, 4)),   # → (B, 128, 4, 4)
        )

        self.classifier = nn.Sequential(
            nn.Flatten(),
            nn.Linear(128 * 4 * 4, 256),
            nn.ReLU(inplace=True),
            nn.Dropout(0.5),
            nn.Linear(256, num_classes),    # raw logits
        )

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        x = self.features(x)
        return self.classifier(x)   # (B, num_classes)


# ─── Label map ─────────────────────────────────────────────────────────────────
GUM_LABELS = {0: "healthy", 1: "mild", 2: "severe"}


def build_gum_model(device: str = "cpu") -> GumDiseaseCNN:
    """
    Instantiate GumDiseaseCNN and load trained weights if available.
    """
    import os
    model = GumDiseaseCNN(num_classes=3)
    
    weights_path = os.path.join("models", "gum", "gum_model.pth")
    if os.path.exists(weights_path):
        model.load_state_dict(torch.load(weights_path, map_location=device, weights_only=True))
        print(f"✅ Loaded GumDiseaseCNN weights from {weights_path}")
    else:
        print(f"⚠️ Gum weights not found at {weights_path}, using random initialization.")

    model.to(device)
    model.eval()
    return model
