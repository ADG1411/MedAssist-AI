from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime


class AppointmentBase(BaseModel):
    patient_id: str
    patient_name: str
    doctor_name: Optional[str] = "Dr. Smith"
    date: str  # YYYY-MM-DD
    time: str  # HH:MM AM/PM
    status: str = "Scheduled"  # Scheduled | Waiting | In Progress | Completed | Cancelled
    type: str = "Consultation"  # Consultation | Follow up | Checkup | Emergency
    notes: Optional[str] = None


class AppointmentCreate(AppointmentBase):
    pass


class AppointmentUpdate(BaseModel):
    patient_name: Optional[str] = None
    date: Optional[str] = None
    time: Optional[str] = None
    status: Optional[str] = None
    type: Optional[str] = None
    notes: Optional[str] = None


class AppointmentOut(AppointmentBase):
    id: str
    created_at: Optional[str] = None

    class Config:
        from_attributes = True


class AppointmentSummaryForAI(BaseModel):
    """Compact appointment for AI context injection."""
    id: str
    patient_name: str
    time: str
    status: str
    type: str
