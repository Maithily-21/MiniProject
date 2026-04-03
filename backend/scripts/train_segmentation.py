"""
scripts/train_segmentation.py
Trains the U-Net model using the YOLO boxes converted to masks.
Focuses on segmenting any annotated dental pathology as a proxy for 'teeth segmentation'.
"""

import os
import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import Dataset, DataLoader
from torchvision import transforms
from pathlib import Path
import cv2
import PIL.Image as Image
import numpy as np

# Add project root to sys.path
import sys
sys.path.append(os.getcwd())

from models.segmentation.unet import UNet
from core.config import settings

# ─── Dataset Class ────────────────────────────────────────────────────────────

class SegmentationDataset(Dataset):
    """
    Dataset that reads YOLO-formatted data and converts boxes into binary masks.
    We convert the YOLO normalized (cls, x, y, w, h) into a full-size binary mask.
    """
    def __init__(self, images_dir: Path, labels_dir: Path, img_size=(256, 256)):
        self.images_dir = images_dir
        self.labels_dir = labels_dir
        self.img_size   = img_size
        
        self.samples = []
        image_files = list(images_dir.glob("*.jpg"))
        for img_path in image_files:
            label_path = labels_dir / (img_path.stem + ".txt")
            if label_path.exists():
                self.samples.append((img_path, label_path))
        
        print(f"🧬 Found {len(self.samples)} samples for segmentation training")

    def __len__(self):
        return len(self.samples)

    def __getitem__(self, idx):
        img_path, lbl_path = self.samples[idx]
        
        # Load and resize image
        image = cv2.imread(str(img_path))
        image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
        h, w, _ = image.shape
        image = cv2.resize(image, self.img_size)
        
        # Create mask
        mask = np.zeros((h, w), dtype=np.uint8)
        with open(lbl_path, "r") as f:
            for line in f:
                _, cx, cy, bw, bh = map(float, line.split())
                # Convert normalized to pixel coords
                x1 = int((cx - bw/2) * w)
                y1 = int((cy - bh/2) * h)
                x2 = int((cx + bw/2) * w)
                y2 = int((cy + bh/2) * h)
                # Draw white rectangle on mask
                cv2.rectangle(mask, (x1, y1), (x2, y2), 255, -1)
                
        # Resize mask to target size
        mask = cv2.resize(mask, self.img_size, interpolation=cv2.INTER_NEAREST)
        
        # Preprocessing for Torch
        image = image.transpose(2, 0, 1).astype(np.float32) / 255.0
        mask  = (mask > 0).astype(np.float32)[np.newaxis, ...] # (1, H, W)
        
        return torch.tensor(image), torch.tensor(mask)

# ─── Training Logic ───────────────────────────────────────────────────────────

def train_unet(epochs=2):
    device = torch.device(settings.MODEL_DEVICE)
    print(f"🌌 Training U-Net on {device}...")
    
    # Path setup
    root_data = Path("data/oral-diseases/Caries_Gingivitus_ToothDiscoloration_Ulcer-yolo_annotated-Dataset/Caries_Gingivitus_ToothDiscoloration_Ulcer-yolo_annotated-Dataset/Data")
    train_imgs = root_data / "images/train"
    train_lbls = root_data / "labels/train"
    
    # Dataloader
    dataset = SegmentationDataset(train_imgs, train_lbls)
    dataloader = DataLoader(dataset, batch_size=8, shuffle=True)
    
    # Model & Optimization
    model = UNet(in_channels=3, out_channels=1).to(device)
    criterion = nn.BCEWithLogitsLoss()
    optimizer = optim.Adam(model.parameters(), lr=0.0001)
    
    # Training Loop
    for epoch in range(epochs):
        model.train()
        epoch_loss = 0.0
        for i, (images, masks) in enumerate(dataloader):
            images, masks = images.to(device), masks.to(device)
            
            optimizer.zero_grad()
            outputs = model(images)
            loss = criterion(outputs, masks)
            loss.backward()
            optimizer.step()
            
            epoch_loss += loss.item()
            if (i+1) % 10 == 0:
                print(f"  Step [{i+1}/{len(dataloader)}] | Loss: {loss.item():.4f}")
        
        print(f"✨ Epoch {epoch+1}/{epochs} Complete | Avg Loss: {epoch_loss/len(dataloader):.4f}")

    # Save
    save_dir = Path("models/segmentation")
    save_dir.mkdir(parents=True, exist_ok=True)
    torch.save(model.state_dict(), save_dir / "unet_model.pth")
    print(f"🎬 U-Net weights saved to {save_dir / 'unet_model.pth'}")

if __name__ == "__main__":
    train_unet(epochs=1)
