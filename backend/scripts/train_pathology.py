"""
scripts/train_pathology.py
Trains the CavityCNN and GumDiseaseCNN using the downloaded Oral Diseases dataset.
Converts YOLO-style labels into classification labels for binary and multi-class tasks.

Improvements over v1:
    - WeightedRandomSampler + pos_weight for class imbalance
    - Data augmentation (flip, rotation, color jitter)
    - Validation loop with F1 tracking after every epoch
    - ReduceLROnPlateau scheduler
    - Saves best checkpoint (highest val F1)
"""

import os
import sys
import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import Dataset, DataLoader, WeightedRandomSampler
from torchvision import transforms
from pathlib import Path
from PIL import Image

sys.path.append(os.getcwd())

from models.cavity.cnn_model import CavityCNN
from models.gum.cnn_model import GumDiseaseCNN
from core.config import settings


# ─── Dataset ──────────────────────────────────────────────────────────────────

class PathologyDataset(Dataset):
    """
    Classification dataset from YOLO-annotated images.

    Label mapping:
        cavity task : class 0 (Caries)     → 1,  else 0
        gum task    : class 3 (Gingivitis) → 1,  else 0
    """

    def __init__(self, images_dir: Path, labels_dir: Path, transform=None, target_task: str = "cavity"):
        self.images_dir  = images_dir
        self.labels_dir  = labels_dir
        self.transform   = transform
        self.target_task = target_task

        self.samples = []
        for img_path in sorted(images_dir.glob("*.jpg")):
            lbl_path = labels_dir / f"{img_path.stem}.txt"
            if lbl_path.exists():
                self.samples.append((img_path, lbl_path))

        print(f"  Found {len(self.samples)} labeled samples in {images_dir}")

    def __len__(self):
        return len(self.samples)

    def _parse_label(self, lbl_path: Path) -> int:
        label = 0
        with open(lbl_path, "r", encoding="utf-8") as f:
            for line in f:
                parts = line.strip().split()
                if not parts:
                    continue
                cls_id = int(parts[0])
                if self.target_task == "cavity" and cls_id == 0:
                    label = 1
                elif self.target_task == "gum" and cls_id == 3:
                    label = 1
        return label

    def __getitem__(self, idx):
        img_path, lbl_path = self.samples[idx]
        image = Image.open(img_path).convert("RGB")
        label = self._parse_label(lbl_path)

        if self.transform:
            image = self.transform(image)

        if self.target_task == "cavity":
            return image, torch.tensor([label], dtype=torch.float32)
        return image, torch.tensor(label, dtype=torch.long)

    def get_labels(self) -> list:
        """Return all integer labels (used to build sampler weights)."""
        return [self._parse_label(lbl) for _, lbl in self.samples]


# ─── Helpers ──────────────────────────────────────────────────────────────────

def _binary_metrics(y_true: torch.Tensor, y_pred: torch.Tensor) -> dict:
    y_true = y_true.int()
    y_pred = y_pred.int()
    tp = int(((y_true == 1) & (y_pred == 1)).sum())
    tn = int(((y_true == 0) & (y_pred == 0)).sum())
    fp = int(((y_true == 0) & (y_pred == 1)).sum())
    fn = int(((y_true == 1) & (y_pred == 0)).sum())
    total     = tp + tn + fp + fn
    accuracy  = (tp + tn) / total if total else 0.0
    precision = tp / (tp + fp) if (tp + fp) else 0.0
    recall    = tp / (tp + fn) if (tp + fn) else 0.0
    f1        = 2 * precision * recall / (precision + recall) if (precision + recall) else 0.0
    return dict(acc=accuracy, prec=precision, rec=recall, f1=f1, tp=tp, tn=tn, fp=fp, fn=fn)


def _make_sampler(labels: list) -> WeightedRandomSampler:
    """Oversample minority class so each batch is ~balanced."""
    num_pos = sum(labels)
    num_neg = len(labels) - num_pos
    w_neg = 1.0 / max(num_neg, 1)
    w_pos = 1.0 / max(num_pos, 1)
    weights = [w_pos if lbl == 1 else w_neg for lbl in labels]
    return WeightedRandomSampler(weights, num_samples=len(weights), replacement=True)


# ─── Training ─────────────────────────────────────────────────────────────────

def train_model(task: str = "cavity", epochs: int = 40):
    device = torch.device(settings.MODEL_DEVICE)
    print(f"\n{'='*60}")
    print(f"  Training  : {task.upper()}")
    print(f"  Epochs    : {epochs}")
    print(f"  Device    : {device}")
    print(f"{'='*60}")

    root_data  = Path(
        "data/oral-diseases/"
        "Caries_Gingivitus_ToothDiscoloration_Ulcer-yolo_annotated-Dataset/"
        "Caries_Gingivitus_ToothDiscoloration_Ulcer-yolo_annotated-Dataset/Data"
    )
    train_imgs = root_data / "images/train"
    train_lbls = root_data / "labels/train"
    val_imgs   = root_data / "images/val"
    val_lbls   = root_data / "labels/val"

    # ── Transforms ──────────────────────────────────────────────────────────
    train_tf = transforms.Compose([
        transforms.Resize((128, 128)),
        transforms.RandomHorizontalFlip(),
        transforms.RandomVerticalFlip(),
        transforms.RandomRotation(20),
        transforms.ColorJitter(brightness=0.3, contrast=0.3, saturation=0.2, hue=0.05),
        transforms.RandomAffine(degrees=0, translate=(0.1, 0.1)),
        transforms.ToTensor(),
        transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225]),
    ])
    val_tf = transforms.Compose([
        transforms.Resize((128, 128)),
        transforms.ToTensor(),
        transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225]),
    ])

    # ── Datasets ────────────────────────────────────────────────────────────
    train_ds = PathologyDataset(train_imgs, train_lbls, transform=train_tf,  target_task=task)
    val_ds   = PathologyDataset(val_imgs,   val_lbls,   transform=val_tf,    target_task=task)

    train_labels = train_ds.get_labels()
    num_pos = sum(train_labels)
    num_neg = len(train_labels) - num_pos
    print(f"\n  Train distribution : {num_neg} negative  |  {num_pos} positive")

    # ── DataLoaders ─────────────────────────────────────────────────────────
    if num_pos > 0 and num_neg > 0:
        sampler  = _make_sampler(train_labels)
        train_dl = DataLoader(train_ds, batch_size=32, sampler=sampler)
    else:
        train_dl = DataLoader(train_ds, batch_size=32, shuffle=True)

    val_dl = DataLoader(val_ds, batch_size=32, shuffle=False)

    # ── Model & Loss ────────────────────────────────────────────────────────
    if task == "cavity":
        model = CavityCNN().to(device)
        # pos_weight boosts gradient on the rare positive class
        pos_weight = torch.tensor([num_neg / max(num_pos, 1)], device=device)
        criterion  = nn.BCEWithLogitsLoss(pos_weight=pos_weight)
        print(f"  pos_weight         : {pos_weight.item():.2f}")
    else:
        model = GumDiseaseCNN().to(device)
        criterion  = nn.CrossEntropyLoss()

    optimizer = optim.Adam(model.parameters(), lr=1e-3, weight_decay=1e-4)
    scheduler = optim.lr_scheduler.ReduceLROnPlateau(
        optimizer, mode="max", factor=0.5, patience=5, min_lr=1e-6
    )

    best_f1    = -1.0
    best_state = None

    print(f"\n{'-'*60}")
    print(f"{'Epoch':>5}  {'TrainLoss':>9}  {'ValLoss':>7}  "
          f"{'Acc':>6}  {'F1':>6}  {'TP':>4} {'TN':>4} {'FP':>4} {'FN':>4}  {'LR':>8}")
    print(f"{'-'*60}")

    for epoch in range(1, epochs + 1):
        # ── Train ────────────────────────────────────────────────────────
        model.train()
        train_loss = 0.0
        for images, labels in train_dl:
            images, labels = images.to(device), labels.to(device)
            optimizer.zero_grad()
            loss = criterion(model(images), labels)
            loss.backward()
            optimizer.step()
            train_loss += loss.item()
        train_loss /= len(train_dl)

        # ── Validate ─────────────────────────────────────────────────────
        model.eval()
        val_loss = 0.0
        all_true, all_pred = [], []

        with torch.no_grad():
            for images, labels in val_dl:
                images, labels = images.to(device), labels.to(device)
                outputs = model(images)
                val_loss += criterion(outputs, labels).item()

                if task == "cavity":
                    probs  = torch.sigmoid(outputs).view(-1)
                    preds  = (probs >= 0.5).long()
                    truths = labels.view(-1).long()
                else:
                    preds  = torch.argmax(outputs, dim=1)
                    truths = (labels == 1).long()
                    preds  = (preds == 1).long()

                all_true.append(truths.cpu())
                all_pred.append(preds.cpu())

        val_loss /= len(val_dl)
        m = _binary_metrics(torch.cat(all_true), torch.cat(all_pred))

        scheduler.step(m["f1"])
        lr = optimizer.param_groups[0]["lr"]

        if m["f1"] > best_f1:
            best_f1    = m["f1"]
            best_state = {k: v.clone() for k, v in model.state_dict().items()}
            tag = " *"
        else:
            tag = ""

        print(f"{epoch:5d}  {train_loss:9.4f}  {val_loss:7.4f}  "
              f"{m['acc']:6.4f}  {m['f1']:6.4f}  "
              f"{m['tp']:4d} {m['tn']:4d} {m['fp']:4d} {m['fn']:4d}  "
              f"{lr:.2e}{tag}")

    # ── Save best checkpoint ─────────────────────────────────────────────
    if best_state is not None:
        model.load_state_dict(best_state)

    save_path = Path(f"models/{task}/{task}_model.pth")
    save_path.parent.mkdir(parents=True, exist_ok=True)
    torch.save(model.state_dict(), save_path)

    print(f"\n  Best val F1 : {best_f1:.4f}")
    print(f"  Saved to    : {save_path}")
    print(f"{'='*60}")


if __name__ == "__main__":
    train_model(task="cavity", epochs=40)
    train_model(task="gum",    epochs=40)
