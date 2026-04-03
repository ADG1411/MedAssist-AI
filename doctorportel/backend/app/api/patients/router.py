from fastapi import APIRouter, Body, HTTPException
from typing import List, Dict, Any, Optional
from pydantic import BaseModel
from pathlib import Path
import json

router = APIRouter()

# ── JSON file persistence ────────────────────────────────────────────────────

_DATA_FILE = Path(__file__).parent / "patients_data.json"

_DEFAULT_PATIENTS: List[Dict[str, Any]] = [
    {
        "id": "P-1001",
        "first_name": "Emma",
        "last_name": "Watson",
        "email": "emma.w@example.com",
        "phone_number": "+1 (555) 123-4567",
        "age": 34,
        "gender": "Female",
        "status": "Active",
        "last_diagnosis": "Type 2 Diabetes",
        "last_visit": "2024-10-15",
        "total_fees": 1250,
        "pending_amount": 0,
        "is_favorite": True,
        "risk_score": 65,
        "tags": ["Diabetes", "VIP"],
        "next_follow_up": "2024-10-30",
        "avatar": "https://ui-avatars.com/api/?name=Emma+Watson&background=f87171&color=fff",
        "is_active": True,
    },
    {
        "id": "P-1002",
        "first_name": "Michael",
        "last_name": "Johnson",
        "email": "mjohnson@example.com",
        "phone_number": "+1 (555) 987-6543",
        "age": 58,
        "gender": "Male",
        "status": "Critical",
        "last_diagnosis": "Severe Chest Pain",
        "last_visit": "2024-10-24",
        "total_fees": 3400,
        "pending_amount": 400,
        "is_favorite": False,
        "risk_score": 92,
        "tags": ["Heart", "Emergency"],
        "next_follow_up": "2024-10-25",
        "avatar": "https://ui-avatars.com/api/?name=Michael+Johnson&background=ef4444&color=fff",
        "is_active": True,
    },
    {
        "id": "P-1003",
        "first_name": "Sarah",
        "last_name": "Smith",
        "email": "sarah.smith@example.com",
        "phone_number": "+1 (555) 456-7890",
        "age": 42,
        "gender": "Female",
        "status": "Active",
        "last_diagnosis": "Anemia",
        "last_visit": "2024-10-23",
        "total_fees": 850,
        "pending_amount": 50,
        "is_favorite": True,
        "risk_score": 45,
        "tags": ["BP", "Follow-up"],
        "next_follow_up": "2024-11-05",
        "avatar": "https://ui-avatars.com/api/?name=Sarah+Smith&background=34d399&color=fff",
        "is_active": True,
    },
    {
        "id": "P-1004",
        "first_name": "Robert",
        "last_name": "Fox",
        "email": "rfox12@example.com",
        "phone_number": "+1 (555) 234-5678",
        "age": 61,
        "gender": "Male",
        "status": "Recovered",
        "last_diagnosis": "Post-Surgery Checkup",
        "last_visit": "2024-09-12",
        "total_fees": 5600,
        "pending_amount": 0,
        "is_favorite": False,
        "risk_score": 15,
        "tags": ["Surgery"],
        "next_follow_up": None,
        "avatar": "https://ui-avatars.com/api/?name=Robert+Fox&background=94a3b8&color=fff",
        "is_active": True,
    },
    {
        "id": "P-1005",
        "first_name": "Eleanor",
        "last_name": "Pena",
        "email": "eleanor.p@example.com",
        "phone_number": "+1 (555) 876-5432",
        "age": 29,
        "gender": "Female",
        "status": "Active",
        "last_diagnosis": "Migraine",
        "last_visit": "2024-10-20",
        "total_fees": 450,
        "pending_amount": 100,
        "is_favorite": False,
        "risk_score": 30,
        "tags": ["Neurology"],
        "next_follow_up": "2024-11-10",
        "avatar": "https://ui-avatars.com/api/?name=Eleanor+Pena&background=a78bfa&color=fff",
        "is_active": True,
    },
    {
        "id": "P-1006",
        "first_name": "James",
        "last_name": "Carter",
        "email": "j.carter@example.com",
        "phone_number": "+1 (555) 321-9876",
        "age": 47,
        "gender": "Male",
        "status": "Critical",
        "last_diagnosis": "Hypertensive Crisis",
        "last_visit": "2024-10-26",
        "total_fees": 2100,
        "pending_amount": 800,
        "is_favorite": False,
        "risk_score": 88,
        "tags": ["Hypertension", "ICU"],
        "next_follow_up": "2024-10-27",
        "avatar": "https://ui-avatars.com/api/?name=James+Carter&background=f59e0b&color=fff",
        "is_active": True,
    },
    {
        "id": "P-1007",
        "first_name": "Priya",
        "last_name": "Sharma",
        "email": "priya.sharma@example.com",
        "phone_number": "+91 98765 43210",
        "age": 36,
        "gender": "Female",
        "status": "Active",
        "last_diagnosis": "Thyroid Disorder",
        "last_visit": "2024-10-18",
        "total_fees": 680,
        "pending_amount": 0,
        "is_favorite": True,
        "risk_score": 38,
        "tags": ["Thyroid", "Regular"],
        "next_follow_up": "2024-11-18",
        "avatar": "https://ui-avatars.com/api/?name=Priya+Sharma&background=6366f1&color=fff",
        "is_active": True,
    },
    {
        "id": "P-1008",
        "first_name": "David",
        "last_name": "Miller",
        "email": "dmiller@example.com",
        "phone_number": "+1 (555) 654-3210",
        "age": 72,
        "gender": "Male",
        "status": "Active",
        "last_diagnosis": "Arthritis",
        "last_visit": "2024-10-10",
        "total_fees": 920,
        "pending_amount": 200,
        "is_favorite": False,
        "risk_score": 55,
        "tags": ["Ortho", "Senior"],
        "next_follow_up": "2024-11-10",
        "avatar": "https://ui-avatars.com/api/?name=David+Miller&background=0ea5e9&color=fff",
        "is_active": True,
    },
    {
        "id": "P-1009",
        "first_name": "Aisha",
        "last_name": "Khan",
        "email": "aisha.k@example.com",
        "phone_number": "+1 (555) 789-0123",
        "age": 25,
        "gender": "Female",
        "status": "Recovered",
        "last_diagnosis": "Viral Fever",
        "last_visit": "2024-09-30",
        "total_fees": 320,
        "pending_amount": 0,
        "is_favorite": False,
        "risk_score": 10,
        "tags": ["Discharged"],
        "next_follow_up": None,
        "avatar": "https://ui-avatars.com/api/?name=Aisha+Khan&background=10b981&color=fff",
        "is_active": True,
    },
    {
        "id": "P-1010",
        "first_name": "Ravi",
        "last_name": "Verma",
        "email": "ravi.verma@example.com",
        "phone_number": "+91 99887 76655",
        "age": 52,
        "gender": "Male",
        "status": "Active",
        "last_diagnosis": "Kidney Stone",
        "last_visit": "2024-10-22",
        "total_fees": 1750,
        "pending_amount": 500,
        "is_favorite": False,
        "risk_score": 70,
        "tags": ["Urology", "Follow-up"],
        "next_follow_up": "2024-11-01",
        "avatar": "https://ui-avatars.com/api/?name=Ravi+Verma&background=f43f5e&color=fff",
        "is_active": True,
    },
]


# ── File-backed helpers ──────────────────────────────────────────────────────

def _load() -> List[Dict[str, Any]]:
    """Load patients from JSON file, seeding defaults on first run."""
    if _DATA_FILE.exists():
        try:
            with open(_DATA_FILE, "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception:
            pass
    _save(_DEFAULT_PATIENTS)
    return list(_DEFAULT_PATIENTS)


def _save(patients: List[Dict[str, Any]]) -> None:
    """Persist patient list to JSON file."""
    with open(_DATA_FILE, "w", encoding="utf-8") as f:
        json.dump(patients, f, indent=2, ensure_ascii=False)


# ── Request model for new patient ────────────────────────────────────────────

class NewPatientRequest(BaseModel):
    first_name: str
    last_name: str
    email: str
    phone_number: str
    age: int
    gender: str
    status: Optional[str] = "Active"
    last_diagnosis: Optional[str] = ""
    last_visit: Optional[str] = ""
    total_fees: Optional[float] = 0
    pending_amount: Optional[float] = 0
    is_favorite: Optional[bool] = False
    risk_score: Optional[int] = 20
    tags: Optional[List[str]] = []
    next_follow_up: Optional[str] = None


# ── Endpoints ─────────────────────────────────────────────────────────────────

@router.get("/")
def get_patients() -> List[Dict[str, Any]]:
    """Return all patients from persistent JSON store."""
    return _load()


@router.get("/{patient_id}")
def get_patient(patient_id: str) -> Dict[str, Any]:
    """Return a single patient by ID."""
    for p in _load():
        if p["id"] == patient_id:
            return p
    raise HTTPException(status_code=404, detail="Patient not found")


@router.post("/")
def create_patient(payload: NewPatientRequest = Body(...)) -> Dict[str, Any]:
    """Add a new patient and persist to JSON file."""
    patients = _load()
    new_id = f"P-{1000 + len(patients) + 1}"
    new_patient: Dict[str, Any] = {
        "id": new_id,
        "first_name": payload.first_name,
        "last_name": payload.last_name,
        "email": payload.email,
        "phone_number": payload.phone_number,
        "age": payload.age,
        "gender": payload.gender,
        "status": payload.status or "Active",
        "last_diagnosis": payload.last_diagnosis or "",
        "last_visit": payload.last_visit or "",
        "total_fees": payload.total_fees or 0,
        "pending_amount": payload.pending_amount or 0,
        "is_favorite": payload.is_favorite or False,
        "risk_score": payload.risk_score or 20,
        "tags": payload.tags or [],
        "next_follow_up": payload.next_follow_up,
        "avatar": f"https://ui-avatars.com/api/?name={payload.first_name}+{payload.last_name}&background=random&color=fff",
        "is_active": True,
    }
    patients.insert(0, new_patient)
    _save(patients)
    return new_patient


@router.delete("/{patient_id}")
def delete_patient(patient_id: str) -> Dict[str, str]:
    """Delete a patient and persist the change."""
    patients = _load()
    updated = [p for p in patients if p["id"] != patient_id]
    if len(updated) == len(patients):
        raise HTTPException(status_code=404, detail="Patient not found")
    _save(updated)
    return {"deleted": patient_id}
