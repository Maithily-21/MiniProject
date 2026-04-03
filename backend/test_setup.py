import sys
import os

# Add current directory to path
sys.path.append(os.getcwd())

try:
    from database.db import init_db
    from main import app
    print("Imports successful!")
    init_db()
    print("Database initialized successfully!")
except Exception as e:
    print(f"Error: {e}")
    sys.exit(1)
