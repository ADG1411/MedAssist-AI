"""
MedCard QR Scan Patient Access API
Routes: /qr/scan, /qr/access, /qr/generate, /patient/{id}/records,
        /ai/summary, /access/log
"""

from fastapi import APIRouter, HTTPException, Header, Depends
from typing import Optional, List
from datetime import datetime, timezone, timedelta
import random

from app.schemas.medcard import (
    QRScanRequest, QRPreviewResponse,
    QRAccessRequest, FullPatientRecord,
    GenerateQRRequest, GenerateQRResponse,
    AISummaryRequest, AISummaryResponse,
    AccessLogCreate, AccessLogOut,
    MedicalRecordOut, FamilyMemberOut, PatientOut,
)
from app.utils.qr_token import create_qr_token, decrypt_qr_token, mask_phone

router = APIRouter()


# ── Mock in-memory data (replace with real DB queries via SQLAlchemy) ─────────

MOCK_PATIENTS = {
    1: {
        "id": 1, "name": "Rahul Sharma", "age": 34, "gender": "Male",
        "phone": "+91 98765 43210", "blood_group": "B+",
        "allergies": "Penicillin, Aspirin",
        "email": "rahul.sharma@email.com",
        "address": "12 MG Road, Bengaluru, Karnataka",
        "created_at": datetime(2022, 3, 15, tzinfo=timezone.utc),
    },
    2: {
        "id": 2, "name": "Priya Verma", "age": 28, "gender": "Female",
        "phone": "+91 87654 32109", "blood_group": "A+",
        "allergies": "Sulfa drugs",
        "email": "priya.verma@email.com",
        "address": "45 Park Street, Mumbai, Maharashtra",
        "created_at": datetime(2023, 1, 10, tzinfo=timezone.utc),
    },
    3: {
        "id": 3, "name": "Arjun Mehta", "age": 52, "gender": "Male",
        "phone": "+91 77543 21098", "blood_group": "O+",
        "allergies": "Heparin",
        "email": "arjun.mehta@email.com",
        "address": "8 Civil Lines, Delhi",
        "created_at": datetime(2021, 8, 20, tzinfo=timezone.utc),
    },
}

MOCK_RECORDS = {
    1: [
        {"id": 101, "patient_id": 1, "diagnosis": "Acute Gastritis", "prescription": "Pantoprazole 40mg OD, Domperidone 10mg TID", "report_url": None, "doctor_name": "Dr. Smith", "notes": "Avoid spicy food", "created_at": datetime(2024, 11, 5, tzinfo=timezone.utc)},
        {"id": 102, "patient_id": 1, "diagnosis": "Hypertension Stage 1", "prescription": "Amlodipine 5mg OD", "report_url": None, "doctor_name": "Dr. Patel", "notes": "Monitor BP daily", "created_at": datetime(2024, 8, 15, tzinfo=timezone.utc)},
        {"id": 103, "patient_id": 1, "diagnosis": "GERD", "prescription": "Omeprazole 20mg BD, Antacid SOS", "report_url": None, "doctor_name": "Dr. Smith", "notes": "Lifestyle modification advised", "created_at": datetime(2024, 3, 22, tzinfo=timezone.utc)},
    ],
    2: [
        {"id": 201, "patient_id": 2, "diagnosis": "Viral Upper Respiratory Infection", "prescription": "Paracetamol 500mg TID, Cetirizine 10mg OD", "report_url": None, "doctor_name": "Dr. Rao", "notes": "Rest and hydration", "created_at": datetime(2025, 1, 12, tzinfo=timezone.utc)},
        {"id": 202, "patient_id": 2, "diagnosis": "Iron Deficiency Anaemia", "prescription": "Ferrous Sulfate 200mg BD", "report_url": None, "doctor_name": "Dr. Smith", "notes": "CBC after 4 weeks", "created_at": datetime(2024, 9, 8, tzinfo=timezone.utc)},
    ],
    3: [
        {"id": 301, "patient_id": 3, "diagnosis": "Coronary Artery Disease", "prescription": "Aspirin 75mg OD, Atorvastatin 40mg", "report_url": None, "doctor_name": "Dr. Kapoor", "notes": "Cardiac review in 3 months", "created_at": datetime(2025, 2, 1, tzinfo=timezone.utc)},
        {"id": 302, "patient_id": 3, "diagnosis": "Hypertension Stage 2", "prescription": "Amlodipine 10mg OD, Losartan 50mg OD", "report_url": None, "doctor_name": "Dr. Smith", "notes": "Salt restriction", "created_at": datetime(2024, 10, 14, tzinfo=timezone.utc)},
        {"id": 303, "patient_id": 3, "diagnosis": "Type 2 Diabetes Mellitus", "prescription": "Metformin 500mg BD, Glimepiride 1mg OD", "report_url": None, "doctor_name": "Dr. Patel", "notes": "HbA1c target <7%", "created_at": datetime(2024, 6, 30, tzinfo=timezone.utc)},
    ],
}

MOCK_FAMILY = {
    1: [
        {"id": 11, "patient_id": 1, "name": "Sunita Sharma", "relation": "Wife",   "phone": "+91 90123 45678", "is_primary": True},
        {"id": 12, "patient_id": 1, "name": "Ravi Sharma",   "relation": "Father", "phone": "+91 81234 56789", "is_primary": False},
    ],
    2: [
        {"id": 21, "patient_id": 2, "name": "Vikram Verma",  "relation": "Husband","phone": "+91 70987 65432", "is_primary": True},
    ],
    3: [
        {"id": 31, "patient_id": 3, "name": "Kavita Mehta",  "relation": "Wife",   "phone": "+91 87654 32109", "is_primary": True},
        {"id": 32, "patient_id": 3, "name": "Rohan Mehta",   "relation": "Son",    "phone": "+91 76543 21098", "is_primary": False},
    ],
}

MOCK_LOGS: List[dict] = []


# ── AI Summary Logic ───────────────────────────────────────────────────────────

def _generate_ai_summary(patient_id: int) -> tuple[list[str], str]:
    records = MOCK_RECORDS.get(patient_id, [])
    diagnoses = [r["diagnosis"].lower() for r in records]

    insights: list[str] = []
    risk = "low"

    # Repeated gastric issues
    gastric = sum(1 for d in diagnoses if any(k in d for k in ["gastritis", "gerd", "gastro", "stomach"]))
    if gastric >= 2:
        insights.append(f"Frequent stomach/GI issues detected across {gastric} visits — consider GI specialist referral.")

    # BP / hypertension trend
    bp_count = sum(1 for d in diagnoses if "hypertension" in d or "bp" in d)
    if bp_count >= 2:
        insights.append("BP is a recurring concern — escalating medication doses noted.")
        risk = "moderate"

    # Cardiac risk
    if any("coronary" in d or "cardiac" in d for d in diagnoses):
        insights.append("Cardiac condition on record — high priority monitoring required.")
        risk = "high"

    # Diabetes
    if any("diabetes" in d for d in diagnoses):
        insights.append("Diabetic patient — monitor blood sugar, HbA1c, and kidney function regularly.")
        if risk != "high":
            risk = "moderate"

    # Allergies warning
    patient = MOCK_PATIENTS.get(patient_id, {})
    if patient.get("allergies"):
        insights.append(f"Known allergies: {patient['allergies']} — verify before prescribing.")

    if not insights:
        insights.append("No significant recurring conditions detected in recent records.")

    return insights, risk


# ── Endpoints ──────────────────────────────────────────────────────────────────


@router.post("/qr/generate", response_model=GenerateQRResponse, tags=["medcard"])
def generate_qr_token(req: GenerateQRRequest):
    """Generate an encrypted QR token for a patient (called by admin/reception)."""
    if req.patient_id not in MOCK_PATIENTS:
        raise HTTPException(status_code=404, detail="Patient not found")

    token, expires_at = create_qr_token(req.patient_id, req.expires_minutes)
    return GenerateQRResponse(
        token=token,
        expires_at=expires_at,
        qr_data=f"MEDCARD::{token}",
    )


@router.post("/qr/scan", response_model=QRPreviewResponse, tags=["medcard"])
def scan_qr(req: QRScanRequest):
    """
    Step 1 — Scan QR code, return masked patient preview (no auth required).
    """
    try:
        payload = decrypt_qr_token(req.token)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

    patient_id = payload["patient_id"]
    patient = MOCK_PATIENTS.get(patient_id)
    if not patient:
        raise HTTPException(status_code=404, detail="Patient not found")

    return QRPreviewResponse(
        patient_id=patient_id,
        name=patient["name"],
        age=patient["age"],
        phone_masked=mask_phone(patient["phone"]),
        blood_group=patient["blood_group"],
    )


@router.post("/qr/access", response_model=FullPatientRecord, tags=["medcard"])
def access_full_record(
    req: QRAccessRequest,
    authorization: Optional[str] = Header(default=None),
):
    """
    Step 2 — Validate doctor JWT + QR token, return full patient record.
    Role check: Bearer token must be present (doctor auth).
    """
    # ── Auth check (JWT presence guard) ──
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Doctor authentication required")

    # In production: decode + verify the JWT, extract doctor_id + role.
    # Here we accept any non-empty Bearer token as a mock.
    doctor_token = authorization.split(" ", 1)[1]
    if not doctor_token:
        raise HTTPException(status_code=401, detail="Invalid doctor token")

    # ── QR token validation ──
    try:
        payload = decrypt_qr_token(req.token)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

    patient_id = payload["patient_id"]
    patient = MOCK_PATIENTS.get(patient_id)
    if not patient:
        raise HTTPException(status_code=404, detail="Patient not found")

    # ── Log access ──
    MOCK_LOGS.append({
        "id": len(MOCK_LOGS) + 1,
        "doctor_id": 1,
        "doctor_name": "Dr. Smith",
        "patient_id": patient_id,
        "access_type": "emergency" if req.emergency else "standard",
        "timestamp": datetime.now(timezone.utc),
    })

    # ── Build response ──
    raw_records  = MOCK_RECORDS.get(patient_id, [])
    raw_family   = MOCK_FAMILY.get(patient_id, [])
    ai_insights, _ = _generate_ai_summary(patient_id)

    return FullPatientRecord(
        patient=PatientOut(**patient),
        records=[MedicalRecordOut(**r) for r in raw_records],
        family_members=[FamilyMemberOut(**f) for f in raw_family],
        ai_summary=ai_insights,
        access_logged=True,
    )


@router.get("/patient/{patient_id}/records", response_model=list[MedicalRecordOut], tags=["medcard"])
def get_patient_records(
    patient_id: int,
    authorization: Optional[str] = Header(default=None),
):
    """Get medical records for a patient (requires doctor auth)."""
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Doctor authentication required")

    records = MOCK_RECORDS.get(patient_id)
    if records is None:
        raise HTTPException(status_code=404, detail="Patient not found")
    return [MedicalRecordOut(**r) for r in records]


@router.post("/ai/summary", response_model=AISummaryResponse, tags=["medcard"])
def get_ai_summary(
    req: AISummaryRequest,
    authorization: Optional[str] = Header(default=None),
):
    """Generate AI summary from patient's medical history (requires doctor auth)."""
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Doctor authentication required")

    if req.patient_id not in MOCK_PATIENTS:
        raise HTTPException(status_code=404, detail="Patient not found")

    insights, risk = _generate_ai_summary(req.patient_id)
    return AISummaryResponse(
        patient_id=req.patient_id,
        insights=insights,
        risk_level=risk,
        generated_at=datetime.now(timezone.utc),
    )


@router.post("/access/log", response_model=AccessLogOut, tags=["medcard"])
def log_access(
    req: AccessLogCreate,
    authorization: Optional[str] = Header(default=None),
):
    """Manually log an access event."""
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Doctor authentication required")

    entry = {
        "id": len(MOCK_LOGS) + 1,
        "doctor_id": 1,
        "doctor_name": "Dr. Smith",
        "patient_id": req.patient_id,
        "access_type": req.access_type,
        "timestamp": datetime.now(timezone.utc),
    }
    MOCK_LOGS.append(entry)
    return AccessLogOut(**entry)


@router.get("/access/logs", response_model=list[AccessLogOut], tags=["medcard"])
def get_access_logs(authorization: Optional[str] = Header(default=None)):
    """Retrieve all access logs (admin/doctor use)."""
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Doctor authentication required")
    return [AccessLogOut(**l) for l in MOCK_LOGS]


@router.get("/demo-token/{patient_id}", tags=["medcard"])
def get_demo_token(patient_id: int):
    """
    DEMO ONLY — generates a fresh QR token for testing the scan flow.
    Remove this endpoint in production.
    """
    if patient_id not in MOCK_PATIENTS:
        raise HTTPException(status_code=404, detail="Patient not found")
    token, expires_at = create_qr_token(patient_id, expires_minutes=30)
    return {"token": token, "expires_at": expires_at.isoformat(), "patient_id": patient_id}
