from fastapi import APIRouter, HTTPException, Body
from typing import List, Optional, Dict, Any
from pydantic import BaseModel
from datetime import datetime, timedelta
import uuid

router = APIRouter()

# ── Mock Data Models ──────────────────────────────────────────────────────────

class AIInsightRequest(BaseModel):
    patient_id: str
    current_symptoms: Optional[str] = None

# Mocks
def _get_mock_patient_summary(patient_id: str) -> Dict[str, Any]:
    return {
        "patient": {
            "id": patient_id,
            "name": "Rahul Sharma",
            "age": 34,
            "gender": "Male",
            "blood_group": "B+",
            "allergies": ["Penicillin", "Dust"],
            "emergency_contact": "+91 9876543210 (Wife)",
            "family_history": "Father: Type 2 Diabetes"
        },
        "timeline": [
            {"date": "2026-03-01", "type": "visit", "title": "Routine Checkup", "doctor": "Dr. Anil Kumar", "diagnosis": "Healthy"},
            {"date": "2025-11-15", "type": "specialist", "title": "Cardiology Consult", "doctor": "Dr. Sharma", "diagnosis": "Mild Hypertension"}
        ],
        "prescriptions": [
            {"name": "Amlodipine 5mg", "dosage": "1 tablet daily", "duration": "30 days"}
        ],
        "vitals": [
            {"date": "Today", "bp": "135/85", "sugar": "110 mg/dL", "hr": "78 bpm", "warnings": ["bp"]}
        ],
        "reports": [
            {"id": "r1", "name": "CBC Blood Test", "date": "2026-03-01", "type": "pdf"}
        ],
        "ai_summary": {
            "summary": "Patient has mild hypertension and a family history of diabetes. Vitals show moderately elevated blood pressure today.",
            "priority": "medium",
            "key_points": ["Elevated BP: 135/85", "Allergic to Penicillin", "On Amlodipine 5mg"],
            "recommended_action": "Monitor BP closely, possibly adjust Amlodipine dosage."
        },
        "risk_level": "medium"
    }

# ── Endpoints ─────────────────────────────────────────────────────────────────

@router.get("/patient/{patient_id}/full-summary")
def get_full_summary(patient_id: str) -> Dict[str, Any]:
    # In a real scenario, this would aggregate data from MedCard, history, etc.
    return _get_mock_patient_summary(patient_id)

@router.post("/ai/consultation-summary")
def generate_ai_summary(req: AIInsightRequest = Body(...)) -> Dict[str, Any]:
    # Analyzes patient info + live symptoms
    symptoms = req.current_symptoms or "none reported"
    risk_level = "medium"
    if "chest pain" in symptoms.lower() or "shortness of breath" in symptoms.lower():
        risk_level = "high"
    elif not req.current_symptoms:
        risk_level = "low"
    
    return {
        "summary": f"Live Analysis: Patient is experiencing {symptoms}. Previous history indicates hypertension.",
        "risk_level": risk_level,
        "suggestions": [
            "Order ECG immediately" if risk_level == "high" else "Continue current medication",
            "Check fasting blood sugar tomorrow"
        ],
        "alerts": ["Drug Interaction Alert: Do NOT prescribe Beta Blockers without checking asthma history."]
    }

@router.get("/patient/{patient_id}/vitals")
def get_patient_vitals(patient_id: str) -> List[Dict[str, Any]]:
    return [
        {"date": "2026-04-03", "bp": "135/85", "hr": "78"},
        {"date": "2026-03-01", "bp": "130/80", "hr": "75"}
    ]
