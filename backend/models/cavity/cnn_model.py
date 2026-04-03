"""
models/cavity/cnn_model.py
Binary CNN classifier for cavity detection.

Classes:
    0 → no_cavity
    1 → cavity

Input : (B, 3, 128, 128)  — RGB cropped tooth patch
Output: (B, 1)            — logit (apply sigmoid → probability of cavity)
"""

import torch
import torch.nn as nn


class CavityCNN(nn.Module):
    """
    Lightweight CNN for binary cavity classification.

    Architecture:
        Block 1: Conv(3→32)   → BN → ReLU → MaxPool
        Block 2: Conv(32→64)  → BN → ReLU → MaxPool
        Block 3: Conv(64→128) → BN → ReLU → MaxPool
        Head:    Flatten → FC(128*16*16→256) → ReLU → Dropout → FC(256→1)
    """

    def __init__(self):
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

            # Block 3
            nn.Conv2d(64, 128, kernel_size=3, padding=1),
            nn.BatchNorm2d(128),
            nn.ReLU(inplace=True),
            nn.MaxPool2d(2),          # 32→16
        )

        self.classifier = nn.Sequential(
            nn.Flatten(),
            nn.Linear(128 * 16 * 16, 256),
            nn.ReLU(inplace=True),
            nn.Dropout(0.5),
            nn.Linear(256, 1),        # raw logit
        )

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        x = self.features(x)
        return self.classifier(x)   # (B, 1)


# ─── Label map ─────────────────────────────────────────────────────────────────
CAVITY_LABELS = {0: "no_cavity", 1: "cavity"}


def build_cavity_model(device: str = "cpu") -> CavityCNN:
    """
    Instantiate CavityCNN and load trained weights if available.
    """
    import os
    model = CavityCNN()
    
    weights_path = os.path.join("models", "cavity", "cavity_model.pth")
    if os.path.exists(weights_path):
        model.load_state_dict(torch.load(weights_path, map_location=device, weights_only=True))
        print(f"✅ Loaded CavityCNN weights from {weights_path}")
    else:
        print(f"⚠️ Cavity weights not found at {weights_path}, using random initialization.")

    model.to(device)
    model.eval()
    return model
