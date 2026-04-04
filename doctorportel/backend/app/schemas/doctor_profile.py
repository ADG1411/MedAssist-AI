"""
Doctor Profile Schema — Complete onboarding data model.
"""
from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime


# ── Overview ─────────────────────────────────────────────────────────────────

class DoctorOverview(BaseModel):
    full_name: str = ""
    profile_photo: Optional[str] = None  # base64 or URL
    specialization: str = ""
    degree: str = ""
    years_of_experience: int = 0
    bio: str = ""
    languages: List[str] = []
    city: str = ""
    address: str = ""


# ── Workplace ────────────────────────────────────────────────────────────────

class Workplace(BaseModel):
    id: str = ""
    name: str = ""
    type: str = "hospital"  # hospital | private_clinic
    position: str = "consultant"  # consultant | surgeon | owner
    location: str = ""
    working_hours: str = ""
    is_primary: bool = False


# ── Availability ─────────────────────────────────────────────────────────────

class DaySchedule(BaseModel):
    enabled: bool = False
    start_time: str = "09:00"
    end_time: str = "17:00"
    break_start: str = "13:00"
    break_end: str = "14:00"


class Availability(BaseModel):
    slot_duration: int = 30  # 15 or 30 mins
    monday: DaySchedule = DaySchedule()
    tuesday: DaySchedule = DaySchedule()
    wednesday: DaySchedule = DaySchedule()
    thursday: DaySchedule = DaySchedule()
    friday: DaySchedule = DaySchedule()
    saturday: DaySchedule = DaySchedule()
    sunday: DaySchedule = DaySchedule()


# ── Fees ─────────────────────────────────────────────────────────────────────

class Fees(BaseModel):
    online_fee: float = 0
    offline_fee: float = 0
    emergency_fee: float = 0
    free_consultation: bool = False
    discount_percent: float = 0


# ── Documents ────────────────────────────────────────────────────────────────

class Document(BaseModel):
    id: str = ""
    name: str = ""
    type: str = ""  # license | degree | id_proof
    file_url: Optional[str] = None  # base64 data or URL
    file_name: str = ""
    uploaded_at: Optional[str] = None
    status: str = "pending"  # pending | verified | rejected


# ── Settings ─────────────────────────────────────────────────────────────────

class ProfileSettings(BaseModel):
    email_notifications: bool = True
    sms_notifications: bool = False
    push_notifications: bool = True
    language: str = "English"
    profile_visibility: str = "public"  # public | private
    show_phone: bool = False
    show_email: bool = True


# ── Full Profile ─────────────────────────────────────────────────────────────

class DoctorProfile(BaseModel):
    id: Optional[str] = None
    overview: DoctorOverview = DoctorOverview()
    workplaces: List[Workplace] = []
    availability: Availability = Availability()
    fees: Fees = Fees()
    documents: List[Document] = []
    settings: ProfileSettings = ProfileSettings()
    verification_status: str = "incomplete"  # incomplete | pending | approved
    completion_percent: int = 0
    created_at: Optional[str] = None
    updated_at: Optional[str] = None


class DoctorProfileUpdate(BaseModel):
    """Partial update — only send the tabs you modified."""
    overview: Optional[DoctorOverview] = None
    workplaces: Optional[List[Workplace]] = None
    availability: Optional[Availability] = None
    fees: Optional[Fees] = None
    documents: Optional[List[Document]] = None
    settings: Optional[ProfileSettings] = None
