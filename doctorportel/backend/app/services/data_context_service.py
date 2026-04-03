"""
Data Context Service
====================
Gathers local data from JSON stores and formats it as context strings
that can be injected into AI prompts for offline (local data) mode.
"""
import json
import logging
from pathlib import Path
from typing import Dict, Any, List

logger = logging.getLogger(__name__)

# Path to the patients JSON store (same one used by patients/router.py)
_PATIENTS_FILE = Path(__file__).parent.parent / "api" / "patients" / "patients_data.json"


def get_patient_context() -> str:
    """Load all patients from the JSON store and format as context string."""
    try:
        if _PATIENTS_FILE.exists():
            with open(_PATIENTS_FILE, "r", encoding="utf-8") as f:
                patients = json.load(f)
        else:
            patients = []
        
        if not patients:
            return "No patients found in the database."
        
        lines = [f"Total Patients in Database: {len(patients)}\n"]
        
        # Group by status
        active = [p for p in patients if p.get("status") == "Active"]
        critical = [p for p in patients if p.get("status") == "Critical"]
        recovered = [p for p in patients if p.get("status") == "Recovered"]
        
        lines.append(f"Active: {len(active)} | Critical: {len(critical)} | Recovered: {len(recovered)}\n")
        lines.append("--- Patient Records ---")
        
        for p in patients:
            name = f"{p.get('first_name', '')} {p.get('last_name', '')}"
            lines.append(
                f"• [{p.get('id')}] {name}, Age {p.get('age')}, {p.get('gender')} | "
                f"Status: {p.get('status')} | Diagnosis: {p.get('last_diagnosis', 'N/A')} | "
                f"Risk: {p.get('risk_score', 0)}/100 | "
                f"Pending: ${p.get('pending_amount', 0)} | "
                f"Tags: {', '.join(p.get('tags', []))}"
            )
        
        return "\n".join(lines)
    except Exception as e:
        logger.error(f"Error loading patient context: {e}")
        return "Error loading patient data from local database."


def get_patient_by_name(name_query: str) -> str:
    """Search for a specific patient by name and return detailed info."""
    try:
        if _PATIENTS_FILE.exists():
            with open(_PATIENTS_FILE, "r", encoding="utf-8") as f:
                patients = json.load(f)
        else:
            return "No patient database found."
        
        query_lower = name_query.lower()
        matches = []
        for p in patients:
            full_name = f"{p.get('first_name', '')} {p.get('last_name', '')}".lower()
            if query_lower in full_name:
                matches.append(p)
        
        if not matches:
            return f"No patients found matching '{name_query}'."
        
        lines = [f"Found {len(matches)} patient(s) matching '{name_query}':\n"]
        for p in matches:
            name = f"{p.get('first_name', '')} {p.get('last_name', '')}"
            lines.append(f"Patient: {name} (ID: {p.get('id')})")
            lines.append(f"  Age: {p.get('age')} | Gender: {p.get('gender')}")
            lines.append(f"  Status: {p.get('status')}")
            lines.append(f"  Last Diagnosis: {p.get('last_diagnosis', 'N/A')}")
            lines.append(f"  Last Visit: {p.get('last_visit', 'N/A')}")
            lines.append(f"  Risk Score: {p.get('risk_score', 0)}/100")
            lines.append(f"  Total Fees: ${p.get('total_fees', 0)} | Pending: ${p.get('pending_amount', 0)}")
            lines.append(f"  Tags: {', '.join(p.get('tags', []))}")
            lines.append(f"  Next Follow-up: {p.get('next_follow_up', 'Not scheduled')}")
            lines.append(f"  Contact: {p.get('email', 'N/A')} | {p.get('phone_number', 'N/A')}")
            lines.append("")
        
        return "\n".join(lines)
    except Exception as e:
        logger.error(f"Error searching patient: {e}")
        return "Error searching patient database."


def get_appointment_context() -> str:
    """Return a mock context of today's appointments."""
    # In a real scenario this would query a DB. For now, provide structured mock data.
    appointments = [
        {"id": "A-001", "patient": "Rahul Sharma", "time": "10:30 AM", "status": "Waiting", "type": "Follow up"},
        {"id": "A-002", "patient": "Emma Watson", "time": "11:00 AM", "status": "In Progress", "type": "Checkup"},
        {"id": "A-003", "patient": "Sarah Smith", "time": "11:45 AM", "status": "Scheduled", "type": "Consultation"},
        {"id": "A-004", "patient": "Michael Johnson", "time": "1:00 PM", "status": "Scheduled", "type": "Emergency"},
        {"id": "A-005", "patient": "Priya Sharma", "time": "2:30 PM", "status": "Scheduled", "type": "Follow up"},
        {"id": "A-006", "patient": "David Miller", "time": "3:15 PM", "status": "Scheduled", "type": "Consultation"},
    ]
    
    lines = [f"Today's Appointments ({len(appointments)} total):\n"]
    for a in appointments:
        lines.append(f"• [{a['id']}] {a['time']} — {a['patient']} | {a['type']} | Status: {a['status']}")
    
    waiting = sum(1 for a in appointments if a["status"] == "Waiting")
    in_progress = sum(1 for a in appointments if a["status"] == "In Progress")
    scheduled = sum(1 for a in appointments if a["status"] == "Scheduled")
    
    lines.append(f"\nSummary: {waiting} waiting, {in_progress} in progress, {scheduled} upcoming")
    return "\n".join(lines)


def get_analytics_context() -> str:
    """Return a summary of practice analytics for AI context."""
    return (
        "Practice Analytics Summary:\n"
        "• Total Patients: 1,284 (+12% this month)\n"
        "• Appointments Today: 14 (4 remaining)\n"
        "• Active Tickets: 7 (2 require attention)\n"
        "• Earnings Today: $840 (+5% vs yesterday)\n"
        "• Monthly Earnings: $42,500 (+18% increase)\n"
        "• Top Diagnoses: Diabetes, Hypertension, Viral Fever\n"
        "• Avg Consult Time: 18 mins (target < 15 mins)\n"
        "• Patient Satisfaction: 4.9/5 (Top 5%)\n"
        "• Emergency Response: < 2 min (Optimal)"
    )


def get_full_context() -> str:
    """Combine all local data into one comprehensive context."""
    sections = [
        get_patient_context(),
        "",
        get_appointment_context(),
        "",
        get_analytics_context(),
    ]
    return "\n\n".join(sections)
