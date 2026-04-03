from fastapi import APIRouter
from typing import List, Dict, Any

router = APIRouter()

@router.get("/")
async def get_cases(status: str = "active") -> List[Dict[str, Any]]:
    # Filter cases from DB
    return [
        {"id": "CAS-101", "patient": "John Doe", "doctor": "Dr. Sarah", "status": "active", "priority": "high"},
        {"id": "CAS-102", "patient": "Alice Smith", "doctor": "Dr. Ben", "status": "completed", "priority": "normal"}
    ]
