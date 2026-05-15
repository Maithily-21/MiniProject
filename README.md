# 🦷 Provident: AI Dental Analysis System

An AI-powered mobile application and backend system for analyzing intraoral images to detect **cavities, gum diseases, and perform dental cosmetic analysis** using deep learning models. 

It features a professional Flutter mobile app, a FastAPI python backend, and an intelligent Multilingual AI Chatbot Assistant.

---

## 🚀 Features

- **Mobile First:** Cross-platform Flutter mobile application.
- **AI Analysis:** Detects cavities, gum health, alignment, symmetry, spacing, and staining using PyTorch models.
- **Multilingual Assistant:** Built-in AI Chatbot providing professional guidance in English, Hindi, and Marathi.
- **PDF Reports:** Generates clean, medical-grade PDF reports directly on the device.
- **Robust Backend:** Fast REST APIs built with FastAPI.

---

## 🧠 Tech Stack

- **Backend:** Python, FastAPI, Uvicorn
- **ML/DL:** PyTorch, OpenCV, NumPy
- **Frontend:** Flutter, Dart
- **State Management:** Provider (Flutter)

---

## 💻 1. Backend Setup (FastAPI)

The backend is responsible for running the PyTorch AI models (U-Net, CNNs).

### Step 1: Install Python Dependencies
Navigate to the `backend/` folder and install the required packages:
```bash
cd backend
pip install -r requirements.txt
```

### Step 2: Download the Dataset (Optional for inference)
If you want to train or modify the models, download the **Oral Diseases Dataset** from Kaggle:
```bash
pip install kaggle
kaggle datasets download -d salmansajid05/oral-diseases
unzip oral-diseases.zip -d data/
```

### Step 3: Run the Local Server
Start the FastAPI server on all interfaces so your phone/emulator can connect to it:
```bash
uvicorn main:app --host 0.0.0.0 --port 8000
```
*Note: Ensure your Windows Firewall allows incoming connections on Port 8000.*

---

## 📱 2. Frontend Setup (Flutter App)

The frontend is a beautifully designed mobile app that communicates with the backend.

### Step 1: Install Flutter Requirements
Navigate to the Flutter project directory:
```bash
cd provident_flutter/provident_flutter
flutter pub get
```

### Step 2: Configure Local IP
Since the app needs to talk to the backend running on your laptop, you must configure your local IP address:
1. Open your terminal and run `ipconfig` (Windows) or `ifconfig` (Mac/Linux).
2. Find your **IPv4 Address** (e.g., `10.109.x.x` or `192.168.x.x`).
3. Open `lib/services/backend_service.dart`.
4. Update the `baseUrl` variable to match your IP:
   ```dart
   static const String baseUrl = String.fromEnvironment(
     'BACKEND_URL',
     defaultValue: 'http://YOUR_IPV4_ADDRESS:8000',
   );
   ```

### Step 3: Connect Device and Run
Ensure your Android/iOS device and your laptop are connected to the **exact same WiFi network**.

**Run the app in debug mode:**
```bash
flutter run
```

**Or build a release APK:**
```bash
flutter build apk --release
```
The APK will be generated at `build/app/outputs/flutter-apk/app-release.apk`. Transfer it to your phone and install!

---

## 🤖 Multilingual AI Chatbot

The app includes an intelligent, context-aware chatbot designed specifically for restricted-domain dental queries. 
- It parses backend analysis data dynamically.
- Fully supports translation toggles for **Hindi** and **Marathi** without breaking the UI.
- Politely rejects out-of-scope non-medical questions.

---

## ⚠️ Notes for Cloud Deployment

The backend utilizes heavy PyTorch ML models. Deploying the backend to free tiers on platforms like Render (which only provide 512MB RAM) will result in **Out Of Memory (OOM)** crashes. 
- **Recommendation:** Deploy the backend on Hugging Face Spaces (16GB RAM Free Tier) or a paid VPS (1GB+ RAM).
