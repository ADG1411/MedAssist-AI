from fastapi import APIRouter
from typing import List, Dict, Any

router = APIRouter()

@router.get("/")
async def get_users(role: str = None) -> List[Dict[str, Any]]:
    # Mock data, normally fetch from DB
    return [
        {"id": 1, "name": "Dr. Sarah", "role": "doctor", "status": "active"},
        {"id": 2, "name": "John Doe", "role": "patient", "status": "active"}
    ]

@router.post("/doctor/{doctor_id}/approve")
async def approve_doctor(doctor_id: int):
    # Logic to approve a doctor
    return {"message": f"Doctor {doctor_id} approved."}
