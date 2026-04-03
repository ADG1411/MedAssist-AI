from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime


class Medication(BaseModel):
    name: str
    dosage: str
    frequency: str  # e.g. "1-0-1", "Twice daily"
    duration: str  # e.g. "7 days", "2 weeks"
    instructions: Optional[str] = None  # e.g. "After food"


class PrescriptionBase(BaseModel):
    patient_id: str
    patient_name: str
    diagnosis: str
    medications: List[Medication]
    notes: Optional[str] = None
    follow_up_date: Optional[str] = None


class PrescriptionCreate(PrescriptionBase):
    pass


class PrescriptionOut(PrescriptionBase):
    id: str
    doctor_name: str = "Dr. Smith"
    created_at: Optional[str] = None

    class Config:
        from_attributes = True
