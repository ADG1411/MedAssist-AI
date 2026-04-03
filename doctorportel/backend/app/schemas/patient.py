from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime


class PatientBase(BaseModel):
    first_name: str
    last_name: str
    email: str
    phone_number: str
    age: int
    gender: str
    status: Optional[str] = "Active"
    last_diagnosis: Optional[str] = ""
    last_visit: Optional[str] = ""
    total_fees: Optional[float] = 0
    pending_amount: Optional[float] = 0
    is_favorite: Optional[bool] = False
    risk_score: Optional[int] = 20
    tags: Optional[List[str]] = []
    next_follow_up: Optional[str] = None


class PatientCreate(PatientBase):
    pass


class PatientUpdate(BaseModel):
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    email: Optional[str] = None
    phone_number: Optional[str] = None
    age: Optional[int] = None
    gender: Optional[str] = None
    status: Optional[str] = None
    last_diagnosis: Optional[str] = None
    last_visit: Optional[str] = None
    total_fees: Optional[float] = None
    pending_amount: Optional[float] = None
    is_favorite: Optional[bool] = None
    risk_score: Optional[int] = None
    tags: Optional[List[str]] = None
    next_follow_up: Optional[str] = None


class PatientOut(PatientBase):
    id: str
    avatar: Optional[str] = None
    is_active: bool = True

    class Config:
        from_attributes = True


class PatientSummaryForAI(BaseModel):
    """Compact patient representation for feeding to the AI context."""
    id: str
    name: str
    age: int
    gender: str
    status: str
    diagnosis: str
    risk_score: int
    tags: List[str]
    pending_amount: float
    next_follow_up: Optional[str] = None
