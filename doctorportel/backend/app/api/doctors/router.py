from fastapi import APIRouter, Body
from typing import List, Dict

router = APIRouter()

MOCK_DOCTOR_PROFILE = {
    "id": 101,
    "user_id": "dr_smith_001",
    "full_name": "Dr. Sarah Smith",
    "email": "dr.smith@example.com",
    "phone_number": "+1-555-0101",
    "specialization": "Senior Cardiologist",
    "experience_years": 15,
    "rating": 4.9,
    "languages": "English, Spanish, Hindi",
    "bio": "Leading Cardiologist with over 15 years of experience in performing complex cardiac surgeries. Dedicated to patient-centric care.",
    "location": "New York, USA",
    "avatar": "https://images.unsplash.com/photo-1559839734-2b71ea197ec2?auto=format&fit=crop&q=80&w=256&h=256",
    "stats": {
        "total_patients": "12.4k",
        "appointments": 842,
        "success_rate": "98%",
        "earnings_this_month": "$4.2k"
    },
    "role": "doctor",
    "is_active": True
}

MOCK_WORKPLACES = [
  {
    "id": "1",
    "name": "New York Medical Central",
    "type": "Hospital",
    "role": "Senior Consultant",
    "location": "New York, NY",
    "isPrimary": True,
    "verified": True
  },
  {
    "id": "2",
    "name": "Smith Cardiology Clinic",
    "type": "Private Clinic",
    "role": "Owner / Lead Specialist",
    "location": "Brooklyn, NY",
    "isPrimary": False,
    "verified": False
  }
]


@router.get("/profile", response_model=Dict)
def get_doctor_profile():
    """Get the current doctor's detailed profile (mocked)"""
    return MOCK_DOCTOR_PROFILE

@router.put("/profile", response_model=Dict)
def update_doctor_profile(updates: Dict = Body(...)):
    """Update the current doctor's detailed profile (mocked)"""
    MOCK_DOCTOR_PROFILE.update(updates)
    return MOCK_DOCTOR_PROFILE

@router.get("/workplaces", response_model=List[Dict])
def get_workplaces():
    """Get the doctor's workplaces"""
    return MOCK_WORKPLACES

@router.post("/workplaces", response_model=List[Dict])
def add_workplace(workplace: Dict = Body(...)):
    """Add a new workplace"""
    MOCK_WORKPLACES.append(workplace)
    return MOCK_WORKPLACES

MOCK_FEES = {
    "hasFreeFirst": False,
    "videoFee": "80",
    "inPersonFee": "150",
    "emergencyFee": "250"
}

@router.get("/fees", response_model=Dict)
def get_fees():
    """Get the doctor's fees"""
    return MOCK_FEES

@router.put("/fees", response_model=Dict)
def update_fees(updates: Dict = Body(...)):
    """Update the doctor's fees"""
    MOCK_FEES.update(updates)
    return MOCK_FEES
