from fastapi import APIRouter
from typing import Dict, Any

router = APIRouter()

@router.get("/summary", response_model=Dict[str, Any])
async def get_analytics_summary():
    """
    Returns high-level summary statistics for the Analytics dashboard cards.
    Includes data like total patients, appointments today, completed cases, and earnings.
    """
    return {
        "total_patients": {
            "value": 1284,
            "trend": "+12% from last wk",
            "is_positive": True
        },
        "appointments_today": {
            "value": 48,
            "trend": "8 walk-ins",
            "is_positive": True
        },
        "completed_cases": {
            "value": 342,
            "trend": "-3% drop",
            "is_positive": False
        },
        "monthly_earnings": {
            "value": 42500,
            "trend": "+18% increase",
            "is_positive": True
        }
    }

@router.get("/charts/patient-growth", response_model=Dict[str, Any])
async def get_patient_growth():
    """
    Returns chart data for patient volume over the week.
    """
    return {
        "status": "success",
        "data": [
            {"name": "Mon", "current": 45, "previous": 38},
            {"name": "Tue", "current": 52, "previous": 42},
            {"name": "Wed", "current": 48, "previous": 45},
            {"name": "Thu", "current": 61, "previous": 50},
            {"name": "Fri", "current": 59, "previous": 55},
            {"name": "Sat", "current": 35, "previous": 30},
            {"name": "Sun", "current": 20, "previous": 25},
        ]
    }

@router.get("/charts/revenue", response_model=Dict[str, Any])
async def get_revenue_breakdown():
    """
    Returns revenue metrics split by Online, Offline, and Emergency.
    """
    return {
        "status": "success",
        "data": [
            {"name": "Week 1", "Online": 4000, "Offline": 8000, "Emergency": 2000},
            {"name": "Week 2", "Online": 4500, "Offline": 8200, "Emergency": 1500},
            {"name": "Week 3", "Online": 5200, "Offline": 8900, "Emergency": 3000},
            {"name": "Week 4", "Online": 4800, "Offline": 8500, "Emergency": 2500},
        ]
    }

@router.get("/ai-insights", response_model=Dict[str, Any])
async def get_ai_insights():
    """
    Returns AI-generated insights for the doctor to optimize their practice.
    """
    return {
        "insights": [
            {
                "type": "trend",
                "title": "Patient Load Increased",
                "description": "Your patient load increased by 20% this week. Most cases are related to Diabetes & Hypertension.",
                "action": None
            },
            {
                "type": "schedule",
                "title": "Schedule Optimization",
                "description": "You are spending 15% more time per patient. Suggestion: Add more buffer slots on Mondays to prevent delays.",
                "action": "Adjust Monday Slots"
            },
            {
                "type": "alert",
                "title": "Predictive Alert",
                "description": "High chance of emergency cases tomorrow due to sudden weather drop. Ensure ER availability.",
                "action": None
            }
        ]
    }