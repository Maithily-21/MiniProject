# ProviDent AI: Project Documentation & Technical Report

## 1. Project Overview
**ProvitDent AI** is a production-ready medical imaging platform designed for intraoral dental analysis. The system leverages deep learning to automate the detection of common dental issues from intraoral photographs. It provides clinicians and patients with automated reports on teeth segmentation, alignment, symmetry, and pathology (cavity and gum disease).

### Key Features:
- **Teeth Segmentation**: Precise pixel-level masking of teeth using U-Net.
- **Alignment Analysis**: Geometric scoring of teeth alignment using centroid line-fitting.
- **Symmetry Scoring**: Left-right IoU comparison to evaluate dental symmetry.
- **Pathology Detection**:
    - **Cavity Detection**: Binary classification (Detected / Not Detected).
    - **Gum Disease Classification**: Multi-class categorization (Healthy / Mild / Severe).

---

## 2. Model Architectures

### A. Teeth Segmentation (U-Net)
The core of the analysis pipeline is a **U-Net** architecture, chosen for its superior performance in biomedical image segmentation.

- **Architecture Type**: Encoder-Decoder with Skip Connections.
- **Encoder**: 
    - Input: `(3, 256, 256)` (RGB)
    - Layers: `64 -> 128 -> 256 -> 512` channels using `DoubleConv` blocks (Conv -> BN -> ReLU).
- **Bottleneck**: `1024` channels at `16x16` resolution.
- **Decoder**: 
    - Mirrors the encoder using `Up` blocks (Bilinear upsample + Concat with skip connection + DoubleConv).
    - Output: `(1, 256, 256)` grayscale mask.
- **Activation**: Sigmoid at the output head for pixel-wise probability.

### B. Cavity Detection (CavityCNN)
A binary classifier that focuses on the teeth region extracted from the segmentation mask.

- **Input**: `(3, 128, 128)` cropped ROI (Region of Interest).
- **Architecture**: A custom CNN consisting of multiple convolutional layers followed by global average pooling and a fully connected layer.
- **Classification**: Binary (Cavity vs. No Cavity) using a 0.5 threshold.

### C. Gum Disease Classification (GumDiseaseCNN)
A multi-class classifier that analyzes the full image to capture texture and color cues from the gingival tissue.

- **Input**: `(3, 128, 128)` resized original image.
- **Classes**: 
    - `0: Healthy`
    - `1: Mild`
    - `2: Severe`
- **Architecture**: Deep CNN with Softmax output for 3-class probability distribution.

---

## 3. Segmentation Process in Detail
The segmentation process is critical as it defines the "Area of Interest" for subsequent analysis.

1. **Preprocessing**: The input image is resized to `256x256` and normalized.
2. **Inference**: The U-Net model predicts a probability map where each pixel value represents the likelihood of being part of a tooth.
3. **Thresholding**: A threshold (typically 0.5) is applied to convert the probability map into a **Binary Mask** (0 = Background, 1 = Teeth).
4. **Post-processing**:
    - The mask is resized back to the original image dimensions using `INTER_NEAREST` interpolation to preserve binary edges.
    - **Overlay Generation**: A semi-transparent color mask is overlaid on the original image for visual verification.
5. **Downstream Usage**: The binary mask is passed to the Alignment and Symmetry services for geometric calculations and to the Cavity service for ROI cropping.

---

## 4. Dataset Information
The models were trained using a combination of public and curated datasets:

- **Primary Dataset**: [Kaggle: Teeth Segmentation](https://www.kaggle.com/datasets/vengatesanv/teeth-segmentation-dataset)
    - Contains intraoral images with high-quality ground-truth masks.
- **Augmentation**: Data was augmented with rotations, flips, and color jittering to improve robustness against varying lighting conditions in dental clinics.
- **Pathology Data**: Custom curated datasets for cavity and gum disease labels, using professional clinical annotations.

---

## 5. Technology Stack & Libraries

### Backend (Python/FastAPI)
- **FastAPI**: High-performance web framework for the REST API.
- **Uvicorn**: ASGI server for production deployment.
- **SQLAlchemy**: ORM for managing user reports and metadata (SQLite/PostgreSQL).
- **Pydantic**: Data validation and settings management.

### AI / Computer Vision
- **PyTorch**: Deep learning framework for model training and inference.
- **OpenCV**: Computer vision library for image preprocessing and geometric analysis.
- **NumPy**: Linear algebra and array manipulations.
- **Pillow**: Image loading and saving.

---

## 6. Backend Folder Structure
The backend is organized using a professional service-oriented architecture:

```text
backend/
├── core/               # Configuration and security (JWT, settings)
├── database/           # DB session and SQLAlchemy models
├── models/             # PyTorch model definitions (.py) and weights (.pth)
│   ├── segmentation/   # U-Net architecture
│   ├── cavity/         # CavityCNN
│   └── gum/            # GumDiseaseCNN
├── routes/             # FastAPI API endpoints
│   ├── auth.py         # User registration and login
│   └── analysis.py     # Main AI pipeline (/analyze)
├── services/           # Business logic (AI orchestration)
├── utils/              # Helper functions (Image processing)
├── uploads/            # Temporary storage for uploaded images
├── outputs/            # Storage for generated masks and overlays
├── requirements.txt    # Dependency list
└── main.py             # Application entry point
```
