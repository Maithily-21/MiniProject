"""
models/segmentation/unet.py
U-Net architecture for teeth segmentation.
Input : (B, 1, 256, 256)  — single-channel grayscale
Output: (B, 1, 256, 256)  — binary mask (sigmoid activated)
"""

import torch
import torch.nn as nn
import torch.nn.functional as F


# ─── Building Blocks ───────────────────────────────────────────────────────────

class DoubleConv(nn.Module):
    """Two consecutive Conv → BN → ReLU blocks (the core U-Net unit)."""

    def __init__(self, in_channels: int, out_channels: int):
        super().__init__()
        self.block = nn.Sequential(
            nn.Conv2d(in_channels, out_channels, kernel_size=3, padding=1, bias=False),
            nn.BatchNorm2d(out_channels),
            nn.ReLU(inplace=True),
            nn.Conv2d(out_channels, out_channels, kernel_size=3, padding=1, bias=False),
            nn.BatchNorm2d(out_channels),
            nn.ReLU(inplace=True),
        )

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        return self.block(x)


class Down(nn.Module):
    """MaxPool → DoubleConv  (encoder step)."""

    def __init__(self, in_channels: int, out_channels: int):
        super().__init__()
        self.pool_conv = nn.Sequential(
            nn.MaxPool2d(2),
            DoubleConv(in_channels, out_channels),
        )

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        return self.pool_conv(x)


class Up(nn.Module):
    """Bilinear upsample → concat with skip → DoubleConv  (decoder step)."""

    def __init__(self, in_channels: int, out_channels: int):
        super().__init__()
        # in_channels = encoder_channels + decoder_channels (skip connection)
        self.up   = nn.Upsample(scale_factor=2, mode="bilinear", align_corners=True)
        self.conv = DoubleConv(in_channels, out_channels)

    def forward(self, x: torch.Tensor, skip: torch.Tensor) -> torch.Tensor:
        x = self.up(x)
        # Pad if sizes differ (handles non-divisible input dims)
        diff_h = skip.size(2) - x.size(2)
        diff_w = skip.size(3) - x.size(3)
        x = F.pad(x, [diff_w // 2, diff_w - diff_w // 2,
                       diff_h // 2, diff_h - diff_h // 2])
        x = torch.cat([skip, x], dim=1)
        return self.conv(x)


# ─── U-Net ─────────────────────────────────────────────────────────────────────

class UNet(nn.Module):
    """
    Lightweight U-Net for binary teeth segmentation.

    Architecture:
        Encoder: 1→64→128→256→512
        Bottleneck: 512→1024
        Decoder: mirrors encoder with skip connections
        Head: 1×1 Conv → Sigmoid → binary mask
    """

    def __init__(self, in_channels: int = 1, out_channels: int = 1):
        super().__init__()

        # Encoder
        self.inc   = DoubleConv(in_channels, 64)
        self.down1 = Down(64,  128)
        self.down2 = Down(128, 256)
        self.down3 = Down(256, 512)

        # Bottleneck
        self.bottleneck = Down(512, 1024)

        # Decoder  (in_channels = up_input + skip)
        self.up1 = Up(1024 + 512, 512)
        self.up2 = Up(512  + 256, 256)
        self.up3 = Up(256  + 128, 128)
        self.up4 = Up(128  +  64,  64)

        # Output head
        self.out_conv = nn.Conv2d(64, out_channels, kernel_size=1)

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        # Encoder path — save feature maps for skip connections
        s1 = self.inc(x)         # 256×256, 64ch
        s2 = self.down1(s1)      # 128×128, 128ch
        s3 = self.down2(s2)      #  64× 64, 256ch
        s4 = self.down3(s3)      #  32× 32, 512ch

        # Bottleneck
        b  = self.bottleneck(s4) #  16× 16, 1024ch

        # Decoder path
        x = self.up1(b,  s4)     #  32× 32, 512ch
        x = self.up2(x,  s3)     #  64× 64, 256ch
        x = self.up3(x,  s2)     # 128×128, 128ch
        x = self.up4(x,  s1)     # 256×256,  64ch

        # Final pixel-wise binary prediction
        return torch.sigmoid(self.out_conv(x))


def build_unet(device: str = "cpu") -> UNet:
    """
    Instantiate U-Net and load trained weights if available.
    """
    import os
    model = UNet(in_channels=3, out_channels=1)  # RGB input for better feature extraction
    
    weights_path = os.path.join("models", "segmentation", "unet_model.pth")
    if os.path.exists(weights_path):
        model.load_state_dict(torch.load(weights_path, map_location=device, weights_only=True))
        print(f"✅ Loaded U-Net weights from {weights_path}")
    else:
        print(f"⚠️ U-Net weights not found at {weights_path}, using random initialization.")

    model.to(device)
    model.eval()
    return model
