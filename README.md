# 🦷 Dental AI Analysis System

An AI-powered system for analyzing intraoral images to detect **cavities, gum diseases, and perform dental segmentation** using deep learning models.

---

## 🚀 Features

- 🦷 Cavity Detection  
- 🩺 Gum Disease Detection  
- 📐 Teeth & Smile Segmentation  
- 📊 Cosmetic Analysis (alignment & symmetry)  
- ⚡ FastAPI Backend (REST APIs)  
- 🎨 Streamlit Frontend  

---

## 🧠 Tech Stack

**Backend:** FastAPI, Python  
**ML/DL:** PyTorch / TensorFlow, OpenCV, NumPy  
**Frontend:** Streamlit  

---

## Model Pipeline 

```
Intraoral Image
   ↓
Segmentation Model
   ↓
Feature Extraction
   ↓
Cavity Detection Model
   ↓
Gum Disease Model
   ↓
Cosmetic Analysis Report
```


## 📊 Dataset

This project uses the **Oral Diseases Dataset** from Kaggle:

* Dataset: https://www.kaggle.com/datasets/salmansajid05/oral-diseases
* It contains images of multiple dental conditions such as caries, gingivitis, ulcers, and tooth discoloration. ([Kaggle][1])

---

## ⚠️ Note

The dataset is **NOT included in this repository** due to size limitations.
You need to download it manually using the Kaggle API.

---

## 🚀 How to Download Dataset Using Kaggle API

### 🔹 Step 1: Install Kaggle

```bash
pip install kaggle
```

---

### 🔹 Step 2: Get Kaggle API Key

1. Go to Kaggle → Account Settings
2. Click **"Create New API Token"**
3. This will download a file:

```
kaggle.json
```

---

### 🔹 Step 3: Add API Key to System

#### 👉 Windows (PowerShell)

```bash
mkdir $HOME\.kaggle
move kaggle.json $HOME\.kaggle\
```

---

### 🔹 Step 4: Add Your Credentials (Optional)

Open `kaggle.json`:

```json
{
  "username": "your_kaggle_username",
  "key": "your_api_key"
}
```

---

### 🔹 Step 5: Download Dataset

Run this command:

```bash
kaggle datasets download -d salmansajid05/oral-diseases
```

---

### 🔹 Step 6: Extract Dataset

```bash
unzip oral-diseases.zip -d backend/data/
```

---

## 📁 Expected Folder Structure

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

---

## ✅ Quick Setup (One Command)

```bash
pip install kaggle && kaggle datasets download -d salmansajid05/oral-diseases && unzip oral-diseases.zip -d backend/data/
```

---

## 💡 Tip

Make sure `backend/data/` is added to `.gitignore` to avoid uploading large files.

[1]: https://www.kaggle.com/datasets/salmansajid05/oral-diseases?utm_source=chatgpt.com "Oral Diseases"
