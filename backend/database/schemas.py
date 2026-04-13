"""
database/schemas.py - Pydantic request/response schemas (DTOs)
Separate from ORM models — used for API validation and serialisation
"""

from datetime import datetime
from typing import List, Optional
from pydantic import BaseModel, EmailStr, Field


# ─── User Schemas ─────────────────────────────────────────────────────────────

class UserCreate(BaseModel):
    """Request body for POST /auth/register"""
    email: EmailStr
    password: str = Field(..., min_length=6, description="Minimum 6 characters")


class UserLogin(BaseModel):
    """Request body for POST /auth/login"""
    email: EmailStr
    password: str


class UserResponse(BaseModel):
    """Safe user representation (no password) returned in responses"""
    id: int
    email: str
    is_active: bool
    created_at: datetime

    class Config:
        from_attributes = True   # Pydantic v2 (replaces orm_mode)


# ─── Token Schema ─────────────────────────────────────────────────────────────

class Token(BaseModel):
    """Returned after successful login/register"""
    access_token: str
    token_type: str = "bearer"


class TokenData(BaseModel):
    """Data decoded from JWT token payload"""
    user_id: Optional[int] = None


# ─── Analysis / Report Schemas ────────────────────────────────────────────────

class ReportBase(BaseModel):
    """Shared fields present in both create and read schemas"""
    alignment_score:    Optional[float] = None
    symmetry_score:     Optional[float] = None
    cavity_result:      Optional[str]   = None
    cavity_confidence:  Optional[float] = None
    gum_disease_result: Optional[str]   = None
    gum_confidence:     Optional[float] = None
    staining_score:     Optional[float] = None
    staining_result:    Optional[str]   = None
    issues:             Optional[str]   = None
    suggestions:        Optional[str]   = None


class ReportCreate(ReportBase):
    """Internal schema used by report_service to persist results"""
    user_id:    int
    image_path: str
    mask_path:  Optional[str] = None


class ReportResponse(ReportBase):
    """Full report returned in API responses"""
    id:         int
    user_id:    int
    image_path: str
    mask_path:  Optional[str] = None
    created_at: datetime

    class Config:
        from_attributes = True


# ─── Analysis API Schemas ─────────────────────────────────────────────────────

class AnalysisResult(BaseModel):
    """
    Structured response returned from POST /analyze.
    Contains all pipeline outputs and a nested human-readable report.
    """
    alignment_tip: str
    symmetry_tip: str
    spacing_tip: str
    gum_visibility: str
    cavity_status: str
    gum_health: str
    staining_status: str
    
    image_url:          str
    mask_url:           Optional[str]    = None
    report:             dict             # Full human-readable nested report
    report_id:          int              # DB primary key for further queries


class ReportListResponse(BaseModel):
    """Paginated list of reports for GET /reports"""
    total:   int
    reports: List[ReportResponse]
