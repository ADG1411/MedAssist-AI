from fastapi import APIRouter, Depends
from typing import Dict, Any

router = APIRouter()

@router.get("/")
async def get_dashboard_stats() -> Dict[str, Any]:
    # In production, fetch these from DB/Redis caches.
    return {
        "active_doctors": 124,
        "active_patients": 4510,
        "live_consultations": 32,
        "emergency_cases": 2,
        "today_revenue": 14500.00,
        "trends": {
            "revenue": [ {"day": "Mon", "value": 12000}, {"day": "Tue", "value": 14500} ],
            "patients": [ {"day": "Mon", "value": 4480}, {"day": "Tue", "value": 4510} ]
        }
    }
