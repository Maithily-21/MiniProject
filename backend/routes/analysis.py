"""
routes/analysis.py
Analysis routes:
  POST /analyze          — Upload image, run full AI pipeline, return report
  GET  /reports          — List all reports for the authenticated user
  GET  /reports/{id}     — Get a single report by ID
  DELETE /report/{id}    — Delete a report by ID
"""

import os
import uuid
import shutil
from typing import Optional

from fastapi import (
    APIRouter, Depends, File, HTTPException,
    Request, UploadFile, status
)
from sqlalchemy.orm import Session

from core.config import settings
from core.security import get_current_user_id
from database.db import get_db
from database.models import AnalysisReport
from services.staining_service import analyze_staining
from database.schemas import AnalysisResult, ReportListResponse, ReportResponse

# Services
from services.segmentation_service import run_segmentation 
from services.alignment_service    import compute_alignment_score
from services.symmetry_service     import compute_symmetry_score
from services.spacing_service      import analyze_spacing
from services.gum_visibility_service import analyze_gum_visibility
from services.cavity_service       import detect_cavity
from services.gum_service          import detect_gum_disease
from services.report_service       import create_report, build_api_payload

router = APIRouter(tags=["Analysis"])

# Allowed image MIME types
ALLOWED_CONTENT_TYPES = {"image/jpeg", "image/png", "image/webp", "image/bmp"}


# ─── Helpers ──────────────────────────────────────────────────────────────────

def _save_upload(upload: UploadFile) -> str:
    """Save an uploaded file to the uploads directory and return its path."""
    ext      = os.path.splitext(upload.filename or "image.jpg")[1] or ".jpg"
    filename = f"{uuid.uuid4().hex}{ext}"
    dest     = os.path.join(settings.UPLOAD_DIR, filename)
    os.makedirs(settings.UPLOAD_DIR, exist_ok=True)

    with open(dest, "wb") as f:
        shutil.copyfileobj(upload.file, f)

    return dest


def _get_base_url(request: Request) -> str:
    """Derive server base URL from the incoming request."""
    return str(request.base_url).rstrip("/")


# ─── POST /analyze ────────────────────────────────────────────────────────────

@router.post(
    "/analyze",
    response_model=AnalysisResult,
    status_code=status.HTTP_200_OK,
    summary="Upload an intraoral image and run the full AI pipeline",
)
async def analyze_image(
    request: Request,
    file:    UploadFile        = File(..., description="Intraoral image (JPEG/PNG)"),
    user_id: Optional[int]     = Depends(get_current_user_id),
    db:      Session           = Depends(get_db),
):
    """
    Full AI pipeline:
    1. Validate & save uploaded image
    2. Teeth Segmentation  (U-Net)
    3. Alignment Score     (centroid line-fitting)
    4. Symmetry Score      (left-right IoU)
    5. Cavity Detection    (CavityCNN)
    6. Gum Disease         (GumDiseaseCNN)
    7. Staining Analysis   (Color thresholding)
    8. Persist report to DB
    9. Return structured JSON response
    """
    # Use default user ID if not authenticated (for testing)
    if user_id is None:
        user_id = 1
    # ── Validation ────────────────────────────────────────────────────────────
    if file.content_type not in ALLOWED_CONTENT_TYPES:
        raise HTTPException(
            status_code=status.HTTP_415_UNSUPPORTED_MEDIA_TYPE,
            detail=f"Unsupported file type '{file.content_type}'. "
                   f"Allowed: JPEG, PNG, WebP, BMP",
        )

    # Check file size (read the raw bytes, then wrap again)
    raw_bytes = await file.read()
    size_mb   = len(raw_bytes) / (1024 * 1024)
    if size_mb > settings.MAX_IMAGE_SIZE_MB:
        raise HTTPException(
            status_code=status.HTTP_413_REQUEST_ENTITY_TOO_LARGE,
            detail=f"File too large ({size_mb:.1f} MB). "
                   f"Max allowed: {settings.MAX_IMAGE_SIZE_MB} MB",
        )
    # Rewind so copyfileobj works correctly
    import io
    file.file = io.BytesIO(raw_bytes)

    # ── Save upload ───────────────────────────────────────────────────────────
    try:
        image_path = _save_upload(file)
    except Exception as exc:
        raise HTTPException(status_code=500, detail=f"Failed to save image: {exc}")

    # ── AI Pipeline ───────────────────────────────────────────────────────────
    try:
        # Step 1 — Segmentation
        seg_result = run_segmentation(image_path)
        mask_path  = seg_result["mask_path"]
        mask_array = seg_result["mask_array"]
        img_rgb    = seg_result["img_rgb"]
        mask_uint8 = seg_result["mask_uint8"]

        # Step 2 — Alignment
        alignment_data = compute_alignment_score(mask_array)

        # Step 3 — Symmetry
        symmetry_data = compute_symmetry_score(mask_array)

        # Step 3b - Spacing
        spacing_tip = analyze_spacing(mask_array)

        # Step 3c - Gum Visibility
        gum_visibility_tip = analyze_gum_visibility(mask_array)

        # Step 4 — Cavity
        cavity_data = detect_cavity(image_path, mask_array)

        # Step 5 — Gum Disease
        gum_data = detect_gum_disease(image_path)

        # Step 6 — Staining Analysis
        stain_score, stain_res = analyze_staining(img_rgb, mask_uint8)

    except Exception as exc:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"AI pipeline error: {exc}",
        )

    # ── Persist & Respond ─────────────────────────────────────────────────────
    try:
        report = create_report(
            db             = db,
            user_id        = user_id,
            image_path     = image_path,
            mask_path      = mask_path,
            alignment_data = alignment_data,
            symmetry_data  = symmetry_data,
            cavity_data    = cavity_data,
            gum_data       = gum_data,
            stain_score    = stain_score,
            stain_res      = stain_res
        )
    except Exception as exc:
        raise HTTPException(status_code=500, detail=f"Failed to save report: {exc}")

    base_url = _get_base_url(request)
    return build_api_payload(
        report         = report,
        alignment_data = alignment_data,
        symmetry_data  = symmetry_data,
        cavity_data    = cavity_data,
        gum_data       = gum_data,
        stain_score    = stain_score,
        stain_res      = stain_res,
        spacing_tip    = spacing_tip,
        gum_visibility = gum_visibility_tip,
        base_url       = base_url,
    )


# ─── GET /reports ─────────────────────────────────────────────────────────────

@router.get(
    "/reports",
    response_model=ReportListResponse,
    summary="List all analysis reports for the current user",
)
def list_reports(
    skip:    int     = 0,
    limit:   int     = 20,
    user_id: int     = Depends(get_current_user_id),
    db:      Session = Depends(get_db),
):
    """
    Returns a paginated list of AnalysisReport records belonging to the
    authenticated user, ordered by most-recent first.
    """
    query   = db.query(AnalysisReport).filter(AnalysisReport.user_id == user_id)
    total   = query.count()
    reports = (
        query.order_by(AnalysisReport.created_at.desc())
             .offset(skip)
             .limit(limit)
             .all()
    )
    return ReportListResponse(total=total, reports=reports)


# ─── GET /reports/{report_id} ─────────────────────────────────────────────────

@router.get(
    "/reports/{report_id}",
    response_model=ReportResponse,
    summary="Retrieve a single analysis report by ID",
)
def get_report(
    report_id: int,
    user_id:   int     = Depends(get_current_user_id),
    db:        Session = Depends(get_db),
):
    """Returns a single report, enforcing ownership (users can only see their own)."""
    report = (
        db.query(AnalysisReport)
          .filter(AnalysisReport.id == report_id,
                  AnalysisReport.user_id == user_id)
          .first()
    )
    if not report:
        raise HTTPException(status_code=404, detail="Report not found")
    return report


# ─── DELETE /report/{report_id} ───────────────────────────────────────────────

@router.delete(
    "/report/{report_id}",
    status_code=status.HTTP_200_OK,
    summary="Delete a report and its associated files",
)
def delete_report(
    report_id: int,
    user_id:   int     = Depends(get_current_user_id),
    db:        Session = Depends(get_db),
):
    """
    Permanently delete a report (ownership enforced).
    Also removes the stored image and mask files from disk.
    """
    report = (
        db.query(AnalysisReport)
          .filter(AnalysisReport.id == report_id,
                  AnalysisReport.user_id == user_id)
          .first()
    )
    if not report:
        raise HTTPException(status_code=404, detail="Report not found")

    # Clean up stored files
    for path in [report.image_path, report.mask_path]:
        if path and os.path.exists(path):
            try:
                os.remove(path)
            except OSError:
                pass  # Non-fatal — continue with DB deletion

    db.delete(report)
    db.commit()

    return {"detail": f"Report {report_id} deleted successfully"}
