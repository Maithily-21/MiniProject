"""
core/config.py - Application configuration using Pydantic Settings
Loads settings from environment variables or .env file
"""

import os
from pydantic_settings import BaseSettings
from functools import lru_cache


class Settings(BaseSettings):
    """
    Application settings loaded from environment variables.
    Provides defaults for development, override via .env file in production.
    """
    # App metadata
    APP_NAME: str = "AI Dental Analysis System"
    APP_VERSION: str = "1.0.0"
    DEBUG: bool = True

    # JWT Security
    SECRET_KEY: str = "your-super-secret-jwt-key-change-in-production-min-32-chars"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30

    # Database
    DATABASE_URL: str = "sqlite:///./dental_analysis.db"

    # File storage directories
    UPLOAD_DIR: str = "uploads"
    OUTPUT_DIR: str = "outputs"
    MAX_IMAGE_SIZE_MB: int = 10

    # ML Model inference device: "cpu" or "cuda"
    MODEL_DEVICE: str = "cpu"

    class Config:
        env_file = ".env"
        case_sensitive = True
        extra = "ignore"


@lru_cache()
def get_settings() -> Settings:
    """
    Returns cached settings instance.
    Decorated with lru_cache so settings are only loaded once per process.
    """
    return Settings()


# Convenience accessor used across the codebase
settings = get_settings()

# Ensure storage directories exist at startup
os.makedirs(settings.UPLOAD_DIR, exist_ok=True)
os.makedirs(settings.OUTPUT_DIR, exist_ok=True)
