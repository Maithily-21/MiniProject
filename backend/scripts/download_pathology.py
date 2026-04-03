"""
scripts/download_pathology.py
Downloads the "oral-diseases" dataset using kagglehub.
Identifies the local path where the files are stored.
"""

import kagglehub
import os
from pathlib import Path
from dotenv import load_dotenv

# Load credentials for kagglehub (it uses the same KAGGLE_USERNAME and KAGGLE_KEY)
load_dotenv()

# Download latest version
print("📥 Downloading salmansajid05/oral-diseases dataset via kagglehub...")
try:
    path = kagglehub.dataset_download("salmansajid05/oral-diseases")
    print(f"✅ Path to dataset files: {path}")
    
    # Symlink it into the project data/ directory for easier access
    dest = Path("data/oral-diseases")
    dest.parent.mkdir(parents=True, exist_ok=True)
    
    if os.path.exists(dest):
        if os.path.islink(dest):
            os.unlink(dest)
        else:
            import shutil
            shutil.rmtree(dest)
            
    # Try creating a symbolic link (requires admin/developer mode on Windows, 
    # but works in typical AI environments)
    try:
        os.symlink(path, dest, target_is_directory=True)
        print(f"🔗 Created symlink: {dest} -> {path}")
    except Exception as e:
        print(f"⚠️ Could not create symlink, copying instead: {e}")
        import shutil
        shutil.copytree(path, dest, dirs_exist_ok=True)
        print(f"📁 Data copied to: {dest}")

except Exception as e:
    print(f"❌ Error downloading via kagglehub: {e}")
    exit(1)
