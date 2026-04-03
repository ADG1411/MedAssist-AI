from fastapi import APIRouter
from pydantic import BaseModel
from typing import Optional, Dict, Any, List

router = APIRouter()

class ChatMessage(BaseModel):
    message: str
    context: Optional[Dict[str, Any]] = None

class ChatResponse(BaseModel):
    text: str
    action: Optional[str] = None
    payload: Optional[Any] = None

@router.post("/", response_model=ChatResponse)
def process_chat_message(chat: ChatMessage):
    """
    Process incoming chat messages and return smart AI responses
    with actionable payloads for the frontend UI.
    """
    msg = chat.message.lower()
    
    # Intent: Appointments
    if "appointment" in msg or "schedule" in msg:
        return ChatResponse(
            text="Here are your appointments for today. You have 4 patients lined up.",
            action="show_appointments",
            payload=[
                {"id": 1, "patient": "Emma Watson", "time": "10:00 AM", "status": "Waiting"},
                {"id": 2, "patient": "John Doe", "time": "11:30 AM", "status": "In Progress"}
            ]
        )
        
    # Intent: Critical Patients / Emergency
    elif "critical" in msg or "emergency" in msg or "sos" in msg:
        return ChatResponse(
            text="I found 1 active critical case requiring immediate attention.",
            action="show_critical",
            payload=[
                {"id": 101, "patient": "Michael Johnson", "condition": "Severe Chest Pain", "status": "Critical"}
            ]
        )
        
    # Intent: Prescription Generation
    elif "prescription" in msg:
        return ChatResponse(
            text="I've generated a draft prescription for the patient based on common fever protocols.",
            action="generate_prescription",
            payload={
                "diagnosis": "Viral Fever",
                "medicines": [
                    {"name": "Paracetamol 500mg", "dosage": "1 tablet", "frequency": "Every 8 hours", "duration": "3 days"},
                    {"name": "Vitamin C", "dosage": "1 tablet", "frequency": "Once daily", "duration": "5 days"}
                ]
            }
        )
        
    # Intent: Patient History
    elif "history" in msg or "case" in msg:
        return ChatResponse(
            text="Here is the timeline and patient history for Rahul.",
            action="show_history",
            payload={
                "patient": "Rahul",
                "history": [
                    {"date": "2026-01-15", "event": "Diagnosed with Type 2 Diabetes"},
                    {"date": "2026-03-10", "event": "Routine Blood Test - HB1Ac normal"}
                ]
            }
        )
        
    # Intent: Summary
    elif "summary" in msg:
        return ChatResponse(
            text="Here is your summary for today: 4 Total Patients, 2 Completed Consultations, $450 Estimated Earnings.",
            action="show_summary"
        )
        
    # Default conversational fallback
    return ChatResponse(
        text="I am your Doctor Portal AI Assistant. I can help you fetch patient records, schedule appointments, generate prescriptions, or analyze reports. How can I assist you today?"
    )
