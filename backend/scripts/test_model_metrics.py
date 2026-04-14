"""
scripts/test_model_metrics.py
Evaluate trained pathology models and report:
- Accuracy
- Precision
- Recall
- F1-score
- Model summary (architecture + parameter counts)

Usage examples:
    venv\\Scripts\\python scripts/test_model_metrics.py --task cavity --split val
    venv\\Scripts\\python scripts/test_model_metrics.py --task gum --split val
"""

import argparse
import os
import sys
from pathlib import Path

import torch
from torch.utils.data import DataLoader, Dataset
from torchvision import transforms
from PIL import Image


sys.path.append(os.getcwd())

from core.config import settings
from models.cavity.cnn_model import CavityCNN
from models.gum.cnn_model import GumDiseaseCNN


class PathologyDataset(Dataset):
    """
    Classification dataset from YOLO labels.

    Label mapping used during training:
        - cavity task: class 0 (caries) -> 1, else 0
        - gum task: class 3 (gingivitis) -> 1, else 0
    """

    def __init__(self, images_dir: Path, labels_dir: Path, transform=None, target_task: str = "cavity"):
        self.images_dir = images_dir
        self.labels_dir = labels_dir
        self.transform = transform
        self.target_task = target_task

        self.samples = []
        for img_path in images_dir.glob("*.jpg"):
            lbl_path = labels_dir / f"{img_path.stem}.txt"
            if lbl_path.exists():
                self.samples.append((img_path, lbl_path))

        print(f"Found {len(self.samples)} labeled samples in {images_dir}")

    def __len__(self):
        return len(self.samples)

    def __getitem__(self, idx):
        img_path, lbl_path = self.samples[idx]
        image = Image.open(img_path).convert("RGB")

        label = 0
        with open(lbl_path, "r", encoding="utf-8") as f:
            for line in f:
                cls_id = int(line.split()[0])
                if self.target_task == "cavity" and cls_id == 0:
                    label = 1
                elif self.target_task == "gum" and cls_id == 3:
                    label = 1

        if self.transform:
            image = self.transform(image)

        if self.target_task == "cavity":
            return image, torch.tensor([label], dtype=torch.float32)
        return image, torch.tensor(label, dtype=torch.long)


def compute_binary_metrics(y_true: torch.Tensor, y_pred: torch.Tensor):
    """Compute binary accuracy/precision/recall/f1 without external deps."""
    y_true = y_true.int()
    y_pred = y_pred.int()

    tp = int(((y_true == 1) & (y_pred == 1)).sum().item())
    tn = int(((y_true == 0) & (y_pred == 0)).sum().item())
    fp = int(((y_true == 0) & (y_pred == 1)).sum().item())
    fn = int(((y_true == 1) & (y_pred == 0)).sum().item())

    total = tp + tn + fp + fn
    accuracy = (tp + tn) / total if total else 0.0
    precision = tp / (tp + fp) if (tp + fp) else 0.0
    recall = tp / (tp + fn) if (tp + fn) else 0.0
    f1 = (2 * precision * recall / (precision + recall)) if (precision + recall) else 0.0

    return {
        "accuracy": accuracy,
        "precision": precision,
        "recall": recall,
        "f1": f1,
        "tp": tp,
        "tn": tn,
        "fp": fp,
        "fn": fn,
    }


def print_model_summary(model: torch.nn.Module, task: str):
    total_params = sum(p.numel() for p in model.parameters())
    trainable_params = sum(p.numel() for p in model.parameters() if p.requires_grad)

    print("\n" + "=" * 72)
    print(f"MODEL SUMMARY ({task.upper()})")
    print("=" * 72)
    print(model)
    print("-" * 72)
    print(f"Total parameters:     {total_params:,}")
    print(f"Trainable parameters: {trainable_params:,}")
    print("=" * 72 + "\n")


def evaluate(task: str, split: str, batch_size: int, threshold: float):
    device = torch.device(settings.MODEL_DEVICE)
    print(f"Using device: {device}")

    root_data = Path(
        "data/oral-diseases/"
        "Caries_Gingivitus_ToothDiscoloration_Ulcer-yolo_annotated-Dataset/"
        "Caries_Gingivitus_ToothDiscoloration_Ulcer-yolo_annotated-Dataset/Data"
    )
    images_dir = root_data / f"images/{split}"
    labels_dir = root_data / f"labels/{split}"

    if not images_dir.exists() or not labels_dir.exists():
        raise FileNotFoundError(f"Missing split paths: {images_dir} or {labels_dir}")

    transform = transforms.Compose(
        [
            transforms.Resize((128, 128)),
            transforms.ToTensor(),
            transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225]),
        ]
    )

    dataset = PathologyDataset(images_dir, labels_dir, transform=transform, target_task=task)
    if len(dataset) == 0:
        raise RuntimeError("No labeled samples found for evaluation.")

    dataloader = DataLoader(dataset, batch_size=batch_size, shuffle=False)

    if task == "cavity":
        model = CavityCNN()
        weights_path = Path("models/cavity/cavity_model.pth")
    else:
        model = GumDiseaseCNN(num_classes=3)
        weights_path = Path("models/gum/gum_model.pth")

    if not weights_path.exists():
        raise FileNotFoundError(f"Model weights not found: {weights_path}")

    model.load_state_dict(torch.load(weights_path, map_location=device, weights_only=True))
    model.to(device)
    model.eval()

    print_model_summary(model, task)

    all_true = []
    all_pred = []

    with torch.no_grad():
        for images, labels in dataloader:
            images = images.to(device)
            labels = labels.to(device)

            outputs = model(images)

            if task == "cavity":
                probs = torch.sigmoid(outputs).view(-1)
                preds = (probs >= threshold).long()
                truths = labels.view(-1).long()
            else:
                preds = torch.argmax(outputs, dim=1)
                truths = (labels == 1).long()
                preds = (preds == 1).long()

            all_true.append(truths.cpu())
            all_pred.append(preds.cpu())

    y_true = torch.cat(all_true)
    y_pred = torch.cat(all_pred)

    metrics = compute_binary_metrics(y_true, y_pred)

    print("Evaluation Metrics")
    print("-" * 72)
    print(f"Task:      {task}")
    print(f"Split:     {split}")
    print(f"Samples:   {len(y_true)}")
    print(f"Accuracy:  {metrics['accuracy']:.4f}")
    print(f"Precision: {metrics['precision']:.4f}")
    print(f"Recall:    {metrics['recall']:.4f}")
    print(f"F1-score:  {metrics['f1']:.4f}")
    print("-" * 72)
    print(
        f"Confusion matrix counts -> TP: {metrics['tp']} | TN: {metrics['tn']} | "
        f"FP: {metrics['fp']} | FN: {metrics['fn']}"
    )


def parse_args():
    parser = argparse.ArgumentParser(description="Evaluate pathology models and print metrics + summary")
    parser.add_argument("--task", choices=["cavity", "gum"], default="cavity", help="Model task to evaluate")
    parser.add_argument("--split", choices=["train", "val", "test"], default="val", help="Dataset split")
    parser.add_argument("--batch-size", type=int, default=32, help="Batch size for evaluation")
    parser.add_argument("--threshold", type=float, default=0.5, help="Sigmoid threshold for cavity task")
    return parser.parse_args()


if __name__ == "__main__":
    args = parse_args()
    evaluate(task=args.task, split=args.split, batch_size=args.batch_size, threshold=args.threshold)
