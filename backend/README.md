# 🦷 AI Dental Analysis System — Backend

A **production-ready FastAPI backend** that accepts intraoral dental images and runs a multi-stage AI pipeline to generate structured cosmetic/diagnostic reports using PyTorch-based machine learning models.

---

## 📁 Project Structure

```text
backend/
├── main.py                          # FastAPI app entry point
├── .env                             # Environment variables (Kaggle credentials, Secret Key)
├── requirements.txt                 # Dependencies (FastAPI, PyTorch, KaggleHub, etc.)
│
├── core/
│   ├── config.py                    # Pydantic settings (loads from .env)
│   └── security.py                  # JWT, password hashing
│
├── database/
│   ├── db.py                        # SQLAlchemy engine/session
│   ├── models.py                    # ORM: User, AnalysisReport
│   └── schemas.py                   # Pydantic DTOs
│
├── services/
│   ├── segmentation_service.py      # U-Net: Tooth mask generation
│   ├── alignment_service.py         # Geometry: Alignment scoring
│   ├── symmetry_service.py          # Pixel IoU: Symmetry scoring
│   ├── cavity_service.py            # CNN: Cavity detection
│   ├── gum_service.py               # CNN: Gum health classification
│   └── report_service.py            # Result aggregation & DB persistence
│
├── models/
│   ├── segmentation/                # U-Net architecture & weights (unet_model.pth)
│   ├── cavity/                      # CavityCNN & weights (cavity_model.pth)
│   └── gum/                         # GumCNN & weights (gum_model.pth)
│
├── scripts/
│   ├── download_pathology.py        # Data acquisition via KaggleHub
│   ├── train_segmentation.py        # U-Net training pipeline
│   ├── train_pathology.py           # CNN training pipeline (Cavity/Gum)
│   └── evaluate.py                  # Full pipeline integration test
│
├── data/                            # Training datasets (Oral Diseases)
├── uploads/                         # User-uploaded intraoral images
└── outputs/                         # Generated masks and overlays
```

---

## ⚙️ Setup & Installation

### 1. Create and activate a virtual environment
```bash
python -m venv venv
# Windows
venv\Scripts\activate
# Linux/macOS
source venv/bin/activate
```

### 2. Install dependencies
```bash
pip install -r requirements.txt
```

### 3. Configure environment variables
Create a `.env` file in the `backend/` directory:
```env
KAGGLE_USERNAME="your_username"
KAGGLE_KEY="your_api_token"
SECRET_KEY="your-super-secret-key"
DATABASE_URL="sqlite:///./dental_analysis.db"
MODEL_DEVICE="cpu" # or "cuda"
```
## 📊 Dataset

This project uses the **Oral Diseases Dataset** from Kaggle:

- Dataset: https://www.kaggle.com/datasets/salmansajid05/oral-diseases  
- It contains images of multiple dental conditions such as caries, gingivitis, ulcers, and tooth discoloration.

---

## ⚠️ Note
The dataset is **NOT included in this repository** due to size limitations.  
You need to download it manually using the Kaggle API.

---

## 🚀 How to Download Dataset Using Kaggle API

### 🔹 Step 1: Install Kaggle
```bash
pip install kaggle
---

## 🧠 Model Training & Data
🔹 Get Kaggle API Key
Go to Kaggle → Account Settings
Click "Create New API Token"
This will download a file:

kaggle.json 

{
  "username": "your_kaggle_username",
  "key": "your_api_key"
}

```bash
backend/
  data/
    caries/
    gingivitis/
    ulcer/
    tooth_discoloration/
    calculus/
    hypodontia/
```

### 1. Data Acquisition
Download the clinical dental dataset from Kaggle:
```bash
venv\Scripts\python scripts/download_pathology.py
```

### 2. Train the Models
To generate the `.pth` weights for the AI pipeline, run the training scripts:
```bash
# Train Cavity and Gum Disease CNNs
venv\Scripts\python scripts/train_pathology.py

# Train the U-Net Segmentation model
venv\Scripts\python scripts/train_segmentation.py
```

### 3. Verify Integration
Run the evaluation script to test the entire pipeline on a sample image:
```bash
venv\Scripts\python scripts/evaluate.py
```

---

## 📡 API Reference

### Authentication
| Method | Endpoint | Description |
| :--- | :--- | :--- |
| POST | `/auth/register` | Register a new account |
| POST | `/auth/login` | Receive JWT Bearer token |
| GET | `/auth/me` | Current user profile |

### Analysis & Reports
| Method | Endpoint | Description |
| :--- | :--- | :--- |
| POST | `/analyze` | Upload image & run AI Pipeline |
| GET | `/reports` | List all previous analysis reports |
| GET | `/reports/{id}` | Get detailed report by ID |
| DELETE | `/report/{id}` | Remove report and associated files |

---

## 🧠 AI Pipeline Details

| Stage | Model | Logic |
| :--- | :--- | :--- |
| **Segmentation** | **U-Net** | Produces a pixel-wise mask identifying teeth boundaries. |
| **Alignment** | **Geometric** | Fits a line through tooth centroids to measure deviation. |
| **Symmetry** | **Pixel IoU** | Calculates overlap between left and right side masks. |
| **Cavity** | **CNN** | Binary classification for dental caries presence. |
| **Gum Health** | **CNN** | Classifies gum tissue as Healthy, Mild, or Severe. |

---

## 🔒 Security & Deployment

- **Authentication**: JWT-based stateless authentication with bcrypt password hashing.
- **Production Server**: Use `gunicorn` with `uvicorn` workers.
- **Scalability**: Designed for easy migration to PostgreSQL or Cloud Storage (S3/GCS).

---

> [!NOTE]
> This system is for educational/demonstrative purposes. For clinical use, models should be trained on significantly larger, diverse datasets for at least 100+ epochs.
