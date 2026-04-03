from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime


# ── QR ──────────────────────────────────────────────────────────────────────

class QRScanRequest(BaseModel):
    token: str

class QRPreviewResponse(BaseModel):
    patient_id: int
    name: str
    age: int
    phone_masked: str
    blood_group: str

class QRAccessRequest(BaseModel):
    token: str
    emergency: bool = False


# ── Patient ──────────────────────────────────────────────────────────────────

class PatientBase(BaseModel):
    name: str
    age: int
    gender: str
    phone: str
    blood_group: str
    allergies: Optional[str] = None
    email: Optional[str] = None
    address: Optional[str] = None

class PatientCreate(PatientBase):
    pass

class PatientOut(PatientBase):
    id: int
    created_at: datetime
    class Config:
        from_attributes = True


# ── Medical Records ──────────────────────────────────────────────────────────

class MedicalRecordOut(BaseModel):
    id: int
    diagnosis: str
    prescription: Optional[str] = None
    report_url: Optional[str] = None
    doctor_name: Optional[str] = None
    notes: Optional[str] = None
    created_at: datetime
    class Config:
        from_attributes = True


# ── Family ───────────────────────────────────────────────────────────────────

class FamilyMemberOut(BaseModel):
    id: int
    name: str
    relation: str
    phone: str
    is_primary: bool
    class Config:
        from_attributes = True


# ── Access Log ───────────────────────────────────────────────────────────────

class AccessLogOut(BaseModel):
    id: int
    doctor_id: int
    doctor_name: Optional[str]
    patient_id: int
    access_type: str
    timestamp: datetime
    class Config:
        from_attributes = True

class AccessLogCreate(BaseModel):
    patient_id: int
    access_type: str = "standard"


# ── Full Patient Record ───────────────────────────────────────────────────────

class FullPatientRecord(BaseModel):
    patient: PatientOut
    records: List[MedicalRecordOut]
    family_members: List[FamilyMemberOut]
    ai_summary: List[str]
    access_logged: bool = True


# ── AI Summary ───────────────────────────────────────────────────────────────

class AISummaryRequest(BaseModel):
    patient_id: int

class AISummaryResponse(BaseModel):
    patient_id: int
    insights: List[str]
    risk_level: str   # low | moderate | high
    generated_at: datetime


# ── QR Token Generation ──────────────────────────────────────────────────────

class GenerateQRRequest(BaseModel):
    patient_id: int
    expires_minutes: int = 10

class GenerateQRResponse(BaseModel):
    token: str
    expires_at: datetime
    qr_data: str
