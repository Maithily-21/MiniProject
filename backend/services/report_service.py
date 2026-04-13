"""
services/report_service.py
Aggregates all pipeline results into a structured report,
persists it to the database, and returns the final API payload.
"""

from typing import Optional
from sqlalchemy.orm import Session

from database.models import AnalysisReport
from database.schemas import ReportCreate


# ─── Issue / Suggestion Logic ─────────────────────────────────────────────────

def _build_issues_and_suggestions(
    alignment_score: float,
    symmetry_score:  float,
    cavity_label:    str,
    gum_label:       str,
    stain_score:     float = 0.0,
) -> tuple[list[str], list[str]]:
    """
    Derive human-readable dental issues and personalised suggestions
    from the raw pipeline scores/labels.
    """
    issues:      list[str] = []
    suggestions: list[str] = []

    # ── Alignment ──────────────────────────────────
    if alignment_score < 50:
        issues.append("Significant teeth misalignment detected")
        suggestions.append("Consult an orthodontist for braces or clear aligner therapy")
    elif alignment_score < 75:
        issues.append("Mild teeth misalignment observed")
        suggestions.append("Regular dental monitoring recommended; discuss orthodontic options")

    # ── Symmetry ───────────────────────────────────
    if symmetry_score < 40:
        issues.append("Noticeable left-right dental asymmetry")
        suggestions.append("Aesthetic evaluation by a cosmetic dentist is advised")
    elif symmetry_score < 65:
        issues.append("Slight dental asymmetry present")
        suggestions.append("Monitor symmetry at next routine check-up")

    # ── Cavity ─────────────────────────────────────
    if cavity_label == "cavity":
        issues.append("Cavity (dental caries) detected")
        suggestions.append("Schedule a filling appointment as soon as possible")
        suggestions.append("Reduce sugar intake and increase fluoride toothpaste usage")

    # ── Gum Disease ────────────────────────────────
    if gum_label == "mild":
        issues.append("Mild gum disease (gingivitis) signs present")
        suggestions.append("Improve brushing and flossing technique; consider antiseptic mouthwash")
    elif gum_label == "severe":
        issues.append("Severe gum disease (periodontitis) signs detected")
        suggestions.append("Urgent referral to a periodontist strongly recommended")
        suggestions.append("Professional deep cleaning (scaling and root planing) may be required")

    # ── Staining ───────────────────────────────────
    if stain_score > 10:
        issues.append(f"Significant surface staining ({stain_score}% coverage) detected")
        suggestions.append("Professional Scaling & Polishing or Whitening treatment recommended")

    # ── Positive reinforcement ─────────────────────
    if not issues:
        issues.append("No significant dental issues detected")
        suggestions.append("Maintain current oral hygiene routine")
        suggestions.append("Schedule a routine check-up every 6 months")

    return issues, suggestions


# ─── Public API ───────────────────────────────────────────────────────────────

def create_report(
    db:             Session,
    user_id:        int,
    image_path:     str,
    mask_path:      Optional[str],
    alignment_data: dict,
    symmetry_data:  dict,
    cavity_data:    dict,
    gum_data:       dict,
    stain_score:    float,
    stain_res:      str,
) -> AnalysisReport:
    """
    Build, persist, and return an AnalysisReport ORM object.

    Args:
        db:             SQLAlchemy session
        user_id:        Authenticated user's ID
        image_path:     Path to the uploaded image
        mask_path:      Path to the generated segmentation mask
        alignment_data: Output dict from alignment_service
        symmetry_data:  Output dict from symmetry_service
        cavity_data:    Output dict from cavity_service
        gum_data:       Output dict from gum_service

    Returns:
        Persisted AnalysisReport instance
    """
    alignment_score = alignment_data["alignment_score"]
    symmetry_score  = symmetry_data["symmetry_score"]
    cavity_label    = cavity_data["label"]
    gum_label       = gum_data["label"]

    issues, suggestions = _build_issues_and_suggestions(
        alignment_score, symmetry_score, cavity_label, gum_label, stain_score
    )

    report = AnalysisReport(
        user_id            = user_id,
        image_path         = image_path,
        mask_path          = mask_path,
        alignment_score    = alignment_score,
        symmetry_score     = symmetry_score,
        cavity_result      = cavity_data["display"],
        cavity_confidence  = cavity_data["confidence"],
        gum_disease_result = gum_label.capitalize(),
        gum_confidence     = gum_data["confidence"],
        staining_score     = stain_score,
        staining_result    = stain_res,
        issues             = "|".join(issues),
        suggestions        = "|".join(suggestions),
    )

    db.add(report)
    db.commit()
    db.refresh(report)
    return report


def build_api_payload(
    report:         AnalysisReport,
    alignment_data: dict,
    symmetry_data:  dict,
    cavity_data:    dict,
    gum_data:       dict,
    stain_score:    float,
    stain_res:      str,
    spacing_tip:    str,
    gum_visibility: str,
    base_url:       str,
) -> dict:
    """
    Construct the full JSON response structure returned to the API consumer.

    Args:
        report:      Persisted AnalysisReport ORM object
        *_data:      Raw service output dicts
        base_url:    Server base URL for constructing file download links

    Returns:
        Serialisable dict matching the API contract
    """
    issues      = report.issues.split("|")      if report.issues      else []
    suggestions = report.suggestions.split("|") if report.suggestions else []

    nested_report = {
        "alignment_score":    report.alignment_score,
        "symmetry_score":     report.symmetry_score,
        "cavity":             report.cavity_result,
        "cavity_confidence":  report.cavity_confidence,
        "gum_disease":        report.gum_disease_result,
        "gum_confidence":     report.gum_confidence,
        "staining_score":     report.staining_score,
        "staining_result":    report.staining_result,
        "num_teeth_detected": alignment_data.get("num_teeth", 0),
        "issues":             issues,
        "suggestions":        suggestions,
    }

    def _url(path: Optional[str]) -> Optional[str]:
        """Convert a local file path to a URL-accessible endpoint."""
        if not path:
            return None
        # Replace backslashes for cross-platform compatibility
        clean = path.replace("\\", "/")
        return f"{base_url}/files/{clean}"

    if report.alignment_score < 30:
        alignment_tip = "Severe alignment irregularity detected. Orthodontic consultation is recommended."
    elif report.alignment_score <= 70:
        alignment_tip = "Your current score suggests potential crowding or misalignment. Consider an orthodontic consultation or clear aligners."
    else:
        alignment_tip = "Teeth alignment appears balanced."

    if report.symmetry_score < 0.3:
        symmetry_tip = "A lower symmetry score often indicates slight shifting. An occlusal check is recommended to ensure a balanced bite."
    else:
        symmetry_tip = "Smile symmetry appears balanced and aesthetically consistent."

    # Top-level requested dictionary features
    response_dict = {
        "alignment_tip": alignment_tip,
        "symmetry_tip": symmetry_tip,
        "spacing_tip": spacing_tip,
        "gum_visibility": gum_visibility,
        "cavity_status": report.cavity_result,
        "gum_health": report.gum_disease_result,
        "staining_status": report.staining_result,
        
        # Internal / required by some API handlers
        "report_id":          report.id,
        "image_url":          _url(report.image_path),
        "mask_url":           _url(report.mask_path),
        "report":             nested_report,
    }
    
    return response_dict
