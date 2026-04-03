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

from app.services.ai_service import generate_json
import datetime

@router.get("/ai-insights", response_model=Dict[str, Any])
async def get_ai_insights():
    """
    Returns AI-generated insights for the doctor to optimize their practice.
    """
    
    # In a real scenario, this would gather recent practice data
    mock_practice_data = {
        "recent_patient_volume": "+12%",
        "top_diagnoses": ["Diabetes", "Hypertension", "Viral Fever"],
        "avg_consult_time": "18 mins (up by 15%)",
        "current_date": datetime.datetime.now().strftime("%Y-%m-%d")
    }
    
    system_prompt = (
        "You are an expert clinical operations AI. Analyze the doctor's practice data "
        "and generate exactly 3 insights to optimize their practice operations and patient care.\n"
        "Return a JSON object with a single key 'insights' containing an array of 3 objects.\n"
        "Each object must have:\n"
        "- 'type' (string: 'trend', 'schedule', or 'alert')\n"
        "- 'title' (short string)\n"
        "- 'description' (string explaining the insight)\n"
        "- 'action' (string with a specific action to take, or null)"
    )
    
    prompt = f"Practice Data: {mock_practice_data}"
    
    ai_response = await generate_json(prompt, system_prompt)
    if "error" in ai_response:
        return {
            "insights": [
                {
                    "type": "error",
                    "title": "AI Offline",
                    "description": "Unable to generate insights right now.",
                    "action": None
                }
            ]
        }
        
    return ai_response