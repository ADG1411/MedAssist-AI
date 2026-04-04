"""
Doctor Profile API — save/load/submit profile, upload documents, AI bio generation.
"""
from fastapi import APIRouter, UploadFile, File, Form
from typing import Dict, Any, List, Optional
from pathlib import Path
import json, uuid, datetime

from app.schemas.doctor_profile import (
    DoctorProfile, DoctorProfileUpdate, DoctorOverview,
    Workplace, Availability, Fees, Document, ProfileSettings
)
from app.services.ai_service import generate_text

router = APIRouter()

_DATA_FILE = Path(__file__).parent / "doctor_profile_data.json"


def _load() -> dict:
    if _DATA_FILE.exists():
        try:
            with open(_DATA_FILE, "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception:
            pass
    return {}


def _save(data: dict):
    with open(_DATA_FILE, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)


def _calc_completion(profile: dict) -> int:
    """Calculate profile completion percentage."""
    total, filled = 0, 0

    # Overview fields (40% weight)
    ov = profile.get("overview", {})
    overview_fields = ["full_name", "specialization", "degree", "years_of_experience", "bio", "city"]
    for f in overview_fields:
        total += 1
        if ov.get(f):
            filled += 1

    # Workplaces (15%)
    total += 1
    if profile.get("workplaces") and len(profile["workplaces"]) > 0:
        filled += 1

    # Availability (10%)
    total += 1
    avail = profile.get("availability", {})
    days = ["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"]
    if any(avail.get(d, {}).get("enabled") for d in days):
        filled += 1

    # Fees (15%)
    fees = profile.get("fees", {})
    total += 1
    if fees.get("online_fee", 0) > 0 or fees.get("offline_fee", 0) > 0:
        filled += 1

    # Documents (20%)
    total += 1
    docs = profile.get("documents", [])
    has_license = any(d.get("type") == "license" for d in docs)
    if has_license:
        filled += 1

    return int((filled / max(total, 1)) * 100)


def _verification_status(profile: dict) -> str:
    pct = _calc_completion(profile)
    if pct < 60:
        return "incomplete"
    docs = profile.get("documents", [])
    has_license = any(d.get("type") == "license" for d in docs)
    if not has_license:
        return "incomplete"
    # Check if admin has approved
    if profile.get("verification_status") == "approved":
        return "approved"
    return "pending"


# ── GET profile ──────────────────────────────────────────────────────────────

@router.get("/")
def get_profile() -> Dict[str, Any]:
    data = _load()
    if not data:
        # Return empty template
        default = DoctorProfile(
            id=str(uuid.uuid4()),
            created_at=datetime.datetime.now().isoformat(),
        )
        return default.model_dump()
    data["completion_percent"] = _calc_completion(data)
    data["verification_status"] = _verification_status(data)
    return data


# ── SAVE/UPDATE profile ─────────────────────────────────────────────────────

@router.put("/")
def update_profile(update: DoctorProfileUpdate) -> Dict[str, Any]:
    data = _load()
    if not data:
        data = DoctorProfile(
            id=str(uuid.uuid4()),
            created_at=datetime.datetime.now().isoformat(),
        ).model_dump()

    # Merge only provided fields
    if update.overview is not None:
        data["overview"] = update.overview.model_dump()
    if update.workplaces is not None:
        data["workplaces"] = [w.model_dump() for w in update.workplaces]
    if update.availability is not None:
        data["availability"] = update.availability.model_dump()
    if update.fees is not None:
        data["fees"] = update.fees.model_dump()
    if update.documents is not None:
        data["documents"] = [d.model_dump() for d in update.documents]
    if update.settings is not None:
        data["settings"] = update.settings.model_dump()

    data["updated_at"] = datetime.datetime.now().isoformat()
    data["completion_percent"] = _calc_completion(data)
    data["verification_status"] = _verification_status(data)

    _save(data)
    return data


# ── SUBMIT for verification ─────────────────────────────────────────────────

@router.post("/submit")
def submit_profile() -> Dict[str, Any]:
    data = _load()
    if not data:
        return {"error": "No profile data found. Please fill out your profile first."}

    pct = _calc_completion(data)
    if pct < 60:
        return {"error": f"Profile is only {pct}% complete. Please fill required fields.", "completion": pct}

    docs = data.get("documents", [])
    has_license = any(d.get("type") == "license" for d in docs)
    if not has_license:
        return {"error": "Medical license document is required for verification."}

    data["verification_status"] = "pending"
    data["updated_at"] = datetime.datetime.now().isoformat()
    _save(data)

    return {"status": "submitted", "message": "Profile submitted for admin verification.", "verification_status": "pending"}


# ── AI Bio Generation ────────────────────────────────────────────────────────

@router.post("/generate-bio")
async def generate_bio(payload: Dict[str, Any]) -> Dict[str, str]:
    name = payload.get("full_name", "Doctor")
    spec = payload.get("specialization", "General Medicine")
    degree = payload.get("degree", "MBBS")
    years = payload.get("years_of_experience", 0)
    city = payload.get("city", "")

    prompt = (
        f"Write a professional, warm 3-4 sentence bio for a doctor's profile page.\n"
        f"Doctor: {name}\nSpecialization: {spec}\nDegree: {degree}\n"
        f"Years of Experience: {years}\nCity: {city}\n\n"
        f"The bio should be in first person, professional yet approachable. "
        f"Highlight expertise and patient care philosophy. Keep it under 200 words."
    )

    bio = await generate_text(prompt, system_prompt="You are a medical copywriter. Write concise, professional doctor bios.")
    return {"bio": bio}
