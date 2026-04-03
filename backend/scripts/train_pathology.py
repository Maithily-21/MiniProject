"""
scripts/train_pathology.py
Trains the CavityCNN and GumDiseaseCNN using the downloaded Oral Diseases dataset.
Converts YOLO-style labels into classification labels for binary and multi-class tasks.
"""

import os
import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import Dataset, DataLoader
from torchvision import transforms, io
from pathlib import Path
import cv2
import PIL.Image as Image
import numpy as np

# Import models from the main package (assuming scripts/ is a submodule or we add to path)
import sys
sys.path.append(os.getcwd())

from models.cavity.cnn_model import CavityCNN
from models.gum.cnn_model import GumDiseaseCNN
from core.config import settings

# ─── Dataset Class ────────────────────────────────────────────────────────────

class PathologyDataset(Dataset):
    """
    Dataset that reads YOLO-formatted data for classification.
    Maps:
        - Class 0 (Caries) -> Cavity Label 1
        - Class 3 (Gingivitis) -> Gum Disease Label 1 (Mild)
    """
    def __init__(self, images_dir: Path, labels_dir: Path, transform=None, target_task="cavity"):
        self.images_dir = images_dir
        self.labels_dir = labels_dir
        self.transform  = transform
        self.target_task = target_task # "cavity" or "gum"
        
        # Filter files that have labels
        self.samples = []
        image_files = list(images_dir.glob("*.jpg"))
        for img_path in image_files:
            label_path = labels_dir / (img_path.stem + ".txt")
            if label_path.exists():
                self.samples.append((img_path, label_path))
        
        print(f"📊 Found {len(self.samples)} labeled samples in {images_dir.name}")

    def __len__(self):
        return len(self.samples)

    def __getitem__(self, idx):
        img_path, lbl_path = self.samples[idx]
        
        # Load image
        image = Image.open(img_path).convert("RGB")
        
        # Parse labels
        label = 0 # Default: Healthy / No Cavity
        with open(lbl_path, "r") as f:
            for line in f:
                cls_id = int(line.split()[0])
                if self.target_task == "cavity" and cls_id == 0: # Caries
                    label = 1
                elif self.target_task == "gum" and cls_id == 3: # Gingivitis
                    label = 1 # Map to 'Mild' severity in our logic
        
        if self.transform:
            image = self.transform(image)
            
        return image, torch.tensor([label] if self.target_task == "cavity" else label, dtype=torch.float32 if self.target_task == "cavity" else torch.long)

# ─── Training Logic ───────────────────────────────────────────────────────────

def train_model(task="cavity", epochs=2):
    device = torch.device(settings.MODEL_DEVICE)
    print(f"🚀 Training {task} model on {device}...")
    
    # Path setup (using the structure we found)
    root_data = Path("data/oral-diseases/Caries_Gingivitus_ToothDiscoloration_Ulcer-yolo_annotated-Dataset/Caries_Gingivitus_ToothDiscoloration_Ulcer-yolo_annotated-Dataset/Data")
    train_imgs = root_data / "images/train"
    train_lbls = root_data / "labels/train"
    val_imgs   = root_data / "images/val"
    val_lbls   = root_data / "labels/val"
    
    # Transforms
    transform = transforms.Compose([
        transforms.Resize((128, 128)),
        transforms.ToTensor(),
        transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225])
    ])
    
    # Dataloaders
    train_ds = PathologyDataset(train_imgs, train_lbls, transform=transform, target_task=task)
    train_dl = DataLoader(train_ds, batch_size=32, shuffle=True)
    
    # Model & Loss
    if task == "cavity":
        model = CavityCNN().to(device)
        criterion = nn.BCEWithLogitsLoss()
    else:
        model = GumDiseaseCNN().to(device)
        criterion = nn.CrossEntropyLoss()
        
    optimizer = optim.Adam(model.parameters(), lr=0.001)
    
    # Simple training loop
    for epoch in range(epochs):
        model.train()
        running_loss = 0.0
        for images, labels in train_dl:
            images, labels = images.to(device), labels.to(device)
            
            optimizer.zero_grad()
            outputs = model(images)
            loss = criterion(outputs, labels)
            loss.backward()
            optimizer.step()
            
            running_loss += loss.item()
            
        print(f"📁 Epoch {epoch+1}/{epochs} | Loss: {running_loss/len(train_dl):.4f}")
        
    # Save the model
    save_path = Path(f"models/{task}/{task}_model.pth")
    save_path.parent.mkdir(parents=True, exist_ok=True)
    torch.save(model.state_dict(), save_path)
    print(f"✅ Model saved to {save_path}")

if __name__ == "__main__":
    # Train both models for a quick verification epoch
    train_model(task="cavity", epochs=1)
    train_model(task="gum", epochs=1)
