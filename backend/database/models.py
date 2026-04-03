"""
database/models.py - SQLAlchemy ORM models
Defines the database schema for the dental analysis system
"""

from datetime import datetime
from sqlalchemy import (
    Column, Integer, String, Float, Text,
    DateTime, ForeignKey, Boolean
)
from sqlalchemy.orm import relationship

from database.db import Base


class User(Base):
    """
    User table — stores registered users with hashed passwords.
    """
    __tablename__ = "users"

    id         = Column(Integer, primary_key=True, index=True)
    email      = Column(String(255), unique=True, index=True, nullable=False)
    password   = Column(String(255), nullable=False)          # bcrypt hash
    is_active  = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.utcnow)

    # One user → many analysis reports
    reports = relationship("AnalysisReport", back_populates="owner",
                           cascade="all, delete-orphan")

    def __repr__(self) -> str:
        return f"<User id={self.id} email={self.email}>"


class AnalysisReport(Base):
    """
    AnalysisReport table — stores results of the full AI pipeline
    for every uploaded intraoral image.
    """
    __tablename__ = "analysis_reports"

    id                 = Column(Integer, primary_key=True, index=True)
    user_id            = Column(Integer, ForeignKey("users.id"), nullable=False)

    # File paths (relative to project root)
    image_path         = Column(String(512), nullable=False)
    mask_path          = Column(String(512), nullable=True)   # segmentation mask

    # Numeric scores (0–100)
    alignment_score    = Column(Float, nullable=True)
    symmetry_score     = Column(Float, nullable=True)

    # Classification results
    cavity_result      = Column(String(50), nullable=True)    # "Detected" / "Not Detected"
    cavity_confidence  = Column(Float, nullable=True)         # 0.0 – 1.0
    gum_disease_result = Column(String,   nullable=True)
    gum_confidence     = Column(Float,    nullable=True)
    staining_score     = Column(Float,    nullable=True)
    staining_result    = Column(String,   nullable=True)
    issues             = Column(Text,     nullable=True) # JSON-string of detected issues

    # Free-text report fields stored as pipe-separated strings
    suggestions        = Column(Text, nullable=True)          # e.g. "Visit dentist|..."

    created_at         = Column(DateTime, default=datetime.utcnow)

    # Back-reference to the owner user
    owner = relationship("User", back_populates="reports")

    def __repr__(self) -> str:
        return f"<AnalysisReport id={self.id} user_id={self.user_id}>"
