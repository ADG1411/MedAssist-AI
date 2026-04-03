from fastapi import APIRouter, Query
from typing import Dict, Any

router = APIRouter()

@router.get("/summary", response_model=Dict[str, Any])
async def get_analytics_summary(period: str = Query("This Month")):
    """
    Returns high-level summary statistics for the Analytics dashboard cards.
    """
    if period == "Today":
        return {
            "total_patients": { "value": "48", "trend": "6 new today", "is_positive": True },
            "appointments_today": { "value": "12", "trend": "3 walk-ins", "is_positive": True },
            "completed_cases": { "value": "9", "trend": "2 pending", "is_positive": False },
            "monthly_earnings": { "value": "$3,200", "trend": "8% vs yesterday", "is_positive": True }
        }
    elif period == "This Week":
        return {
            "total_patients": { "value": "312", "trend": "12% from last wk", "is_positive": True },
            "appointments_today": { "value": "48", "trend": "8 walk-ins", "is_positive": True },
            "completed_cases": { "value": "86", "trend": "3% drop", "is_positive": False },
            "monthly_earnings": { "value": "$18,400", "trend": "15% increase", "is_positive": True }
        }
    else: # This Month
        return {
            "total_patients": { "value": "1,284", "trend": "12% from last wk", "is_positive": True },
            "appointments_today": { "value": "342", "trend": "28 walk-ins", "is_positive": True },
            "completed_cases": { "value": "342", "trend": "3% drop", "is_positive": False },
            "monthly_earnings": { "value": "$42,500", "trend": "18% increase", "is_positive": True }
        }

@router.get("/charts/patient-growth", response_model=Dict[str, Any])
async def get_patient_growth(period: str = Query("This Month")):
    if period == "Today":
        data = [
            {"name": "8 am", "current": 4, "previous": 3},
            {"name": "10 am", "current": 8, "previous": 6},
            {"name": "12 pm", "current": 12, "previous": 9},
            {"name": "2 pm", "current": 14, "previous": 11},
            {"name": "4 pm", "current": 10, "previous": 8},
            {"name": "6 pm", "current": 6, "previous": 7},
        ]
        badge = "Growth +8%"
    elif period == "This Week":
        data = [
            {"name": "Mon", "current": 45, "previous": 38},
            {"name": "Tue", "current": 52, "previous": 42},
            {"name": "Wed", "current": 48, "previous": 45},
            {"name": "Thu", "current": 61, "previous": 50},
            {"name": "Fri", "current": 59, "previous": 55},
            {"name": "Sat", "current": 35, "previous": 30},
            {"name": "Sun", "current": 20, "previous": 25},
        ]
        badge = "Growth +15%"
    else:
        data = [
            {"name": "Week 1", "current": 290, "previous": 240},
            {"name": "Week 2", "current": 320, "previous": 280},
            {"name": "Week 3", "current": 340, "previous": 295},
            {"name": "Week 4", "current": 334, "previous": 305},
        ]
        badge = "Growth +12%"
        
    return {"status": "success", "data": data, "growthBadge": badge}

@router.get("/charts/revenue", response_model=Dict[str, Any])
async def get_revenue_breakdown(period: str = Query("This Month")):
    if period == "Today":
        data = [
            {"name": "8-10am", "Online": 400, "Offline": 800, "Emergency": 0},
            {"name": "10-12pm", "Online": 600, "Offline": 1000, "Emergency": 200},
            {"name": "12-2pm", "Online": 500, "Offline": 900, "Emergency": 0},
            {"name": "2-4pm", "Online": 700, "Offline": 800, "Emergency": 300},
            {"name": "4-6pm", "Online": 300, "Offline": 600, "Emergency": 0},
        ]
    elif period == "This Week":
        data = [
            {"name": "Mon", "Online": 2000, "Offline": 3500, "Emergency": 500},
            {"name": "Tue", "Online": 2200, "Offline": 3800, "Emergency": 300},
            {"name": "Wed", "Online": 1800, "Offline": 3200, "Emergency": 800},
            {"name": "Thu", "Online": 2500, "Offline": 4000, "Emergency": 600},
            {"name": "Fri", "Online": 2300, "Offline": 3600, "Emergency": 400},
            {"name": "Sat", "Online": 1200, "Offline": 2000, "Emergency": 200},
            {"name": "Sun", "Online": 600, "Offline": 1000, "Emergency": 0},
        ]
    else:
        data = [
            {"name": "Week 1", "Online": 8000, "Offline": 14000, "Emergency": 2500},
            {"name": "Week 2", "Online": 9000, "Offline": 15000, "Emergency": 1800},
            {"name": "Week 3", "Online": 10000, "Offline": 16000, "Emergency": 3200},
            {"name": "Week 4", "Online": 9500, "Offline": 15500, "Emergency": 2800},
        ]
    return {"status": "success", "data": data}

from app.services.ai_service import generate_json
import datetime

@router.get("/ai-insights", response_model=Dict[str, Any])
async def get_ai_insights(period: str = Query("This Month")):
    """
    Returns AI-generated insights for the doctor to optimize their practice.
    """
    
    # In a real scenario, this would gather recent practice data
    mock_practice_data = {
        "recent_patient_volume": "+12%" if period == "This Month" else "+15%",
        "top_diagnoses": ["Diabetes", "Hypertension", "Viral Fever"],
        "avg_consult_time": "18 mins (up by 15%)",
        "period_examined": period,
        "current_date": datetime.datetime.now().strftime("%Y-%m-%d")
    }
    
    system_prompt = (
        "You are an expert clinical operations AI. Analyze the doctor's practice data "
        "and generate exactly 3 insights to optimize their practice operations and patient care.\n"
        "Return a JSON object with a single key 'insights' containing an array of 3 objects.\n"
        "Each object must have:\n"
        "- 'type' (string: strictly one of 'trend', 'schedule', or 'alert')\n"
        "- 'title' (short string)\n"
        "- 'description' (string explaining the insight)\n"
        "- 'action' (string with a VERY SHORT 2-4 word label for a button to take action, or null)"
    )
    
    prompt = f"Practice Data: {mock_practice_data}"
    
    # Force use of backend AI model
    ai_response = await generate_json(prompt, system_prompt)
    if "error" in ai_response or "insights" not in ai_response:
        return {
            "insights": [
                {
                    "type": "error",
                    "title": "AI Offline",
                    "description": f"Unable to generate insights right now. {ai_response.get('error', '')}",
                    "action": None
                }
            ]
        }
        
    return ai_response